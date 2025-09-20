import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/bin_model.dart';
// import 'bin_creation_screen.dart';
import '../models/rental_record.dart';
import '../utils/helpers.dart';
import '../widgets/rental_history_widget.dart';

class BinDetailScreen extends StatefulWidget {
  final BinItem bin;
  final int hiveKey;

  const BinDetailScreen({super.key, required this.bin, required this.hiveKey});

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
      // print('Current rental: $_currentRental');
    } else {
      _currentRental = null;
    }

    setState(() {});

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

    if (_currentRental!.state == RentalState.active &&
        !_currentRental!.isExpired) {
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
    // if rental just expired while active, keep counting (extra time)
    if (_currentRental != null &&
        _currentRental!.state == RentalState.active &&
        _currentRental!.secondsLeft() <= 0) {
      _currentRental!.isExpired;
    }
  }

  Future<void> _pauseRental() async {
    if (_currentRental == null || _currentRental!.state != RentalState.active)
      return;

    final remaining = _currentRental!.secondsLeft();
    final updated = _currentRental!.copyWith(
      startDate: null,
      remainingSeconds: remaining,
      state: RentalState.paused,
    );

    await rentalsBox.put(_bin.currentRentalKey, updated);

    final updatedBin = _bin.copyWith(
      currentRentalKey: _bin.currentRentalKey,
      rentalHistory: _bin.rentalHistory,
      state: _bin.state,
    );

    await binsBox.put(widget.hiveKey, updatedBin);

    if (mounted) {
      setState(() {
        _currentRental = updated;
        _secondsLeft = updated.secondsLeft();
      });
    }
    _timer?.cancel();
  }

  Future<void> _resumeRental() async {
    if (_currentRental == null || _currentRental!.state != RentalState.paused)
      return;

    final updated = _currentRental!.copyWith(
      startDate: DateTime.now(),
      remainingSeconds: null,
      state: RentalState.active,
    );

    await rentalsBox.put(_bin.currentRentalKey, updated);

    final updatedBin = _bin.copyWith(
      currentRentalKey: _bin.currentRentalKey,
      rentalHistory: _bin.rentalHistory,
      state: _bin.state,
    );

    await binsBox.put(widget.hiveKey, updatedBin);

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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('End Rental'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final ended = _currentRental!.copyWith(
      state: RentalState.completed,
      endedAt: DateTime.now(),
    );

    final rentalKey = _bin.currentRentalKey!;
    await rentalsBox.put(rentalKey, ended);

    // final history = List<int>.from(_bin.rentalHistory ?? [])..add(rentalKey);
    final updatedBin = _bin.copyWith(state: BinState.toBeReturned);

    await binsBox.put(widget.hiveKey, updatedBin);

    // print('Ended rental for bin ${_bin.id}, rental state: ${ended.state}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }); // pop with true to indicate success
  }

  Future<void> _completeRental() async {
    if (_currentRental == null) return;
    if (_currentRental!.state != RentalState.completed) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Complete Rental'),
        content: Text(
          'Complete rental for bin ${_bin.id}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Complete Rental'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    // final rentalKey = _bin.currentRentalKey!;

    // print('Before update: ${_bin.currentRentalKey}');

    final history = List<int>.from(_bin.rentalHistory ?? []);
    final updatedBin = BinItem(
      id: _bin.id,
      currentRentalKey: null,
      rentalHistory: history,
      state: BinState.free,
    );

    // print('After update: ${updatedBin.currentRentalKey}');

    await binsBox.put(widget.hiveKey, updatedBin);

    setState(() {
      _currentRental = null;
      _secondsLeft = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }); // pop with true to indicate success
  }

  Future<void> _createRentalDialog() async {
    final renterNameCtrl = TextEditingController();
    final renterPhoneCtrl = TextEditingController();
    final renterLocCtrl = TextEditingController();
    final daysCtrl = TextEditingController(text: '10');
    final hoursCtrl = TextEditingController(text: '0');
    final minutesCtrl = TextEditingController(text: '0');
    RentalState initialState = RentalState.active;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Create Rental'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: renterNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Renter Name (optional)',
                  ),
                ),
                TextFormField(
                  controller: renterPhoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Renter Phone (optional)',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: renterLocCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Renter Location (optional)',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rental Duration',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: daysCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Days',
                          hintText: '10',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final days = int.tryParse(value);
                          if (days == null || days < 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: hoursCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Hours',
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final hours = int.tryParse(value);
                          if (hours == null || hours < 0 || hours > 23) {
                            return '0-23';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: minutesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final minutes = int.tryParse(value);
                          if (minutes == null || minutes < 0 || minutes > 59) {
                            return '0-59';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RentalState>(
                  value: initialState,
                  items: const [
                    DropdownMenuItem(
                      value: RentalState.active,
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: RentalState.paused,
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      initialState = value;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Rental State'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? true) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final renterName = renterNameCtrl.text.trim();
    final renterPhone = renterPhoneCtrl.text.trim();
    final renterLoc = renterLocCtrl.text.trim();
    final days = int.parse(daysCtrl.text);
    final hours = int.parse(hoursCtrl.text);
    final minutes = int.parse(minutesCtrl.text);

    // Calculate total duration in seconds
    final totalSeconds = (days * 24 * 3600) + (hours * 3600) + (minutes * 60);

    final now = DateTime.now();
    final rental = RentalRecord(
      renterName: renterName,
      renterPhone: renterPhone,
      renterLoc: renterLoc,
      startDate: initialState == RentalState.active ? now : null,
      remainingSeconds: initialState == RentalState.paused
          ? totalSeconds
          : null,
      plannedSeconds: totalSeconds,
      state: initialState,
    );

    final rentalKey = await rentalsBox.add(rental);
    final history = List<int>.from(_bin.rentalHistory ?? [])..add(rentalKey);
    final updatedBin = _bin.copyWith(
      currentRentalKey: rentalKey,
      rentalHistory: history,
      state: BinState.active,
    );
    await binsBox.put(widget.hiveKey, updatedBin);

    // print('Created rental $rentalKey for bin ${_bin.id}');

    _loadData(); // reload data to reflect changes
  }
  // int _extraDays() {
  //     final now = DateTime.now();
  //     final extra = _bin.expiresAt.difference(now).inDays;
  //     return -extra;
  // }

  // Future<void> _editBin() async {
  //     final result = await Navigator.push<BinItem>(
  //         context,
  //         MaterialPageRoute(
  //             builder: (_) => BinCreationScreen(
  //                 bin: _bin,
  //                 binKey: widget.hiveKey,
  //             )
  //         )
  //     );

  //     if (result != null) {
  //         final updated = result.copyWith(
  //             currentRentalKey: _bin.currentRentalKey,
  //             rentalHistory: _bin.rentalHistory,
  //         );
  //         await binsBox.put(widget.hiveKey, updated);
  //         _loadData();
  //     }
  // }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRental = _currentRental != null && _bin.state != BinState.free;
    final rentalActive = _currentRental?.state == RentalState.active;
    final rentalPaused = _currentRental?.state == RentalState.paused;
    final expired = _currentRental?.isExpired ?? false;
    bool isCompleted =
        _currentRental?.state == RentalState.completed &&
        _bin.state == BinState.toBeReturned;

    final timerText = hasRental
        ? formatSeconds(_secondsLeft)
        : 'No active rental';

    final rentalHistory = _bin.rentalHistory ?? [];
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
        // actions: [
        //     IconButton(icon: const Icon(Icons.edit), onPressed: _editBin),
        //     // IconButton(icon: const Icon(Icons.delete), onPressed: _onDelete),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  switch (_bin.state) {
                    BinState.free => Icons.inventory_2,
                    BinState.active =>
                      expired
                          ? Icons.block
                          : (rentalActive ? Icons.timer : Icons.pause_circle),
                    BinState.toBeReturned => Icons.check,
                  },
                  color: switch (_bin.state) {
                    BinState.free => Colors.grey,
                    BinState.active =>
                      expired
                          ? Colors.red
                          : (rentalActive ? Colors.green : Colors.orange),
                    BinState.toBeReturned => Colors.yellow,
                  },
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(switch (_bin.state) {
                  BinState.free => 'Free',
                  BinState.active =>
                    expired ? 'Expired' : (rentalActive ? 'Active' : 'Paused'),
                  BinState.toBeReturned => 'Ready to be picked up',
                }, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'ID: ${_bin.id}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (!hasRental) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _createRentalDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Rental'),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Renter Name: ${_currentRental!.renterName.isNotEmpty ? _currentRental!.renterName : '—'}',
              ),
              const SizedBox(height: 8),
              Text(
                'Renter phone: ${_currentRental!.renterPhone.isNotEmpty ? _currentRental!.renterPhone : '—'}',
              ),
              const SizedBox(height: 8),
              Text(
                'Renter Location: ${_currentRental!.renterLoc.isNotEmpty ? _currentRental!.renterLoc : '—'}',
              ),
              const SizedBox(height: 6),
              Text(
                'Planned duration: ${(_currentRental!.plannedSeconds / 86400).round()} days',
              ),
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    Text(
                      expired ? 'Expired $timerText ago' : timerText,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: expired
                            ? Colors.red
                            : (rentalActive ? Colors.green : Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (rentalActive)
                          ElevatedButton.icon(
                            onPressed: _pauseRental,
                            icon: const Icon(Icons.pause),
                            label: const Text('Pause Rental'),
                          ),
                        if (rentalPaused)
                          ElevatedButton.icon(
                            onPressed: _resumeRental,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Resume Rental'),
                          ),
                        if (isCompleted)
                          ElevatedButton.icon(
                            onPressed: _completeRental,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Bin is free'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        const SizedBox(width: 12),
                        if (rentalActive && !isCompleted)
                          ElevatedButton.icon(
                            onPressed: _endRental,
                            icon: const Icon(Icons.check),
                            label: const Text('End Rental'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            RentalHistoryWidget(
              rentalHistory: rentalHistory,
              rentalsBox: rentalsBox,
              maxItems: 3,
            ),
          ],
        ),
      ),
    );
  }
}
