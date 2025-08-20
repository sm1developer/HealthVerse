// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 1;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      activity: fields[0] as String,
      elapsed: Duration(microseconds: fields[1] as int),
      steps: fields[2] as int,
      startedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.activity)
      ..writeByte(1)
      ..write(obj.elapsed.inMicroseconds)
      ..writeByte(2)
      ..write(obj.steps)
      ..writeByte(3)
      ..write(obj.startedAt);
  }
}
