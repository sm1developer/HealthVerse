import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import '../models/workout.dart';

class WorkoutStore {
  WorkoutStore._();
  static final WorkoutStore instance = WorkoutStore._();

  static const String _boxName = 'workouts_box';
  Box<Workout>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WorkoutAdapter());
    _box = await Hive.openBox<Workout>(_boxName);
  }

  List<Workout> get items =>
      List.unmodifiable(_box?.values.toList().reversed ?? const <Workout>[]);

  ValueListenable<Box<Workout>>? get listenable => _box?.listenable();

  void add(Workout workout) {
    _box?.add(workout);
  }
}
