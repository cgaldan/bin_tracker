// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RentalRecordAdapter extends TypeAdapter<RentalRecord> {
  @override
  final int typeId = 2;

  @override
  RentalRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RentalRecord(
      renterName: fields[0] as String,
      renterPhone: fields[1] as String,
      startDate: fields[2] as DateTime?,
      remainingSeconds: fields[3] as int?,
      plannedSeconds: fields[4] as int,
      state: fields[5] as RentalState,
      endedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RentalRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.renterName)
      ..writeByte(1)
      ..write(obj.renterPhone)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.remainingSeconds)
      ..writeByte(4)
      ..write(obj.plannedSeconds)
      ..writeByte(5)
      ..write(obj.state)
      ..writeByte(6)
      ..write(obj.endedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RentalRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RentalStateAdapter extends TypeAdapter<RentalState> {
  @override
  final int typeId = 1;

  @override
  RentalState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RentalState.active;
      case 1:
        return RentalState.inactive;
      case 2:
        return RentalState.completed;
      default:
        return RentalState.active;
    }
  }

  @override
  void write(BinaryWriter writer, RentalState obj) {
    switch (obj) {
      case RentalState.active:
        writer.writeByte(0);
        break;
      case RentalState.inactive:
        writer.writeByte(1);
        break;
      case RentalState.completed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RentalStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
