import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/main_screen.dart';
import 'models/bin_model.dart';
import 'models/rental_record.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(BinItemAdapter());
  Hive.registerAdapter(RentalStateAdapter());
  Hive.registerAdapter(RentalRecordAdapter());

  await Hive.openBox<BinItem>('bins');
  await Hive.openBox<RentalState>('rentalStates');
  await Hive.openBox<RentalRecord>('rentals');

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
        scaffoldBackgroundColor: const Color.fromARGB(255, 202, 197, 197),
      ),
      home: HomeScreen(),
    );
  }
}