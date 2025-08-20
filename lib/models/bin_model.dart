import 'package:hive/hive.dart';

part 'bin_model.g.dart';

@HiveType(typeId: 0)
class BinItem {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final int? currentRentalKey;
  
  @HiveField(2)
  final List<int>? rentalHistory;

  BinItem({
    required this.id,
    this.currentRentalKey,
    this.rentalHistory,
  });

  BinItem copyWith({
    String? id,
    int? currentRentalKey,
    List<int>? rentalHistory,
  }) {
    return BinItem(
      id: id ?? this.id,
      currentRentalKey: currentRentalKey ?? this.currentRentalKey,
      rentalHistory: rentalHistory ?? this.rentalHistory,
    );
  }
}