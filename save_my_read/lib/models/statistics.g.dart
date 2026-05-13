// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatisticsAdapter extends TypeAdapter<Statistics> {
  @override
  final int typeId = 1;

  @override
  Statistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Statistics()
      ..year = fields[0] as String
      ..count = fields[1] as int;
  }

  @override
  void write(BinaryWriter writer, Statistics obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.year)
      ..writeByte(1)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
