import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/bin_model.dart';
import 'bin_creation_screen.dart';

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
    late Box<BinItem> binBox;
    late BinItem _bin;
    Timer? _timer;
    Duration _remaining = Duration.zero;

    @override
    void initState() {
        super.initState();
        binBox = Hive.box<BinItem>('bins');
        _bin = widget.bin;
        _updateRemainingTime();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
            _updateRemainingTime();
        });
    }

    void _updateRemainingTime() {
        final now = DateTime.now();
        final rem = _bin.expiresAt.difference(now);
        setState(() {
            _remaining = rem;
        });
    }

    String _formatDuration(Duration duration) {
        final isNegative = duration.isNegative;
        final dur = duration.abs();
        final hours = dur.inHours.remainder(100000).toString().padLeft(2, '0');
        final minutes = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
        final seconds = dur.inSeconds.remainder(60).toString().padLeft(2, '0');
        return '${isNegative ? '-' : ''}$hours:$minutes:$seconds';
    }

    Future<void> _onEdit() async {
        final updated = await Navigator.push<BinItem>(
            context,
            MaterialPageRoute(
                builder: (_) => BinCreationScreen(
                    bin: _bin,
                )
            )
        );

        if (updated != null) {
            await binBox.put(widget.hiveKey, updated);
            setState(() {
                _bin = updated;
            });
            _updateRemainingTime();
        }
    }

    Future<void> _onDelete() async {
        final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
                title: const Text('Delete Bin'),
                content: Text('Delete bin ${_bin.id}? This cannot be undone.'),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(c).pop(false),
                        child: const Text('Cancel')
                    ),
                    TextButton(
                        onPressed: () => Navigator.of(c).pop(true),
                        child: const Text('Delete')
                    )
                ],
            )
        );

        if (ok == true) {
            await binBox.delete(widget.hiveKey);
            if (mounted) {
                Navigator.of(context).pop(true);
            }
        }
    }

    @override
    void dispose() {
        _timer?.cancel();
        super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
        final expired = _remaining.isNegative;
        final statusText = expired 
            ? 'Expired ${_formatDuration(_remaining)} ago'
            : '${_formatDuration(_remaining)} left';

        return Scaffold(
            appBar: AppBar(
                title: Text('Bin ${_bin.id}'),
                actions: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: _onEdit),
                    IconButton(icon: const Icon(Icons.delete), onPressed: _onDelete),
                ],
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(children: [
                            Icon(expired ? Icons.block : Icons.timer, color: expired ? Colors.red : Colors.green),
                            const SizedBox(width: 8),
                            Text(expired ? 'Expired' : 'Active',
                                style: Theme.of(context).textTheme.titleMedium),
                        ]),
                        const SizedBox(height: 16),

                        Text('ID: ${_bin.id}', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Location: ${_bin.location}'),
                        const SizedBox(height: 8),
                        Text('Contact: ${_bin.contactName} (${_bin.contactPhone})'),
                        const SizedBox(height: 8),
                        Text('Placed: ${_bin.startDate.toLocal()}'),
                        const SizedBox(height: 8),
                        Text('Expires: ${_bin.expiresAt.toLocal()}'),
                        const SizedBox(height: 24),

                        Center(
                            child: Column(
                                children: [
                                    Text(statusText,
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: expired ? Colors.red : Colors.green,
                                        )),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Edit Bin'),
                                        onPressed: _onEdit,
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Delete Bin'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                        ),
                                        onPressed: _onDelete,
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}