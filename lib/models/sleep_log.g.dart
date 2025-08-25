// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_log.dart';

class SleepLogAdapter extends TypeAdapter<SleepLog> {
  @override
  final int typeId = 5;

  @override
  SleepLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepLog(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime,
      duration: Duration(microseconds: fields[2] as int),
    );
  }

  @override
  void write(BinaryWriter writer, SleepLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.duration.inMicroseconds);
  }
}
