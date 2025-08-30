// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bin_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BinItemAdapter extends TypeAdapter<BinItem> {
  @override
  final int typeId = 1;

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
      state: fields[3] as BinState,
    );
  }

  @override
  void write(BinaryWriter writer, BinItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.currentRentalKey)
      ..writeByte(2)
      ..write(obj.rentalHistory)
      ..writeByte(3)
      ..write(obj.state);
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

class BinStateAdapter extends TypeAdapter<BinState> {
  @override
  final int typeId = 0;

  @override
  BinState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BinState.free;
      case 1:
        return BinState.active;
      case 2:
        return BinState.toBeReturned;
      default:
        return BinState.free;
    }
  }

  @override
  void write(BinaryWriter writer, BinState obj) {
    switch (obj) {
      case BinState.free:
        writer.writeByte(0);
        break;
      case BinState.active:
        writer.writeByte(1);
        break;
      case BinState.toBeReturned:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BinStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
