// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addiction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddictionModelAdapter extends TypeAdapter<AddictionModel> {
  @override
  final int typeId = 0;

  @override
  AddictionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddictionModel()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..iconName = fields[2] as String
      ..startDate = fields[3] as DateTime
      ..costPerDay = fields[4] as double
      ..minutesWastedPerDay = fields[5] as int;
  }

  @override
  void write(BinaryWriter writer, AddictionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconName)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.costPerDay)
      ..writeByte(5)
      ..write(obj.minutesWastedPerDay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddictionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
