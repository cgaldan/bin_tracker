import 'package:bin_tracker/models/rental_record.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bin_tracker/models/bin_model.dart';
import 'package:bin_tracker/screens/bin_creation_screen.dart';
import 'bin_detail_screen.dart';
import '../utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<BinItem> binsBox;
  late Box<RentalRecord> rentalsBox;
  BinFilter selectedFilter = BinFilter.all;

  @override
  void initState() {
    super.initState();
    binsBox = Hive.box<BinItem>('bins');
    rentalsBox = Hive.box<RentalRecord>('rentals');
  }

  bool _matchesFilter(BinItem bin) {
    final rental = bin.currentRentalKey != null
        ? rentalsBox.get(bin.currentRentalKey)
        : null;

    switch (selectedFilter) {
      case BinFilter.all:
        return true;
      case BinFilter.free:
        return rental == null;
      case BinFilter.active:
        return rental != null &&
            rental.state == RentalState.active &&
            !rental.isExpired;
      case BinFilter.expired:
        return rental != null &&
            rental.state == RentalState.active &&
            rental.isExpired;
      case BinFilter.paused:
        return rental != null && rental.state == RentalState.paused;
    }
  }

  Future<void> _deleteBin(int binKey, BinItem bin) async {
    final hasRental = bin.currentRentalKey != null;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bin?'),
        content: hasRental
            ? Text(
                'This bin is currently rented. Are you sure you want to delete it?',
              )
            : Text('Are you sure you want to delete bin ${bin.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (hasRental) {
      await rentalsBox.delete(bin.currentRentalKey);
    }

    await binsBox.delete(binKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bin Tracker'),
        actions: [
          PopupMenuButton<BinFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (BinFilter filter) {
              setState(() {
                selectedFilter = filter;
              });
            },
            itemBuilder: (BuildContext context) =>
                BinFilter.values.map((BinFilter filter) {
                  return PopupMenuItem<BinFilter>(
                    value: filter,
                    child: Row(
                      children: [
                        if (selectedFilter == filter)
                          const Icon(Icons.check, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(getFilterDisplayName(filter)),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: binsBox.listenable(),
        builder: (context, Box<BinItem> box, _) {
          final keys = box.keys.cast<int>().toList();
          if (keys.isEmpty) {
            return const Center(child: Text('No bins added yet.'));
          }

          // Filter bins based on selected filter
          final filteredKeys = keys.where((binKey) {
            final bin = box.get(binKey)!;
            return _matchesFilter(bin);
          }).toList();

          if (filteredKeys.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_alt_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No bins match the "${getFilterDisplayName(selectedFilter)}" filter',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: filteredKeys.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final binKey = filteredKeys[index];
              final bin = box.get(binKey)!;

              final rental = bin.currentRentalKey != null
                  ? rentalsBox.get(bin.currentRentalKey)
                  : null;

              String subtitle;
              IconData leadingIcon;
              Color iconColor;

              if (rental == null) {
                subtitle = 'No current rental';
                leadingIcon = Icons.inventory_2;
                iconColor = Colors.grey;
              } else if (rental.state == RentalState.completed) {
                subtitle =
                    'Last renter: ${rental.renterName} (waiting to be picked up)';
                leadingIcon = Icons.check_circle;
                iconColor = Colors.blueGrey;
              } else {
                final seconds = rental.secondsLeft();
                final timeText = formatSeconds(seconds);
                final expired = rental.isExpired;

                subtitle = '${rental.renterName} · $timeText';

                if (expired) {
                  leadingIcon = Icons.block;
                  iconColor = Colors.red;
                } else if (rental.state == RentalState.active) {
                  leadingIcon = Icons.timer;
                  iconColor = Colors.green;
                } else if (rental.state == RentalState.completed) {
                  leadingIcon = Icons.check_circle;
                  iconColor = Colors.blue;
                } else {
                  leadingIcon = Icons.pause_circle;
                  iconColor = Colors.orange;
                }
              }

              return ListTile(
                leading: Icon(leadingIcon, color: iconColor),
                title: Text(bin.id),
                subtitle: Text(subtitle),
                onTap: () async {
                  final shouldRefresh = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BinDetailScreen(bin: bin, hiveKey: binKey),
                    ),
                  );

                  if (shouldRefresh == true) {
                    setState(() {});
                  }
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IconButton(
                    //   icon: Icon(Icons.edit),
                    //   onPressed: () async {
                    //     final result = await Navigator.push<BinItem>(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => BinCreationScreen(bin: bin, binKey: binKey),
                    //       ),
                    //     );

                    //     if (result != null) {
                    //       final updated = result.copyWith(
                    //         currentRentalKey: bin.currentRentalKey,
                    //         rentalHistory: bin.rentalHistory,
                    //       );
                    //       await binsBox.put(binKey, updated);
                    //     }
                    //   },
                    // ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteBin(binKey, bin),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => BinCreationScreen()));

          if (result != null && result is BinItem) {
            await binsBox.add(result);
            setState(() {});
          }
        },
      ),
    );
  }
}
