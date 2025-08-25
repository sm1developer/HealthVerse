import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import '../models/sleep_log.dart';

class SleepStore {
  SleepStore._();
  static final SleepStore instance = SleepStore._();

  static const String _boxName = 'sleep_logs_box';
  Box<SleepLog>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SleepLogAdapter());
    _box = await Hive.openBox<SleepLog>(_boxName);
  }

  List<SleepLog> get items =>
      List.unmodifiable(_box?.values.toList().reversed ?? const <SleepLog>[]);

  ValueListenable<Box<SleepLog>>? get listenable => _box?.listenable();

  Future<void> add(SleepLog log) async {
    await _box?.add(log);
  }

  Future<bool> delete(SleepLog log) async {
    if (_box == null) return false;
    final Box<SleepLog> box = _box!;
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
