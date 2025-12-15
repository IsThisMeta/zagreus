// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_links.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrAuthorLinks _$ReadarrAuthorLinksFromJson(Map<String, dynamic> json) =>
    ReadarrAuthorLinks(
      url: json['url'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$ReadarrAuthorLinksToJson(ReadarrAuthorLinks instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('url', instance.url);
  writeNotNull('name', instance.name);
  return val;
}
