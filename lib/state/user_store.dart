import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

class UserStore {
  UserStore._();
  static final UserStore instance = UserStore._();

  static const String _boxName = 'user_profile_box';
  static const String _key = 'profile';
  Box<UserProfile>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserProfileAdapter());
    _box = await Hive.openBox<UserProfile>(_boxName);
  }

  UserProfile? get profile => _box?.get(_key);

  Future<void> save(UserProfile profile) async {
    await _box?.put(_key, profile);
  }
}
