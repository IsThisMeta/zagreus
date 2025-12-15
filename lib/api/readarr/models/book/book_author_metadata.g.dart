// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_author_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrBookAuthorMetadata _$ReadarrBookAuthorMetadataFromJson(
        Map<String, dynamic> json) =>
    ReadarrBookAuthorMetadata(
      id: (json['id'] as num?)?.toInt(),
      foreignAuthorId: json['foreignAuthorId'] as String?,
      titleSlug: json['titleSlug'] as String?,
      name: json['name'] as String?,
      sortName: json['sortName'] as String?,
      nameLastFirst: json['nameLastFirst'] as String?,
      sortNameLastFirst: json['sortNameLastFirst'] as String?,
      aliases:
          (json['aliases'] as List<dynamic>?)?.map((e) => e as String).toList(),
      overview: json['overview'] as String?,
      gender: json['gender'] as String?,
      hometown: json['hometown'] as String?,
      born:
          json['born'] == null ? null : DateTime.parse(json['born'] as String),
      died:
          json['died'] == null ? null : DateTime.parse(json['died'] as String),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$ReadarrBookAuthorMetadataToJson(
    ReadarrBookAuthorMetadata instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('foreignAuthorId', instance.foreignAuthorId);
  writeNotNull('titleSlug', instance.titleSlug);
  writeNotNull('name', instance.name);
  writeNotNull('sortName', instance.sortName);
  writeNotNull('nameLastFirst', instance.nameLastFirst);
  writeNotNull('sortNameLastFirst', instance.sortNameLastFirst);
  writeNotNull('aliases', instance.aliases);
  writeNotNull('overview', instance.overview);
  writeNotNull('gender', instance.gender);
  writeNotNull('hometown', instance.hometown);
  writeNotNull('born', instance.born?.toIso8601String());
  writeNotNull('died', instance.died?.toIso8601String());
  writeNotNull('status', instance.status);
  return val;
}
