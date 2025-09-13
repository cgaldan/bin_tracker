import 'package:hive/hive.dart';

part 'rental_record.g.dart';

@HiveType(typeId: 2)
enum RentalState {
  @HiveField(0)
  active,

  @HiveField(1)
  paused,

  @HiveField(2)
  completed,
}

@HiveType(typeId: 3)
class RentalRecord {
  @HiveField(0)
  final String renterName;

  @HiveField(1)
  final String renterPhone;

  @HiveField(2)
  final String renterLoc;

  @HiveField(3)
  final DateTime? startDate;

  @HiveField(4)
  final int? remainingSeconds;

  @HiveField(5)
  final int plannedSeconds;

  @HiveField(6)
  final RentalState state;

  @HiveField(7)
  final DateTime? endedAt;

  @HiveField(8)
  final DateTime? pickedAt;

  RentalRecord({
    required this.renterName,
    required this.renterPhone,
    required this.renterLoc,
    this.startDate,
    this.remainingSeconds,
    this.plannedSeconds = 10 * 24 * 3600, // Default to 10 days in seconds
    this.state = RentalState.active,
    this.endedAt,
    this.pickedAt,
  });

  RentalRecord copyWith({
    String? renterName,
    String? renterPhone,
    String? renterLoc,
    DateTime? startDate,
    int? remainingSeconds,
    int? plannedSeconds,
    RentalState? state,
    DateTime? endedAt,
    DateTime? pickedAt,
  }) {
    return RentalRecord(
      renterName: renterName ?? this.renterName,
      renterPhone: renterPhone ?? this.renterPhone,
      renterLoc: renterLoc ?? this.renterLoc,
      startDate: startDate ?? this.startDate,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      state: state ?? this.state,
      endedAt: endedAt ?? this.endedAt,
      pickedAt: pickedAt ?? this.pickedAt,
    );
  }

  int secondsLeft() {
    if (state == RentalState.paused && remainingSeconds != null) {
      return remainingSeconds!;
    }

    if (startDate == null) {
      return plannedSeconds;
    }

    final expiresAt = startDate!.add(Duration(seconds: plannedSeconds));
    return expiresAt.difference(DateTime.now()).inSeconds;
  }

  bool get isExpired => (state == RentalState.active) && secondsLeft() <= 0;

  DateTime? get expiresAt {
    if (startDate == null) return null;
    return startDate!.add(Duration(seconds: plannedSeconds));
  }
}
