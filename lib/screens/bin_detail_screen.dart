import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/bin_model.dart';
import 'bin_creation_screen.dart';
import '../models/rental_record.dart';
import '../utils/helpers.dart';

class BinDetailScreen extends StatefulWidget{
    final BinItem bin;
    final int hiveKey;

    const BinDetailScreen({
        Key? key,
        required this.bin,
        required this.hiveKey
    }) : super(key: key);

    @override
    State<BinDetailScreen> createState() => _BinDetailScreenState();
}

class _BinDetailScreenState extends State<BinDetailScreen> {
    late Box<BinItem> binsBox;
    late Box<RentalRecord> rentalsBox;

    late BinItem _bin;
    RentalRecord? _currentRental;
    Timer? _timer;
    int _secondsLeft = 0;

    @override
    void initState() {
        super.initState();
        binsBox = Hive.box<BinItem>('bins');
        rentalsBox = Hive.box<RentalRecord>('rentals');
        _loadData();
    }

    void _loadData() {
        _bin = binsBox.get(widget.hiveKey) ?? widget.bin;

        if (_bin.currentRentalKey != null) {
            _currentRental = rentalsBox.get(_bin.currentRentalKey);
        } else {
            _currentRental = null;
        }

        _updateRemainingTime();
        // _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        //     _updateRemainingTime();
        // });
    }

    void _updateRemainingTime() {
      _timer?.cancel();

      if (_currentRental == null) {
          setState(() {
            _secondsLeft = 0;
          });
          return;
      }

      _secondsLeft = _currentRental!.secondsLeft();

      if (_currentRental!.state == RentalState.active && !_currentRental!.isExpired) {
          _timer = Timer.periodic(const Duration(seconds: 1), (_) {
              _tick();
          });
      } else {
        setState(() {});
        // final now = DateTime.now();
        // final rem = _bin.expiresAt.difference(now);
        // setState(() {
        //     _remaining = rem;
        // });
      }
    }

    void _tick() {
        if (!mounted) return;
        final seconds = _currentRental?.secondsLeft() ?? 0;
        setState(() {
            _secondsLeft = seconds;
        });
        // if rental just expired while active, stop timer (we leave state as active but expired)
        if (_currentRental != null && _currentRental!.state == RentalState.active && _currentRental!.secondsLeft() <= 0) {
            _timer?.cancel();
            setState(() {});
        }
    }

    Future<void> _pauseRental() async {
        if (_currentRental == null) return;
        if (_currentRental!.state != RentalState.active) return;
        if (_currentRental!.isExpired) return; // cannot pause expired rental

        final remaining = _currentRental!.secondsLeft();
        final updated = _currentRental!.copyWith(
            startDate: null,
            remainingSeconds: remaining > 0 ? remaining : 0,
            state: RentalState.inactive
        );

        await rentalsBox.put(_bin.currentRentalKey, updated);
        setState(() {
            _currentRental = updated;
            _secondsLeft = updated.secondsLeft();
        });
        _timer?.cancel();
    }

    Future<void> _resumeRental() async {
        if (_currentRental == null) return;
        if (_currentRental!.state != RentalState.inactive) return;

        final updated = _currentRental!.copyWith(
            startDate: DateTime.now(),
            remainingSeconds: null,
            state: RentalState.active
        );

        await rentalsBox.put(_bin.currentRentalKey, updated);
        setState(() {
            _currentRental = updated;
            _secondsLeft = updated.secondsLeft();
        });
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }

