part of 'water_log.dart';

class WaterLogAdapter extends TypeAdapter<WaterLog> {
  @override
  final int typeId = 3;

  @override
  WaterLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterLog(
      amountMl: fields[0] as int,
      loggedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WaterLog obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.amountMl)
      ..writeByte(1)
      ..write(obj.loggedAt);
  }
}
