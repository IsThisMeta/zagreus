// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZagLogTypeAdapter extends TypeAdapter<ZagLogType> {
  @override
  final int typeId = 24;

  @override
  ZagLogType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ZagLogType.WARNING;
      case 1:
        return ZagLogType.ERROR;
      case 2:
        return ZagLogType.CRITICAL;
      case 3:
        return ZagLogType.DEBUG;
      default:
        return ZagLogType.WARNING;
    }
  }

  @override
  void write(BinaryWriter writer, ZagLogType obj) {
    switch (obj) {
      case ZagLogType.WARNING:
        writer.writeByte(0);
        break;
      case ZagLogType.ERROR:
        writer.writeByte(1);
        break;
      case ZagLogType.CRITICAL:
        writer.writeByte(2);
        break;
      case ZagLogType.DEBUG:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZagLogTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
