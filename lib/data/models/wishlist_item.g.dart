// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WishlistItemAdapter extends TypeAdapter<WishlistItem> {
  @override
  final int typeId = 0;

  @override
  WishlistItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WishlistItem(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      imageUrl: fields[3] as String?,
      targetPrice: fields[4] as double?,
      isPurchased: fields[5] as bool,
      savedAmount: fields[7] as double,
      targetDate: fields[9] as DateTime?,
      createdAt: fields[6] as DateTime?,
    )..categoryOrNull = fields[8] as WishlistCategory?;
  }

  @override
  void write(BinaryWriter writer, WishlistItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.targetPrice)
      ..writeByte(5)
      ..write(obj.isPurchased)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.savedAmount)
      ..writeByte(8)
      ..write(obj.categoryOrNull)
      ..writeByte(9)
      ..write(obj.targetDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WishlistCategoryAdapter extends TypeAdapter<WishlistCategory> {
  @override
  final int typeId = 1;

  @override
  WishlistCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WishlistCategory.elektronik;
      case 1:
        return WishlistCategory.fashion;
      case 2:
        return WishlistCategory.gaming;
      case 3:
        return WishlistCategory.pendidikan;
      case 4:
        return WishlistCategory.kendaraan;
      case 5:
        return WishlistCategory.lainnya;
      default:
        return WishlistCategory.elektronik;
    }
  }

  @override
  void write(BinaryWriter writer, WishlistCategory obj) {
    switch (obj) {
      case WishlistCategory.elektronik:
        writer.writeByte(0);
        break;
      case WishlistCategory.fashion:
        writer.writeByte(1);
        break;
      case WishlistCategory.gaming:
        writer.writeByte(2);
        break;
      case WishlistCategory.pendidikan:
        writer.writeByte(3);
        break;
      case WishlistCategory.kendaraan:
        writer.writeByte(4);
        break;
      case WishlistCategory.lainnya:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
