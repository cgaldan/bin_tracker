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
      currentRentalKey: fields[1] as int?,
      rentalHistory: (fields[2] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, BinItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.currentRentalKey)
      ..writeByte(2)
      ..write(obj.rentalHistory);
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
