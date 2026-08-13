// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingsEntryAdapter extends TypeAdapter<SavingsEntry> {
  @override
  final int typeId = 2;

  @override
  SavingsEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsEntry(
      id: fields[0] as String,
      wishlistId: fields[1] as String,
      amount: fields[2] as double,
      addedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.wishlistId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
