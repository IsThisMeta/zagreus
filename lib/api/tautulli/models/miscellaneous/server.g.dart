// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliServer _$TautulliServerFromJson(Map<String, dynamic> json) =>
    TautulliServer(
      httpsRequired:
          TautulliUtilities.ensureBooleanFromJson(json['httpsRequired']),
      local: TautulliUtilities.ensureBooleanFromJson(json['local']),
      clientIdentifier:
          TautulliUtilities.ensureStringFromJson(json['clientIdentifier']),
      label: TautulliUtilities.ensureStringFromJson(json['label']),
      ipAddress: TautulliUtilities.ensureStringFromJson(json['ip']),
      port: TautulliUtilities.ensureIntegerFromJson(json['port']),
      uri: TautulliUtilities.ensureStringFromJson(json['uri']),
      value: TautulliUtilities.ensureStringFromJson(json['value']),
      isCloud: TautulliUtilities.ensureBooleanFromJson(json['is_cloud']),
    );

Map<String, dynamic> _$TautulliServerToJson(TautulliServer instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('httpsRequired', instance.httpsRequired);
  writeNotNull('local', instance.local);
  writeNotNull('clientIdentifier', instance.clientIdentifier);
  writeNotNull('label', instance.label);
  writeNotNull('ip', instance.ipAddress);
  writeNotNull('port', instance.port);
  writeNotNull('uri', instance.uri);
  writeNotNull('value', instance.value);
  writeNotNull('is_cloud', instance.isCloud);
  return val;
}
