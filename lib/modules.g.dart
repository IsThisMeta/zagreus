// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modules.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZagModuleAdapter extends TypeAdapter<ZagModule> {
  @override
  final int typeId = 25;

  @override
  ZagModule read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ZagModule.DASHBOARD;
      case 11:
        return ZagModule.EXTERNAL_MODULES;
      case 1:
        return ZagModule.LIDARR;
      case 2:
        return ZagModule.NZBGET;
      case 3:
        return ZagModule.OVERSEERR;
      case 4:
        return ZagModule.RADARR;
      case 5:
        return ZagModule.SABNZBD;
      case 6:
        return ZagModule.SEARCH;
      case 7:
        return ZagModule.SETTINGS;
      case 8:
        return ZagModule.SONARR;
      case 9:
        return ZagModule.TAUTULLI;
      case 10:
        return ZagModule.WAKE_ON_LAN;
      case 12:
        return ZagModule.DISCOVER;
      case 13:
        return ZagModule.UNRAID;
      case 15:
        return ZagModule.READARR;
      case 16:
        return ZagModule.BAZARR;
      default:
        return ZagModule.DASHBOARD;
    }
  }

  @override
  void write(BinaryWriter writer, ZagModule obj) {
    switch (obj) {
      case ZagModule.DASHBOARD:
        writer.writeByte(0);
        break;
      case ZagModule.EXTERNAL_MODULES:
        writer.writeByte(11);
        break;
      case ZagModule.LIDARR:
        writer.writeByte(1);
        break;
      case ZagModule.NZBGET:
        writer.writeByte(2);
        break;
      case ZagModule.OVERSEERR:
        writer.writeByte(3);
        break;
      case ZagModule.RADARR:
        writer.writeByte(4);
        break;
      case ZagModule.SABNZBD:
        writer.writeByte(5);
        break;
      case ZagModule.SEARCH:
        writer.writeByte(6);
        break;
      case ZagModule.SETTINGS:
        writer.writeByte(7);
        break;
      case ZagModule.SONARR:
        writer.writeByte(8);
        break;
      case ZagModule.TAUTULLI:
        writer.writeByte(9);
        break;
      case ZagModule.WAKE_ON_LAN:
        writer.writeByte(10);
        break;
      case ZagModule.DISCOVER:
        writer.writeByte(12);
        break;
      case ZagModule.UNRAID:
        writer.writeByte(13);
        break;
      case ZagModule.READARR:
        writer.writeByte(15);
        break;
      case ZagModule.BAZARR:
        writer.writeByte(16);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZagModuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
