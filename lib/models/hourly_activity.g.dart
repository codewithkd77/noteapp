// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hourly_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HourlyActivityAdapter extends TypeAdapter<HourlyActivity> {
  @override
  final int typeId = 5;

  @override
  HourlyActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HourlyActivity(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      hour: fields[2] as int,
      activity: fields[3] as String,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HourlyActivity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.hour)
      ..writeByte(3)
      ..write(obj.activity)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourlyActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
