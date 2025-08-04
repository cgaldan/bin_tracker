class BinItem {
  final String id;
  final String location;
  final String contactName;
  final String contactPhone;
  final DateTime startDate;

  BinItem({
    required this.id,
    required this.location,
    required this.contactName,
    required this.contactPhone,
    required this.startDate,
  });

  DateTime get expiresAt => startDate.add(const Duration(seconds: 30));

  int get daysLeft {
    final now = DateTime.now();
    return expiresAt.difference(now).inDays;
  }

  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(expiresAt);
  }
}