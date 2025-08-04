import 'package:flutter/material.dart';
import 'screens/bin_creation_screen.dart';
import 'models/bin_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bin Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 126, 14, 179)),
        scaffoldBackgroundColor: const Color.fromARGB(255, 221, 217, 217),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<BinItem> _bins = [];

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
                return ListTile(
                  title: Text(bin.id),
                  subtitle: Text(bin.isExpired
                      ? 'Expired on ${bin.expiresAt.toLocal()}'
                      : '${bin.daysLeft} day${bin.daysLeft == 1 ? '' : 's'} left'),
                  trailing: Icon(bin.isExpired ? Icons.block : Icons.timer, color: bin.isExpired ? Colors.red : Colors.green),
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

          if (result != null) {
            setState(() {
              _bins.add(result as BinItem);
            });
          }
        },
      ),
    );
  }
}