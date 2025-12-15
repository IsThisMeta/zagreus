// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliServerInfo _$TautulliServerInfoFromJson(Map<String, dynamic> json) =>
    TautulliServerInfo(
      name: TautulliUtilities.ensureStringFromJson(json['name']),
      machineIdentifier:
          TautulliUtilities.ensureStringFromJson(json['machine_identifier']),
      host: TautulliUtilities.ensureStringFromJson(json['host']),
      port: TautulliUtilities.ensureIntegerFromJson(json['port']),
      version: TautulliUtilities.ensureStringFromJson(json['version']),
    );

Map<String, dynamic> _$TautulliServerInfoToJson(TautulliServerInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('machine_identifier', instance.machineIdentifier);
  writeNotNull('version', instance.version);
  writeNotNull('host', instance.host);
  writeNotNull('port', instance.port);
  return val;
}
