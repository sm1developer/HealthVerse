import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import '../models/water_log.dart';

class WaterStore {
  WaterStore._();
  static final WaterStore instance = WaterStore._();

  static const String _boxName = 'water_logs_box';
  Box<WaterLog>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WaterLogAdapter());
    _box = await Hive.openBox<WaterLog>(_boxName);
  }

  List<WaterLog> get items =>
      List.unmodifiable(_box?.values.toList().reversed ?? const <WaterLog>[]);

  ValueListenable<Box<WaterLog>>? get listenable => _box?.listenable();

  Future<void> add(WaterLog log) async {
    await _box?.add(log);
  }

  Future<bool> delete(WaterLog log) async {
    if (_box == null) return false;
    final Box<WaterLog> box = _box!;
    for (final key in box.keys) {
      final value = box.get(key);
      if (identical(value, log) || value == log) {
        await box.delete(key);
        return true;
      }
    }
    return false;
  }
}
