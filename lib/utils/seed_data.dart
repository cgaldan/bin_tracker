import 'package:hive_flutter/hive_flutter.dart';
import '../models/bin_model.dart';
import '../models/rental_record.dart';

class SeedData {
  static const List<String> _binIdPrefixes = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  static const List<String> _sampleRenterNames = [
    'John Smith',
    'Sarah Johnson',
    'Mike Wilson',
    'Lisa Brown',
    'David Lee',
    'Emma Davis',
    'Chris Taylor',
    'Anna Martinez',
    'Tom Anderson',
    'Maria Garcia',
    'Alex Thompson',
    'Sophie White',
    'James Miller',
    'Olivia Clark',
    'Daniel Rodriguez',
    'Emily Lewis',
    'Ryan Walker',
    'Grace Hall',
    'Kevin Young',
    'Chloe King',
  ];

  static const List<String> _sampleLocations = [
    'Downtown',
    'North Side',
    'South Side',
    'East End',
    'West Side',
    'Central Plaza',
    'Business District',
    'Residential Area',
    'Industrial Zone',
    'Shopping Center',
    'University Area',
    'Airport District',
    'Harbor View',
    'Mountain View',
    'Riverside',
  ];

  static const List<String> _samplePhones = [
    '+1-555-0101',
    '+1-555-0102',
    '+1-555-0103',
    '+1-555-0104',
    '+1-555-0105',
    '+1-555-0106',
    '+1-555-0107',
    '+1-555-0108',
    '+1-555-0109',
    '+1-555-0110',
    '+1-555-0111',
    '+1-555-0112',
    '+1-555-0113',
    '+1-555-0114',
    '+1-555-0115',
    '+1-555-0116',
  ];

  /// Generate a specified number of bin units
  static List<BinItem> generateBins(
    int count, {
    String? prefix,
    int startNumber = 1,
    bool includeRandomRentals = false,
    double rentalProbability = 0.3, // 30% chance of having a rental
  }) {
    final bins = <BinItem>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < count; i++) {
      final binNumber = startNumber + i;
      final binId = prefix != null
          ? '$prefix${binNumber.toString().padLeft(3, '0')}'
          : '${_binIdPrefixes[i % _binIdPrefixes.length]}${binNumber.toString().padLeft(3, '0')}';

      // Determine bin state
      BinState state = BinState.free;
      if (includeRandomRentals &&
          (random + i) % 100 < (rentalProbability * 100)) {
        state = BinState.active;
      }

      bins.add(
        BinItem(
          id: binId,
          state: state,
          currentRentalKey: null, // Will be set later if needed
          rentalHistory: [],
        ),
      );
    }

