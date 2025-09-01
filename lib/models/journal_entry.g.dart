// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JournalEntryAdapter extends TypeAdapter<JournalEntry> {
  @override
  final int typeId = 6;

  @override
  JournalEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalEntry(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      type: fields[5] as JournalType,
      mood: fields[6] as String?,
      tags: (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.mood)
      ..writeByte(7)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class JournalTypeAdapter extends TypeAdapter<JournalType> {
  @override
  final int typeId = 7;

  @override
  JournalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return JournalType.diary;
      case 1:
        return JournalType.affirmation;
      case 2:
        return JournalType.gratitude;
      case 3:
        return JournalType.reflection;
      default:
        return JournalType.diary;
    }
  }

  @override
  void write(BinaryWriter writer, JournalType obj) {
    switch (obj) {
      case JournalType.diary:
        writer.writeByte(0);
        break;
      case JournalType.affirmation:
        writer.writeByte(1);
        break;
      case JournalType.gratitude:
        writer.writeByte(2);
        break;
      case JournalType.reflection:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
