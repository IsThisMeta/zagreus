// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliServerIdentity _$TautulliServerIdentityFromJson(
        Map<String, dynamic> json) =>
    TautulliServerIdentity(
      machineIdentifier:
          TautulliUtilities.ensureStringFromJson(json['machine_identifier']),
      version: TautulliUtilities.ensureStringFromJson(json['version']),
    );

Map<String, dynamic> _$TautulliServerIdentityToJson(
    TautulliServerIdentity instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('machine_identifier', instance.machineIdentifier);
  writeNotNull('version', instance.version);
  return val;
}
