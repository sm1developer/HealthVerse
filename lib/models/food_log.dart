import 'package:hive/hive.dart';

part 'food_log.g.dart';

@HiveType(typeId: 4)
class FoodLog {
  FoodLog({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.loggedAt,
    this.details,
  });

  @HiveField(0)
  final String name;

  @HiveField(1)
  final String unit;

  @HiveField(2)
  final double quantity;

  @HiveField(3)
  final DateTime loggedAt;

  // Optional multi-item details (newline-separated)
  @HiveField(4)
  final String? details;
}
