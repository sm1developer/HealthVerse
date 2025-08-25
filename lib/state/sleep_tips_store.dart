import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SleepTipsStore {
  SleepTipsStore._();
  static final SleepTipsStore instance = SleepTipsStore._();

  static const String _boxName = 'sleep_tips_box';
  static const String _key = 'tips';
  Box<String>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  String get tips => _box?.get(_key) ?? _defaultTips;

  Future<void> save(String value) async {
    await _box?.put(_key, value);
  }
}

const String _defaultTips =
    '• Aim for 7-9 hours of sleep\n• Keep your room cool and dark\n• Avoid screens before bedtime\n• Maintain a consistent sleep schedule';
