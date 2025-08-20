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
      renterLoc: fields[2] as String,
      startDate: fields[3] as DateTime?,
      remainingSeconds: fields[4] as int?,
      plannedSeconds: fields[5] as int,
      state: fields[6] as RentalState,
      endedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RentalRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.renterName)
      ..writeByte(1)
      ..write(obj.renterPhone)
      ..writeByte(2)
      ..write(obj.renterLoc)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.remainingSeconds)
      ..writeByte(5)
      ..write(obj.plannedSeconds)
      ..writeByte(6)
      ..write(obj.state)
      ..writeByte(7)
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
      case 3:
        return RentalState.paused;
      case 4:
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
      case RentalState.paused:
        writer.writeByte(3);
        break;
      case RentalState.completed:
        writer.writeByte(4);
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
