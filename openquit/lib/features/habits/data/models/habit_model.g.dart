// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 3;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..iconName = fields[2] as String
      ..description = fields[3] as String?
      ..frequencyIndex = fields[4] as int
      ..weekDays = (fields[5] as List).cast<int>()
      ..startDate = fields[6] as DateTime
      ..completedDates = (fields[7] as List).cast<DateTime>()
      ..colorHex = fields[8] as String;
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.frequencyIndex)
      ..writeByte(5)
      ..write(obj.weekDays)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.completedDates)
      ..writeByte(8)
      ..write(obj.colorHex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
