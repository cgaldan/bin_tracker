import 'package:hive/hive.dart';

part 'bin_model.g.dart';

@HiveType(typeId: 0)
class BinItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String location;
  
  @HiveField(2)
  final String contactName;
  
  @HiveField(3)
  final String contactPhone;
  
  @HiveField(4)
  final DateTime startDate;

  @HiveField(5)
  final DateTime endDate;

  BinItem({
    required this.id,
    required this.location,
    required this.contactName,
    required this.contactPhone,
    required this.startDate,
    required this.endDate,
  });

  DateTime get expiresAt => startDate.add(const Duration(hours: 24));

  int get daysLeft {
    final now = DateTime.now();
    return expiresAt.difference(now).inDays;
  }

  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(expiresAt);
  }
}