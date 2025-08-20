import 'package:hive/hive.dart';

part 'workout.g.dart';

@HiveType(typeId: 1)
class Workout {
  Workout({
    required this.activity,
    required this.elapsed,
    required this.steps,
    required this.startedAt,
  });

  @HiveField(0)
  final String activity;

  @HiveField(1)
  final Duration elapsed;

  @HiveField(2)
  final int steps;

  @HiveField(3)
  final DateTime startedAt;
}
