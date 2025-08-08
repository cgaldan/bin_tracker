// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bin_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BinItemAdapter extends TypeAdapter<BinItem> {
  @override
  final int typeId = 0;

  @override
  BinItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BinItem(
      id: fields[0] as String,
      location: fields[1] as String,
      contactName: fields[2] as String,
      contactPhone: fields[3] as String,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BinItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.location)
      ..writeByte(2)
      ..write(obj.contactName)
      ..writeByte(3)
      ..write(obj.contactPhone)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BinItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
