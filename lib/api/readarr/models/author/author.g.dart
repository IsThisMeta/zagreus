// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrAuthor _$ReadarrAuthorFromJson(Map<String, dynamic> json) =>
    ReadarrAuthor(
      id: (json['id'] as num?)?.toInt(),
      authorName: json['authorName'] as String?,
      authorNameLastFirst: json['authorNameLastFirst'] as String?,
      foreignAuthorId: json['foreignAuthorId'] as String?,
      titleSlug: json['titleSlug'] as String?,
      overview: json['overview'] as String?,
      disambiguation: json['disambiguation'] as String?,
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => ReadarrAuthorLinks.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ReadarrImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      path: json['path'] as String?,
      qualityProfileId: (json['qualityProfileId'] as num?)?.toInt(),
      metadataProfileId: (json['metadataProfileId'] as num?)?.toInt(),
      monitored: json['monitored'] as bool?,
      monitorNewItems: json['monitorNewItems'] as String?,
      rootFolderPath: json['rootFolderPath'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      cleanName: json['cleanName'] as String?,
      sortName: json['sortName'] as String?,
      sortNameLastFirst: json['sortNameLastFirst'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      added: json['added'] == null
          ? null
          : DateTime.parse(json['added'] as String),
      ratings: json['ratings'] == null
          ? null
          : ReadarrAuthorRatings.fromJson(
              json['ratings'] as Map<String, dynamic>),
      statistics: json['statistics'] == null
          ? null
          : ReadarrAuthorStatistics.fromJson(
              json['statistics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReadarrAuthorToJson(ReadarrAuthor instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('authorName', instance.authorName);
  writeNotNull('authorNameLastFirst', instance.authorNameLastFirst);
  writeNotNull('foreignAuthorId', instance.foreignAuthorId);
  writeNotNull('titleSlug', instance.titleSlug);
  writeNotNull('overview', instance.overview);
  writeNotNull('disambiguation', instance.disambiguation);
  writeNotNull('links', instance.links?.map((e) => e.toJson()).toList());
  writeNotNull('images', instance.images?.map((e) => e.toJson()).toList());
  writeNotNull('path', instance.path);
  writeNotNull('qualityProfileId', instance.qualityProfileId);
  writeNotNull('metadataProfileId', instance.metadataProfileId);
  writeNotNull('monitored', instance.monitored);
  writeNotNull('monitorNewItems', instance.monitorNewItems);
  writeNotNull('rootFolderPath', instance.rootFolderPath);
  writeNotNull('genres', instance.genres);
  writeNotNull('cleanName', instance.cleanName);
  writeNotNull('sortName', instance.sortName);
  writeNotNull('sortNameLastFirst', instance.sortNameLastFirst);
  writeNotNull('tags', instance.tags);
  writeNotNull('added', instance.added?.toIso8601String());
  writeNotNull('ratings', instance.ratings?.toJson());
  writeNotNull('statistics', instance.statistics?.toJson());
  return val;
}
