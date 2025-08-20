import 'package:hive/hive.dart';

part 'water_log.g.dart';

@HiveType(typeId: 3)
class WaterLog {
  WaterLog({required this.amountMl, required this.loggedAt});

  @HiveField(0)
  final int amountMl;

  @HiveField(1)
  final DateTime loggedAt;
}


