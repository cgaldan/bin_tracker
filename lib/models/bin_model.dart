import 'package:hive/hive.dart';

part 'bin_model.g.dart';

@HiveType(typeId: 0)
enum BinState {
  @HiveField(0)
  free,

  @HiveField(1)
  active,

  @HiveField(2)
  toBeReturned,
}

@HiveType(typeId: 1)
class BinItem {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final int? currentRentalKey;
  
  @HiveField(2)
  final List<int>? rentalHistory;

  @HiveField(3)
  final BinState state;

  BinItem({
    required this.id,
    this.currentRentalKey,
    this.rentalHistory,
    this.state = BinState.free,
  });

  BinItem copyWith({
    String? id,
    int? currentRentalKey,
    List<int>? rentalHistory,
    BinState? state,
  }) {
    return BinItem(
      id: id ?? this.id,
      currentRentalKey: currentRentalKey ?? this.currentRentalKey,
      rentalHistory: rentalHistory ?? this.rentalHistory,
      state: state ?? this.state,
    );
  }
}