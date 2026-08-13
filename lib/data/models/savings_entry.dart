import 'package:hive/hive.dart';

part 'savings_entry.g.dart';

@HiveType(typeId: 2)
class SavingsEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String wishlistId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime addedAt;

  SavingsEntry({
    required this.id,
    required this.wishlistId,
    required this.amount,
    required this.addedAt,
  });

  String get formattedDate {
    return '${addedAt.day}/${addedAt.month}/${addedAt.year}';
  }

  String get formattedTime {
    final hour = addedAt.hour.toString().padLeft(2, '0');
    final minute = addedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}