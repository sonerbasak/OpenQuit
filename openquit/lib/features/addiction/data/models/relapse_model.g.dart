// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relapse_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RelapseModelAdapter extends TypeAdapter<RelapseModel> {
  @override
  final int typeId = 2;

  @override
  RelapseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RelapseModel()
      ..id = fields[0] as String
      ..addictionId = fields[1] as String
      ..occurredAt = fields[2] as DateTime
      ..note = fields[3] as String?
      ..previousSobrietySeconds = fields[4] as int;
  }

  @override
  void write(BinaryWriter writer, RelapseModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.addictionId)
      ..writeByte(2)
      ..write(obj.occurredAt)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.previousSobrietySeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelapseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
