// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whois_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliWHOISInfo _$TautulliWHOISInfoFromJson(Map<String, dynamic> json) =>
    TautulliWHOISInfo(
      host: TautulliUtilities.ensureStringFromJson(json['host']),
      subnets: TautulliWHOISInfo._subnetsToObjectArray(json['nets'] as List),
    );

Map<String, dynamic> _$TautulliWHOISInfoToJson(TautulliWHOISInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('host', instance.host);
  writeNotNull('nets', TautulliWHOISInfo._subnetsToMap(instance.subnets));
  return val;
}
