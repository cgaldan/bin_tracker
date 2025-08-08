import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bin_tracker/models/bin_model.dart';
import 'package:bin_tracker/screens/bin_creation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<BinItem> box;
  List<BinItem> _bins = [];

  @override
  void initState() {
    super.initState();
    box = Hive.box<BinItem>('bins');
    _loadBins();
  }

  void _loadBins() {
    setState(() {
      _bins = box.values.toList();
    });
  }
  
  void _addBin(BinItem bin) {
    box.add(bin);
    _loadBins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bin Tracker'),
      ),
      body: _bins.isEmpty
          ? const Center(
              child: Text('No bins added yet.'),
            )
          : ListView.builder(
              itemCount: _bins.length,
              itemBuilder: (context, index) {
                final bin = _bins[index];
                final key = box.keyAt(index) as int;
                return ListTile(
                  leading: Icon(
                    bin.isExpired ? Icons.block : Icons.timer, 
                    color: bin.isExpired ? Colors.red : Colors.green,          
                  ),
                  title: Text(bin.id),
                  subtitle: Text(bin.isExpired
                      ? 'Expired on ${bin.expiresAt.toLocal()}'
                      : '${bin.daysLeft} day${bin.daysLeft == 1 ? '' : 's'} left'),
                  trailing: 
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final updatedBin = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BinCreationScreen(bin: bin),
                            ),
                          );

                          if (updatedBin != null && updatedBin is BinItem) {
                            box.putAt(key, updatedBin);
                            _loadBins();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:(context) => AlertDialog(
                              title: Text('Delete Bin?'),
                              content: Text('Are you sure you want to delete bin ${bin.id}?'),
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

                          if (confirm == true) {
                            box.delete(key);
                            _loadBins();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: ()  async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BinCreationScreen(),
            ),
          );

          if (result != null && result is BinItem) {
            _addBin(result);
          }
        },
      ),
    );
  }
}