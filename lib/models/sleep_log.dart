import 'package:hive/hive.dart';

part 'sleep_log.g.dart';

@HiveType(typeId: 5)
class SleepLog {
  SleepLog({
    required this.startTime,
    required this.endTime,
    required this.duration,
  });

  @HiveField(0)
  final DateTime startTime;

  @HiveField(1)
  final DateTime endTime;

  @HiveField(2)
  final Duration duration;
}
