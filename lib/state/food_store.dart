import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import '../models/food_log.dart';

class FoodStore {
  FoodStore._();
  static final FoodStore instance = FoodStore._();

  static const String _boxName = 'food_logs_box';
  Box<FoodLog>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FoodLogAdapter());
    _box = await Hive.openBox<FoodLog>(_boxName);
  }

  List<FoodLog> get items =>
      List.unmodifiable(_box?.values.toList().reversed ?? const <FoodLog>[]);

  ValueListenable<Box<FoodLog>>? get listenable => _box?.listenable();

  Future<void> add(FoodLog log) async {
    await _box?.add(log);
  }
}