    Future<void> _endRental() async {
        if (_currentRental == null) return;

        final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
                title: const Text('End Rental'),
                content: Text('End rental for bin ${_bin.id}? This cannot be undone.'),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(c).pop(false),
                        child: const Text('Cancel')
                    ),
                    TextButton(
                        onPressed: () => Navigator.of(c).pop(true),
                        child: const Text('End Rental')
                    )
                ],
            )
        );
        
        if (ok != true) return;

        final ended = _currentRental!.copyWith(
            state: RentalState.completed,
            endedAt: DateTime.now(),
        );

        final rentalKey = _bin.currentRentalKey!;
        await rentalsBox.put(rentalKey, ended);

        final history = (_bin.rentalHistory ?? [])..add(rentalKey);
        final updatedBin = _bin.copyWith(
            currentRentalKey: null,
            rentalHistory: history,
        );

        await binsBox.put(widget.hiveKey, updatedBin);
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pop(true);
        }); // pop with true to indicate success
    }

    Future<void> _createRentalDialog() async {
        final renterNameCtrl = TextEditingController();
        final renterPhoneCtrl = TextEditingController();
        RentalState initialState = RentalState.active;
        final formKey = GlobalKey<FormState>();

        try {
            final result = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                    title: const Text('Create Rental'),
                    content: Form(
                        key: formKey,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                TextFormField(
                                    controller: renterNameCtrl,
                                    decoration: const InputDecoration(labelText: 'Renter Name (optional)'),
                                ),
                                TextFormField(
                                    controller: renterPhoneCtrl,
                                    decoration: const InputDecoration(labelText: 'Renter Phone (optional)'),
                                    keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<RentalState>(
                                    value: initialState,
                                    items: const [
                                        DropdownMenuItem(value: RentalState.active, child: Text('Active')),
                                        DropdownMenuItem(value: RentalState.inactive, child: Text('Inactive')),
                                    ],
                                    onChanged: (value) {
                                        if (value != null) {
                                            initialState = value;
                                        }
                                    },
                                    decoration: const InputDecoration(labelText: 'Rental State'),
                                )
                            ],
                        )
                    ),
                    actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(
                            onPressed: () {
                                if (formKey.currentState?.validate() ?? true) {
                                    Navigator.pop(context, true); 
                                }
                            },
                            child: const Text('Create')
                        ),
                    ],
                )
            );

            if (result != true) return;

            final renterName = renterNameCtrl.text.trim();
            final renterPhone = renterPhoneCtrl.text.trim();
            
            renterNameCtrl.dispose();
            renterPhoneCtrl.dispose();

            final now = DateTime.now();
            final rental = RentalRecord(
                renterName: renterName,
                renterPhone: renterPhone,
                startDate: initialState == RentalState.active ? now : null,
                remainingSeconds: initialState == RentalState.inactive ? 10 * 24 * 3600 : null,
                plannedSeconds: 10 * 24 * 3600,
                state: initialState,
            );

            final rentalKey = await rentalsBox.add(rental);
            final history = List<int>.from(_bin.rentalHistory ?? [])..add(rentalKey);
            final updatedBin = _bin.copyWith(
                currentRentalKey: rentalKey,
                rentalHistory: history,
            );
            await binsBox.put(widget.hiveKey, updatedBin);

            _loadData(); // reload data to reflect changes
        } finally {
            try { renterNameCtrl.dispose(); } catch (_) {}
            try { renterPhoneCtrl.dispose(); } catch (_) {}
        }
    }
    // int _extraDays() {
    //     final now = DateTime.now();
    //     final extra = _bin.expiresAt.difference(now).inDays;
    //     return -extra;
    // }

    Future<void> _editBin() async {
        final result = await Navigator.push<BinItem>(
            context,
            MaterialPageRoute(
                builder: (_) => BinCreationScreen(
                    bin: _bin,
                    binKey: widget.hiveKey,
                )
            )
        );

        if (result != null) {
            final updated = result.copyWith(
                currentRentalKey: _bin.currentRentalKey,
                rentalHistory: _bin.rentalHistory,
            );
            await binsBox.put(widget.hiveKey, updated);
            _loadData();
        }
    }

    @override
    void dispose() {
        _timer?.cancel();
        super.dispose();
    }

    // Future<void> _onDelete() async {
    //     final ok = await showDialog<bool>(
    //         context: context,
    //         builder: (c) => AlertDialog(
    //             title: const Text('Delete Bin'),
    //             content: Text('Delete bin ${_bin.id}? This cannot be undone.'),
    //             actions: [
    //                 TextButton(
    //                     onPressed: () => Navigator.of(c).pop(false),
    //                     child: const Text('Cancel')
    //                 ),
    //                 TextButton(
    //                     onPressed: () => Navigator.of(c).pop(true),
    //                     child: const Text('Delete')
    //                 )
    //             ],
    //         )
    //     );

    //     if (ok == true) {
    //         await binBox.delete(widget.hiveKey);
    //         if (mounted) {
    //             Navigator.of(context).pop(true);
    //         }
    //     }
    // }

    @override
    Widget build(BuildContext context) {
        final hasRental = _currentRental != null;
        final isActive = _currentRental?.state == RentalState.active;
        final isInactive = _currentRental?.state == RentalState.inactive;
        final expired = _currentRental?.isExpired ?? false;

        final timerText = hasRental ? formatSeconds(_secondsLeft) : 'No active rental';
        // final expired = _remaining.isNegative;
        // final extraDays = _extraDays() > 0;
        // final statusText = expired 
        //     ? 'Expired ${_formatDuration(_remaining)} ago'
        //     : '${_formatDuration(_remaining)} left';
        
        // final extraDaysText = extraDays 
        //     ? 'Extra days: ${_extraDays()}'
        //     : 'There are no extra days';

        return Scaffold(
            appBar: AppBar(
                title: Text('Bin ${_bin.id}'),
                actions: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: _editBin),
                    // IconButton(icon: const Icon(Icons.delete), onPressed: _onDelete),
                ],
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(children: [
                            Icon(
                                hasRental ? (expired ? Icons.block : (isActive ? Icons.timer : Icons.pause_circle)) : Icons.inventory_2,
                                color: hasRental ? (expired ? Colors.red : (isActive ? Colors.green : Colors.orange)) : Colors.grey,
                                size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                                hasRental ? (_currentRental!.renterName.isNotEmpty ? _currentRental!.renterName : 'Rented') : 'Free',
                                style: Theme.of(context).textTheme.titleMedium,
                            ),
                        ]),
                        const SizedBox(height: 16),

                        Text('ID: ${_bin.id}', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Location: ${_bin.location ?? '—'}'),
                        const SizedBox(height: 8),
                        if (!hasRental) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                                onPressed: _createRentalDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Create Rental'),
                            )
                        ] else ...[
                            const SizedBox(height: 12),
                            Text('Renter phone: ${_currentRental!.renterPhone.isNotEmpty ? _currentRental!.renterPhone : '—'}'),
                            const SizedBox(height: 8),
                            Text('Planned duration: ${(_currentRental!.plannedSeconds / 86400).round()} days'),
                            const SizedBox(height: 12),
                            Center(
                                child: Column(
                                    children: [
                                        Text(
                                            expired ? 'Expired ${timerText} ago' : timerText,
                                            style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: expired ? Colors.red : (isActive ? Colors.green : Colors.orange),
                                            )
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                if (isActive && !expired)
                                                    ElevatedButton.icon(
                                                        onPressed: _pauseRental,
                                                        icon: const Icon(Icons.pause),
                                                        label: const Text('Pause Rental'),
                                                    ),
                                                if (isInactive)
                                                    ElevatedButton.icon(
                                                        onPressed: _resumeRental,
                                                        icon: const Icon(Icons.play_arrow),
                                                        label: const Text('Resume Rental'),
                                                    ),
                                                const SizedBox(width: 12),
                                                ElevatedButton.icon(
                                                    onPressed: _endRental,
                                                    icon: const Icon(Icons.check),
                                                    label: const Text('End Rental'),
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                    ),
                                                ),
                                            ],
                                        )
                                    ]
                                )
                            )
                        ]
                        // const SizedBox(height: 8),
                        // Text('Placed: ${_bin.startDate.toLocal()}'),
                        // const SizedBox(height: 8),
                        // Text('Expires: ${_bin.expiresAt.toLocal()}'),
                        // const SizedBox(height: 24),

                        // Center(
                        //     child: Column(
                        //         children: [
                        //             Text(statusText,
                        //                 style: TextStyle(
                        //                     fontSize: 24,
                        //                     fontWeight: FontWeight.bold,
                        //                     color: expired ? Colors.red : Colors.green,
                        //                 )),
                        //             const SizedBox(height: 16),
                        //             Text(extraDaysText,
                        //                 style: TextStyle(
                        //                     fontSize: 18,
                        //                     fontWeight: FontWeight.bold,
                        //                     color: extraDays ? Colors.green.shade800 : Colors.black,
                        //                     )),
                        //             const SizedBox(height: 300),
                        //             ElevatedButton.icon(
                        //                 icon: const Icon(Icons.edit),
                        //                 label: const Text('Edit Bin'),
                        //                 onPressed: _onEdit,
                        //             ),
                        //             const SizedBox(height: 8),
                        //             ElevatedButton.icon(
                        //                 icon: const Icon(Icons.delete),
                        //                 label: const Text('Delete Bin'),
                        //                 style: ElevatedButton.styleFrom(
                        //                     backgroundColor: Colors.red,
                        //                 ),
                        //                 onPressed: _onDelete,
                        //             ),
                        //         ],
                        //     ),
                        // ),
                    ],
                ),
            ),
        );
    }
}