    return bins;
  }

  /// Generate rental records for bins that need them
  static List<RentalRecord> generateRentalsForBins(
    List<BinItem> bins, {
    double activeProbability = 0.2,
    double pausedProbability = 0.1,
  }) {
    final rentals = <RentalRecord>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < bins.length; i++) {
      final bin = bins[i];
      if (bin.state != BinState.active) continue;

      final rand = (random + i) % 100;
      RentalState rentalState;

      if (rand < (activeProbability * 100)) {
        rentalState = RentalState.active;
      } else if (rand < ((activeProbability + pausedProbability) * 100)) {
        rentalState = RentalState.paused;
      } else {
        continue; // No rental for this bin
      }

      final renterIndex = (random + i) % _sampleRenterNames.length;
      final locationIndex = (random + i) % _sampleLocations.length;
      final phoneIndex = (random + i) % _samplePhones.length;

      // Generate random duration (1-30 days)
      final days = 1 + ((random + i) % 30);
      final hours = (random + i) % 24;
      final minutes = (random + i) % 60;
      final plannedSeconds =
          (days * 24 * 3600) + (hours * 3600) + (minutes * 60);

      final rental = RentalRecord(
        renterName: _sampleRenterNames[renterIndex],
        renterPhone: _samplePhones[phoneIndex],
        renterLoc: _sampleLocations[locationIndex],
        plannedSeconds: plannedSeconds,
        state: rentalState,
        startDate: rentalState == RentalState.active
            ? DateTime.now().subtract(Duration(days: (random + i) % 10))
            : null,
        remainingSeconds: rentalState == RentalState.paused
            ? plannedSeconds - ((random + i) % plannedSeconds)
            : null,
      );

      rentals.add(rental);
    }

    return rentals;
  }

  /// Seed the database with sample data
  static Future<Map<String, int>> seedDatabase({
    required Box<BinItem> binsBox,
    required Box<RentalRecord> rentalsBox,
    int binCount = 50,
    String? binPrefix,
    int startNumber = 1,
    bool includeRentals = true,
    double rentalProbability = 0.3,
  }) async {
    // Clear existing data if requested
    await binsBox.clear();
    await rentalsBox.clear();

    // Generate bins
    final bins = generateBins(
      binCount,
      prefix: binPrefix,
      startNumber: startNumber,
      includeRandomRentals: includeRentals,
      rentalProbability: rentalProbability,
    );

    // Generate rentals if needed
    List<RentalRecord> rentals = [];
    if (includeRentals) {
      rentals = generateRentalsForBins(bins);
    }

    // Add bins to database
    final binKeys = <int>[];
    for (final bin in bins) {
      final key = await binsBox.add(bin);
      binKeys.add(key);
    }

    // Add rentals and link them to bins
    final rentalKeys = <int>[];
    int rentalIndex = 0;

    for (int i = 0; i < bins.length; i++) {
      final bin = bins[i];
      if (bin.state == BinState.active && rentalIndex < rentals.length) {
        final rental = rentals[rentalIndex];
        final rentalKey = await rentalsBox.add(rental);
        rentalKeys.add(rentalKey);

        // Update bin with rental key
        final updatedBin = bin.copyWith(currentRentalKey: rentalKey);
        await binsBox.put(binKeys[i], updatedBin);

        rentalIndex++;
      }
    }

    return {'bins': binKeys.length, 'rentals': rentalKeys.length};
  }

  /// Generate sample data for specific scenarios
  static Future<Map<String, int>> seedTestScenarios({
    required Box<BinItem> binsBox,
    required Box<RentalRecord> rentalsBox,
    String scenario = 'mixed',
  }) async {
    switch (scenario.toLowerCase()) {
      case 'empty':
        return await seedDatabase(
          binsBox: binsBox,
          rentalsBox: rentalsBox,
          binCount: 0,
          includeRentals: false,
        );

      case 'free_only':
        return await seedDatabase(
          binsBox: binsBox,
          rentalsBox: rentalsBox,
          binCount: 20,
          includeRentals: false,
        );

      case 'active_rentals':
        return await seedDatabase(
          binsBox: binsBox,
          rentalsBox: rentalsBox,
          binCount: 30,
          includeRentals: true,
          rentalProbability: 0.8,
        );

      case 'mixed':
        return await seedDatabase(
          binsBox: binsBox,
          rentalsBox: rentalsBox,
          binCount: 50,
          includeRentals: true,
          rentalProbability: 0.4,
        );

      case 'large':
        return await seedDatabase(
          binsBox: binsBox,
          rentalsBox: rentalsBox,
          binCount: 200,
          includeRentals: true,
          rentalProbability: 0.3,
        );

      case 'warehouse':
        return await seedDatabase(
          binsBox: binsBox,
          rentalsBox: rentalsBox,
          binCount: 100,
          binPrefix: 'WH',
          startNumber: 1,
          includeRentals: true,
          rentalProbability: 0.2,
        );

      default:
        throw ArgumentError('Unknown scenario: $scenario');
    }
  }

  /// Clear all data from the database
  static Future<void> clearAllData({
    required Box<BinItem> binsBox,
    required Box<RentalRecord> rentalsBox,
  }) async {
    await binsBox.clear();
    await rentalsBox.clear();
  }

  /// Get database statistics
  static Map<String, dynamic> getDatabaseStats({
    required Box<BinItem> binsBox,
    required Box<RentalRecord> rentalsBox,
  }) {
    final bins = binsBox.values.toList();
    final rentals = rentalsBox.values.toList();

    final freeBins = bins.where((b) => b.state == BinState.free).length;
    final activeBins = bins.where((b) => b.state == BinState.active).length;
    final toBeReturnedBins = bins
        .where((b) => b.state == BinState.toBeReturned)
        .length;

    final activeRentals = rentals
        .where((r) => r.state == RentalState.active)
        .length;
    final pausedRentals = rentals
        .where((r) => r.state == RentalState.paused)
        .length;
    final completedRentals = rentals
        .where((r) => r.state == RentalState.completed)
        .length;

    return {
      'totalBins': bins.length,
      'freeBins': freeBins,
      'activeBins': activeBins,
      'toBeReturnedBins': toBeReturnedBins,
      'totalRentals': rentals.length,
      'activeRentals': activeRentals,
      'pausedRentals': pausedRentals,
      'completedRentals': completedRentals,
    };
  }

  /// Bulk operations for managing many bins
  static Future<Map<String, int>> bulkDeleteBins({
    required Box<BinItem> binsBox,
    required Box<RentalRecord> rentalsBox,
    List<int>? binKeys,
    String? prefix,
    BinState? state,
  }) async {
    List<int> keysToDelete = [];

    if (binKeys != null) {
      keysToDelete = binKeys;
    } else if (prefix != null) {
      // Delete bins with specific prefix
      for (final key in binsBox.keys.cast<int>()) {
        final bin = binsBox.get(key);
        if (bin != null && bin.id.startsWith(prefix)) {
          keysToDelete.add(key);
        }
      }
    } else if (state != null) {
      // Delete bins with specific state
      for (final key in binsBox.keys.cast<int>()) {
        final bin = binsBox.get(key);
        if (bin != null && bin.state == state) {
          keysToDelete.add(key);
        }
      }
    } else {
      throw ArgumentError('Must provide binKeys, prefix, or state');
    }

    int deletedBins = 0;
    int deletedRentals = 0;

    for (final key in keysToDelete) {
      final bin = binsBox.get(key);
      if (bin != null) {
        // Delete associated rental
        if (bin.currentRentalKey != null) {
          await rentalsBox.delete(bin.currentRentalKey);
          deletedRentals++;
        }

        // Delete bin
        await binsBox.delete(key);
        deletedBins++;
      }
    }

    return {'deletedBins': deletedBins, 'deletedRentals': deletedRentals};
  }

  /// Bulk update bin states
  static Future<int> bulkUpdateBinStates({
    required Box<BinItem> binsBox,
    List<int>? binKeys,
    String? prefix,
    BinState? fromState,
    required BinState toState,
  }) async {
    List<int> keysToUpdate = [];

    if (binKeys != null) {
      keysToUpdate = binKeys;
    } else if (prefix != null) {
      // Update bins with specific prefix
      for (final key in binsBox.keys.cast<int>()) {
        final bin = binsBox.get(key);
        if (bin != null && bin.id.startsWith(prefix)) {
          if (fromState == null || bin.state == fromState) {
            keysToUpdate.add(key);
          }
        }
      }
    } else if (fromState != null) {
      // Update bins with specific state
      for (final key in binsBox.keys.cast<int>()) {
        final bin = binsBox.get(key);
        if (bin != null && bin.state == fromState) {
          keysToUpdate.add(key);
        }
      }
    } else {
      throw ArgumentError('Must provide binKeys, prefix, or fromState');
    }

    int updatedBins = 0;

    for (final key in keysToUpdate) {
      final bin = binsBox.get(key);
      if (bin != null) {
        final updatedBin = bin.copyWith(state: toState);
        await binsBox.put(key, updatedBin);
        updatedBins++;
      }
    }

    return updatedBins;
  }

  /// Export data to JSON format
  static Map<String, dynamic> exportData({
    required Box<BinItem> binsBox,
    required Box<RentalRecord> rentalsBox,
  }) {
    final bins = <Map<String, dynamic>>[];
    final rentals = <Map<String, dynamic>>[];

    // Export bins
    for (final key in binsBox.keys.cast<int>()) {
      final bin = binsBox.get(key);
      if (bin != null) {
        bins.add({
          'key': key,
          'id': bin.id,
          'state': bin.state.toString().split('.').last,
          'currentRentalKey': bin.currentRentalKey,
          'rentalHistory': bin.rentalHistory,
        });
      }
    }

    // Export rentals
    for (final key in rentalsBox.keys.cast<int>()) {
      final rental = rentalsBox.get(key);
      if (rental != null) {
        rentals.add({
          'key': key,
          'renterName': rental.renterName,
          'renterPhone': rental.renterPhone,
          'renterLoc': rental.renterLoc,
          'startDate': rental.startDate?.toIso8601String(),
          'remainingSeconds': rental.remainingSeconds,
          'plannedSeconds': rental.plannedSeconds,
          'state': rental.state.toString().split('.').last,
          'endedAt': rental.endedAt?.toIso8601String(),
          'pickedAt': rental.pickedAt?.toIso8601String(),
        });
      }
    }

    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'bins': bins,
      'rentals': rentals,
    };
  }
}
