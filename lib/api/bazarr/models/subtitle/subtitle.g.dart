// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtitle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BazarrSubtitle _$BazarrSubtitleFromJson(Map<String, dynamic> json) =>
    BazarrSubtitle(
      name: json['name'] as String?,
      code2: json['code2'] as String?,
      code3: json['code3'] as String?,
      forced: json['forced'] as bool?,
      hearingImpaired: json['hi'] as bool?,
      path: json['path'] as String?,
    );

Map<String, dynamic> _$BazarrSubtitleToJson(BazarrSubtitle instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('code2', instance.code2);
  writeNotNull('code3', instance.code3);
  writeNotNull('forced', instance.forced);
  writeNotNull('hi', instance.hearingImpaired);
  writeNotNull('path', instance.path);
  return val;
}
