import 'package:hive/hive.dart';

part 'rental_record.g.dart';

@HiveType(typeId: 1)
enum RentalState {
  @HiveField(0)
  active,

  @HiveField(1)
  inactive,
  
  @HiveField(2)
  completed,
}

@HiveType(typeId: 2)
class RentalRecord {
  @HiveField(0)
  final String renterName;

  @HiveField(1)
  final String renterPhone;

  @HiveField(2)
  final DateTime? startDate;

  @HiveField(3)
  final int? remainingSeconds;

  @HiveField(4)
  final int plannedSeconds;

  @HiveField(5)
  final RentalState state;

  @HiveField(6)
  final DateTime? endedAt;
  
  RentalRecord({
    required this.renterName,
    required this.renterPhone,
    this.startDate,
    this.remainingSeconds,
    this.plannedSeconds = 10 * 24 * 3600, // Default to 10 days in seconds
    this.state = RentalState.inactive,
    this.endedAt,
  });

  RentalRecord copyWith({
    String? renterName,
    String? renterPhone,
    DateTime? startDate,
    int? remainingSeconds,
    int? plannedSeconds,
    RentalState? state,
    DateTime? endedAt,
  }) {
    return RentalRecord(
      renterName: renterName ?? this.renterName,
      renterPhone: renterPhone ?? this.renterPhone,
      startDate: startDate ?? this.startDate,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      state: state ?? this.state,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  int secondsLeft() {
    if (state == RentalState.inactive) {
      return remainingSeconds ?? plannedSeconds;
    }

    if (remainingSeconds != null) {
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
