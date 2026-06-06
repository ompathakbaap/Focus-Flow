// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionRecordAdapter extends TypeAdapter<SessionRecord> {
  @override
  final int typeId = 0;

  @override
  SessionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionRecord(
      date: fields[0] as DateTime,
      durationMinutes: fields[1] as int,
      sessionType: fields[2] as String,
      completed: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SessionRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.durationMinutes)
      ..writeByte(2)
      ..write(obj.sessionType)
      ..writeByte(3)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
