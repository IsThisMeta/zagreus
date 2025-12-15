// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indexer_icon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZagIndexerIconAdapter extends TypeAdapter<ZagIndexerIcon> {
  @override
  final int typeId = 22;

  @override
  ZagIndexerIcon read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ZagIndexerIcon.GENERIC;
      case 1:
        return ZagIndexerIcon.DOGNZB;
      case 2:
        return ZagIndexerIcon.DRUNKENSLUG;
      case 3:
        return ZagIndexerIcon.NZBFINDER;
      case 4:
        return ZagIndexerIcon.NZBGEEK;
      case 5:
        return ZagIndexerIcon.NZBHYDRA;
      case 6:
        return ZagIndexerIcon.NZBSU;
      default:
        return ZagIndexerIcon.GENERIC;
    }
  }

  @override
  void write(BinaryWriter writer, ZagIndexerIcon obj) {
    switch (obj) {
      case ZagIndexerIcon.GENERIC:
        writer.writeByte(0);
        break;
      case ZagIndexerIcon.DOGNZB:
        writer.writeByte(1);
        break;
      case ZagIndexerIcon.DRUNKENSLUG:
        writer.writeByte(2);
        break;
      case ZagIndexerIcon.NZBFINDER:
        writer.writeByte(3);
        break;
      case ZagIndexerIcon.NZBGEEK:
        writer.writeByte(4);
        break;
      case ZagIndexerIcon.NZBHYDRA:
        writer.writeByte(5);
        break;
      case ZagIndexerIcon.NZBSU:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZagIndexerIconAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
