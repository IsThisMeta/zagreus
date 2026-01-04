// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZagProfileAdapter extends TypeAdapter<ZagProfile> {
  @override
  final int typeId = 0;

  @override
  ZagProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZagProfile(
      lidarrEnabled: fields[0] == null ? false : fields[0] as bool?,
      lidarrHost: fields[1] == null ? '' : fields[1] as String?,
      lidarrKey: fields[2] == null ? '' : fields[2] as String?,
      lidarrHeaders: fields[26] == null
          ? {}
          : (fields[26] as Map?)?.cast<String, String>(),
      lidarrLocalHost: fields[48] == null ? '' : fields[48] as String?,
      lidarrLocalSsids: fields[49] == null ? '' : fields[49] as String?,
      radarrEnabled: fields[3] == null ? false : fields[3] as bool?,
      radarrHost: fields[4] == null ? '' : fields[4] as String?,
      radarrKey: fields[5] == null ? '' : fields[5] as String?,
      radarrHeaders: fields[27] == null
          ? {}
          : (fields[27] as Map?)?.cast<String, String>(),
      radarrLocalHost: fields[50] == null ? '' : fields[50] as String?,
      radarrLocalSsids: fields[51] == null ? '' : fields[51] as String?,
      sonarrEnabled: fields[6] == null ? false : fields[6] as bool?,
      sonarrHost: fields[7] == null ? '' : fields[7] as String?,
      sonarrKey: fields[8] == null ? '' : fields[8] as String?,
      sonarrHeaders: fields[28] == null
          ? {}
          : (fields[28] as Map?)?.cast<String, String>(),
      sonarrLocalHost: fields[52] == null ? '' : fields[52] as String?,
      sonarrLocalSsids: fields[53] == null ? '' : fields[53] as String?,
      sabnzbdEnabled: fields[9] == null ? false : fields[9] as bool?,
      sabnzbdHost: fields[10] == null ? '' : fields[10] as String?,
      sabnzbdKey: fields[11] == null ? '' : fields[11] as String?,
      sabnzbdHeaders: fields[29] == null
          ? {}
          : (fields[29] as Map?)?.cast<String, String>(),
      sabnzbdLocalHost: fields[54] == null ? '' : fields[54] as String?,
      sabnzbdLocalSsids: fields[55] == null ? '' : fields[55] as String?,
      nzbgetEnabled: fields[12] == null ? false : fields[12] as bool?,
      nzbgetHost: fields[13] == null ? '' : fields[13] as String?,
      nzbgetUser: fields[14] == null ? '' : fields[14] as String?,
      nzbgetPass: fields[15] == null ? '' : fields[15] as String?,
      nzbgetHeaders: fields[30] == null
          ? {}
          : (fields[30] as Map?)?.cast<String, String>(),
      nzbgetLocalHost: fields[56] == null ? '' : fields[56] as String?,
      nzbgetLocalSsids: fields[57] == null ? '' : fields[57] as String?,
      wakeOnLANEnabled: fields[23] == null ? false : fields[23] as bool?,
      wakeOnLANBroadcastAddress:
          fields[24] == null ? '' : fields[24] as String?,
      wakeOnLANMACAddress: fields[25] == null ? '' : fields[25] as String?,
      tautulliEnabled: fields[31] == null ? false : fields[31] as bool?,
      tautulliHost: fields[32] == null ? '' : fields[32] as String?,
      tautulliKey: fields[33] == null ? '' : fields[33] as String?,
      tautulliHeaders: fields[35] == null
          ? {}
          : (fields[35] as Map?)?.cast<String, String>(),
      tautulliLocalHost: fields[58] == null ? '' : fields[58] as String?,
      tautulliLocalSsids: fields[59] == null ? '' : fields[59] as String?,
      seerrEnabled: fields[40] == null ? false : fields[40] as bool?,
      seerrHost: fields[41] == null ? '' : fields[41] as String?,
      seerrKey: fields[42] == null ? '' : fields[42] as String?,
      seerrHeaders: fields[43] == null
          ? {}
          : (fields[43] as Map?)?.cast<String, String>(),
      seerrLocalHost: fields[68] == null ? '' : fields[68] as String?,
      seerrLocalSsids: fields[69] == null ? '' : fields[69] as String?,
      unraidEnabled: fields[44] == null ? false : fields[44] as bool?,
      unraidHost: fields[45] == null ? '' : fields[45] as String?,
      unraidKey: fields[46] == null ? '' : fields[46] as String?,
      unraidHeaders: fields[47] == null
          ? {}
          : (fields[47] as Map?)?.cast<String, String>(),
      unraidLocalHost: fields[60] == null ? '' : fields[60] as String?,
      unraidLocalSsids: fields[61] == null ? '' : fields[61] as String?,
      readarrEnabled: fields[62] == null ? false : fields[62] as bool?,
      readarrHost: fields[63] == null ? '' : fields[63] as String?,
      readarrKey: fields[64] == null ? '' : fields[64] as String?,
      readarrHeaders: fields[65] == null
          ? {}
          : (fields[65] as Map?)?.cast<String, String>(),
      readarrLocalHost: fields[66] == null ? '' : fields[66] as String?,
      readarrLocalSsids: fields[67] == null ? '' : fields[67] as String?,
      bazarrEnabled: fields[70] == null ? false : fields[70] as bool?,
      bazarrHost: fields[71] == null ? '' : fields[71] as String?,
      bazarrKey: fields[72] == null ? '' : fields[72] as String?,
      bazarrHeaders: fields[73] == null
          ? {}
          : (fields[73] as Map?)?.cast<String, String>(),
      bazarrLocalHost: fields[74] == null ? '' : fields[74] as String?,
      bazarrLocalSsids: fields[75] == null ? '' : fields[75] as String?,
      sshEnabled: fields[76] == null ? false : fields[76] as bool?,
      sshLocalHost: fields[77] == null ? '' : fields[77] as String?,
      sshLocalSsids: fields[78] == null ? '' : fields[78] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ZagProfile obj) {
    writer
      ..writeByte(67)
      ..writeByte(0)
      ..write(obj.lidarrEnabled)
      ..writeByte(1)
      ..write(obj.lidarrHost)
      ..writeByte(2)
      ..write(obj.lidarrKey)
      ..writeByte(26)
      ..write(obj.lidarrHeaders)
      ..writeByte(48)
      ..write(obj.lidarrLocalHost)
      ..writeByte(49)
      ..write(obj.lidarrLocalSsids)
      ..writeByte(3)
      ..write(obj.radarrEnabled)
      ..writeByte(4)
      ..write(obj.radarrHost)
      ..writeByte(5)
      ..write(obj.radarrKey)
      ..writeByte(27)
      ..write(obj.radarrHeaders)
      ..writeByte(50)
      ..write(obj.radarrLocalHost)
      ..writeByte(51)
      ..write(obj.radarrLocalSsids)
      ..writeByte(6)
      ..write(obj.sonarrEnabled)
      ..writeByte(7)
      ..write(obj.sonarrHost)
      ..writeByte(8)
      ..write(obj.sonarrKey)
      ..writeByte(28)
      ..write(obj.sonarrHeaders)
      ..writeByte(52)
      ..write(obj.sonarrLocalHost)
      ..writeByte(53)
      ..write(obj.sonarrLocalSsids)
      ..writeByte(9)
      ..write(obj.sabnzbdEnabled)
      ..writeByte(10)
      ..write(obj.sabnzbdHost)
      ..writeByte(11)
      ..write(obj.sabnzbdKey)
      ..writeByte(29)
      ..write(obj.sabnzbdHeaders)
      ..writeByte(54)
      ..write(obj.sabnzbdLocalHost)
      ..writeByte(55)
      ..write(obj.sabnzbdLocalSsids)
      ..writeByte(12)
      ..write(obj.nzbgetEnabled)
      ..writeByte(13)
      ..write(obj.nzbgetHost)
      ..writeByte(14)
      ..write(obj.nzbgetUser)
      ..writeByte(15)
      ..write(obj.nzbgetPass)
      ..writeByte(30)
      ..write(obj.nzbgetHeaders)
      ..writeByte(56)
      ..write(obj.nzbgetLocalHost)
      ..writeByte(57)
      ..write(obj.nzbgetLocalSsids)
      ..writeByte(23)
      ..write(obj.wakeOnLANEnabled)
      ..writeByte(24)
      ..write(obj.wakeOnLANBroadcastAddress)
      ..writeByte(25)
      ..write(obj.wakeOnLANMACAddress)
      ..writeByte(31)
      ..write(obj.tautulliEnabled)
      ..writeByte(32)
      ..write(obj.tautulliHost)
      ..writeByte(33)
      ..write(obj.tautulliKey)
      ..writeByte(35)
      ..write(obj.tautulliHeaders)
      ..writeByte(58)
      ..write(obj.tautulliLocalHost)
      ..writeByte(59)
      ..write(obj.tautulliLocalSsids)
      ..writeByte(40)
      ..write(obj.seerrEnabled)
      ..writeByte(41)
      ..write(obj.seerrHost)
      ..writeByte(42)
      ..write(obj.seerrKey)
      ..writeByte(43)
      ..write(obj.seerrHeaders)
      ..writeByte(68)
      ..write(obj.seerrLocalHost)
      ..writeByte(69)
      ..write(obj.seerrLocalSsids)
      ..writeByte(44)
      ..write(obj.unraidEnabled)
      ..writeByte(45)
      ..write(obj.unraidHost)
      ..writeByte(46)
      ..write(obj.unraidKey)
      ..writeByte(47)
      ..write(obj.unraidHeaders)
      ..writeByte(60)
      ..write(obj.unraidLocalHost)
      ..writeByte(61)
      ..write(obj.unraidLocalSsids)
      ..writeByte(62)
      ..write(obj.readarrEnabled)
      ..writeByte(63)
      ..write(obj.readarrHost)
      ..writeByte(64)
      ..write(obj.readarrKey)
      ..writeByte(65)
      ..write(obj.readarrHeaders)
      ..writeByte(66)
      ..write(obj.readarrLocalHost)
      ..writeByte(67)
      ..write(obj.readarrLocalSsids)
      ..writeByte(70)
      ..write(obj.bazarrEnabled)
      ..writeByte(71)
      ..write(obj.bazarrHost)
      ..writeByte(72)
      ..write(obj.bazarrKey)
      ..writeByte(73)
      ..write(obj.bazarrHeaders)
      ..writeByte(74)
      ..write(obj.bazarrLocalHost)
      ..writeByte(75)
      ..write(obj.bazarrLocalSsids)
      ..writeByte(76)
      ..write(obj.sshEnabled)
      ..writeByte(77)
      ..write(obj.sshLocalHost)
      ..writeByte(78)
      ..write(obj.sshLocalSsids);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZagProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZagProfile _$ZagProfileFromJson(Map<String, dynamic> json) => ZagProfile(
      lidarrEnabled: json['lidarrEnabled'] as bool?,
      lidarrHost: json['lidarrHost'] as String?,
      lidarrKey: json['lidarrKey'] as String?,
      lidarrHeaders: (json['lidarrHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      lidarrLocalHost: json['lidarrLocalHost'] as String?,
      lidarrLocalSsids: json['lidarrLocalSsids'] as String?,
      radarrEnabled: json['radarrEnabled'] as bool?,
      radarrHost: json['radarrHost'] as String?,
      radarrKey: json['radarrKey'] as String?,
      radarrHeaders: (json['radarrHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      radarrLocalHost: json['radarrLocalHost'] as String?,
      radarrLocalSsids: json['radarrLocalSsids'] as String?,
      sonarrEnabled: json['sonarrEnabled'] as bool?,
      sonarrHost: json['sonarrHost'] as String?,
      sonarrKey: json['sonarrKey'] as String?,
      sonarrHeaders: (json['sonarrHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      sonarrLocalHost: json['sonarrLocalHost'] as String?,
      sonarrLocalSsids: json['sonarrLocalSsids'] as String?,
      sabnzbdEnabled: json['sabnzbdEnabled'] as bool?,
      sabnzbdHost: json['sabnzbdHost'] as String?,
      sabnzbdKey: json['sabnzbdKey'] as String?,
      sabnzbdHeaders: (json['sabnzbdHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      sabnzbdLocalHost: json['sabnzbdLocalHost'] as String?,
      sabnzbdLocalSsids: json['sabnzbdLocalSsids'] as String?,
      nzbgetEnabled: json['nzbgetEnabled'] as bool?,
      nzbgetHost: json['nzbgetHost'] as String?,
      nzbgetUser: json['nzbgetUser'] as String?,
      nzbgetPass: json['nzbgetPass'] as String?,
      nzbgetHeaders: (json['nzbgetHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      nzbgetLocalHost: json['nzbgetLocalHost'] as String?,
      nzbgetLocalSsids: json['nzbgetLocalSsids'] as String?,
      wakeOnLANEnabled: json['wakeOnLANEnabled'] as bool?,
      wakeOnLANBroadcastAddress: json['wakeOnLANBroadcastAddress'] as String?,
      wakeOnLANMACAddress: json['wakeOnLANMACAddress'] as String?,
      tautulliEnabled: json['tautulliEnabled'] as bool?,
      tautulliHost: json['tautulliHost'] as String?,
      tautulliKey: json['tautulliKey'] as String?,
      tautulliHeaders: (json['tautulliHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      tautulliLocalHost: json['tautulliLocalHost'] as String?,
      tautulliLocalSsids: json['tautulliLocalSsids'] as String?,
      seerrEnabled: json['seerrEnabled'] as bool?,
      seerrHost: json['seerrHost'] as String?,
      seerrKey: json['seerrKey'] as String?,
      seerrHeaders: (json['seerrHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      seerrLocalHost: json['seerrLocalHost'] as String?,
      seerrLocalSsids: json['seerrLocalSsids'] as String?,
      unraidEnabled: json['unraidEnabled'] as bool?,
      unraidHost: json['unraidHost'] as String?,
      unraidKey: json['unraidKey'] as String?,
      unraidHeaders: (json['unraidHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      unraidLocalHost: json['unraidLocalHost'] as String?,
      unraidLocalSsids: json['unraidLocalSsids'] as String?,
      readarrEnabled: json['readarrEnabled'] as bool?,
      readarrHost: json['readarrHost'] as String?,
      readarrKey: json['readarrKey'] as String?,
      readarrHeaders: (json['readarrHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      readarrLocalHost: json['readarrLocalHost'] as String?,
      readarrLocalSsids: json['readarrLocalSsids'] as String?,
      bazarrEnabled: json['bazarrEnabled'] as bool?,
      bazarrHost: json['bazarrHost'] as String?,
      bazarrKey: json['bazarrKey'] as String?,
      bazarrHeaders: (json['bazarrHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      bazarrLocalHost: json['bazarrLocalHost'] as String?,
      bazarrLocalSsids: json['bazarrLocalSsids'] as String?,
      sshEnabled: json['sshEnabled'] as bool?,
      sshLocalHost: json['sshLocalHost'] as String?,
      sshLocalSsids: json['sshLocalSsids'] as String?,
    );

Map<String, dynamic> _$ZagProfileToJson(ZagProfile instance) =>
    <String, dynamic>{
      'lidarrEnabled': instance.lidarrEnabled,
      'lidarrHost': instance.lidarrHost,
      'lidarrKey': instance.lidarrKey,
      'lidarrHeaders': instance.lidarrHeaders,
      'lidarrLocalHost': instance.lidarrLocalHost,
      'lidarrLocalSsids': instance.lidarrLocalSsids,
      'radarrEnabled': instance.radarrEnabled,
      'radarrHost': instance.radarrHost,
      'radarrKey': instance.radarrKey,
      'radarrHeaders': instance.radarrHeaders,
      'radarrLocalHost': instance.radarrLocalHost,
      'radarrLocalSsids': instance.radarrLocalSsids,
      'sonarrEnabled': instance.sonarrEnabled,
      'sonarrHost': instance.sonarrHost,
      'sonarrKey': instance.sonarrKey,
      'sonarrHeaders': instance.sonarrHeaders,
      'sonarrLocalHost': instance.sonarrLocalHost,
      'sonarrLocalSsids': instance.sonarrLocalSsids,
      'sabnzbdEnabled': instance.sabnzbdEnabled,
      'sabnzbdHost': instance.sabnzbdHost,
      'sabnzbdKey': instance.sabnzbdKey,
      'sabnzbdHeaders': instance.sabnzbdHeaders,
      'sabnzbdLocalHost': instance.sabnzbdLocalHost,
      'sabnzbdLocalSsids': instance.sabnzbdLocalSsids,
      'nzbgetEnabled': instance.nzbgetEnabled,
      'nzbgetHost': instance.nzbgetHost,
      'nzbgetUser': instance.nzbgetUser,
      'nzbgetPass': instance.nzbgetPass,
      'nzbgetHeaders': instance.nzbgetHeaders,
      'nzbgetLocalHost': instance.nzbgetLocalHost,
      'nzbgetLocalSsids': instance.nzbgetLocalSsids,
      'wakeOnLANEnabled': instance.wakeOnLANEnabled,
      'wakeOnLANBroadcastAddress': instance.wakeOnLANBroadcastAddress,
      'wakeOnLANMACAddress': instance.wakeOnLANMACAddress,
      'tautulliEnabled': instance.tautulliEnabled,
      'tautulliHost': instance.tautulliHost,
      'tautulliKey': instance.tautulliKey,
      'tautulliHeaders': instance.tautulliHeaders,
      'tautulliLocalHost': instance.tautulliLocalHost,
      'tautulliLocalSsids': instance.tautulliLocalSsids,
      'seerrEnabled': instance.seerrEnabled,
      'seerrHost': instance.seerrHost,
      'seerrKey': instance.seerrKey,
      'seerrHeaders': instance.seerrHeaders,
      'seerrLocalHost': instance.seerrLocalHost,
      'seerrLocalSsids': instance.seerrLocalSsids,
      'unraidEnabled': instance.unraidEnabled,
      'unraidHost': instance.unraidHost,
      'unraidKey': instance.unraidKey,
      'unraidHeaders': instance.unraidHeaders,
      'unraidLocalHost': instance.unraidLocalHost,
      'unraidLocalSsids': instance.unraidLocalSsids,
      'readarrEnabled': instance.readarrEnabled,
      'readarrHost': instance.readarrHost,
      'readarrKey': instance.readarrKey,
      'readarrHeaders': instance.readarrHeaders,
      'readarrLocalHost': instance.readarrLocalHost,
      'readarrLocalSsids': instance.readarrLocalSsids,
      'bazarrEnabled': instance.bazarrEnabled,
      'bazarrHost': instance.bazarrHost,
      'bazarrKey': instance.bazarrKey,
      'bazarrHeaders': instance.bazarrHeaders,
      'bazarrLocalHost': instance.bazarrLocalHost,
      'bazarrLocalSsids': instance.bazarrLocalSsids,
      'sshEnabled': instance.sshEnabled,
      'sshLocalHost': instance.sshLocalHost,
      'sshLocalSsids': instance.sshLocalSsids,
    };
