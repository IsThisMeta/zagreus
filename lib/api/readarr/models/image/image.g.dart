// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrImage _$ReadarrImageFromJson(Map<String, dynamic> json) => ReadarrImage(
      url: json['url'] as String?,
      coverType: json['coverType'] as String?,
      extension: json['extension'] as String?,
    );

Map<String, dynamic> _$ReadarrImageToJson(ReadarrImage instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('url', instance.url);
  writeNotNull('coverType', instance.coverType);
  writeNotNull('extension', instance.extension);
  return val;
}
