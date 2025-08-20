// GENERATED CODE - MANUALLY WRITTEN FOR NOW

part of 'food_log.dart';

class FoodLogAdapter extends TypeAdapter<FoodLog> {
  @override
  final int typeId = 4;

  @override
  FoodLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodLog(
      name: fields[0] as String,
      unit: fields[1] as String,
      quantity: (fields[2] as num).toDouble(),
      loggedAt: fields[3] as DateTime,
      details: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.unit)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.loggedAt)
      ..writeByte(4)
      ..write(obj.details);
  }
}
