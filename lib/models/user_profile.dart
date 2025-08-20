import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile {
  UserProfile({
    required this.name,
    required this.gender,
    required this.birthday,
    required this.weightKg,
    required this.heightCm,
    this.photoPath,
  });

  @HiveField(0)
  final String name;
  @HiveField(1)
  final String gender; // 'Male' | 'Female' | 'Other'
  @HiveField(2)
  final DateTime birthday;
  @HiveField(3)
  final double weightKg;
  @HiveField(4)
  final double heightCm;
  @HiveField(5)
  final String? photoPath; // local file path
}
