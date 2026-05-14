// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 1;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      currencyCode: fields[0] as String,
      currencySymbol: fields[1] as String,
      dailyMotivationEnabled: fields[2] as bool,
      notificationHour: fields[3] as int,
      notificationMinute: fields[4] as int,
      milestoneNotificationsEnabled: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.currencyCode)
      ..writeByte(1)
      ..write(obj.currencySymbol)
      ..writeByte(2)
      ..write(obj.dailyMotivationEnabled)
      ..writeByte(3)
      ..write(obj.notificationHour)
      ..writeByte(4)
      ..write(obj.notificationMinute)
      ..writeByte(5)
      ..write(obj.milestoneNotificationsEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
