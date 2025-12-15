// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_view_option.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZagListViewOptionAdapter extends TypeAdapter<ZagListViewOption> {
  @override
  final int typeId = 29;

  @override
  ZagListViewOption read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ZagListViewOption.BLOCK_VIEW;
      case 1:
        return ZagListViewOption.GRID_VIEW;
      default:
        return ZagListViewOption.BLOCK_VIEW;
    }
  }

  @override
  void write(BinaryWriter writer, ZagListViewOption obj) {
    switch (obj) {
      case ZagListViewOption.BLOCK_VIEW:
        writer.writeByte(0);
        break;
      case ZagListViewOption.GRID_VIEW:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZagListViewOptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
