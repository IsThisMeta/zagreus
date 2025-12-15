// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrBook _$ReadarrBookFromJson(Map<String, dynamic> json) => ReadarrBook(
      id: (json['id'] as num?)?.toInt(),
      authorId: (json['authorId'] as num?)?.toInt(),
      foreignBookId: json['foreignBookId'] as String?,
      titleSlug: json['titleSlug'] as String?,
      title: json['title'] as String?,
      releaseDate: json['releaseDate'] == null
          ? null
          : DateTime.parse(json['releaseDate'] as String),
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => ReadarrAuthorLinks.fromJson(e as Map<String, dynamic>))
          .toList(),
      genres:
          (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      ratings: json['ratings'] == null
          ? null
          : ReadarrBookRatings.fromJson(
              json['ratings'] as Map<String, dynamic>),
      cleanTitle: json['cleanTitle'] as String?,
      monitored: json['monitored'] as bool?,
      anyEditionOk: json['anyEditionOk'] as bool?,
      lastInfoSync: json['lastInfoSync'] == null
          ? null
          : DateTime.parse(json['lastInfoSync'] as String),
      added: json['added'] == null
          ? null
          : DateTime.parse(json['added'] as String),
      addOptions: json['addOptions'] as Map<String, dynamic>?,
      authorMetadata: json['authorMetadata'] == null
          ? null
          : ReadarrBookAuthorMetadata.fromJson(
              json['authorMetadata'] as Map<String, dynamic>),
      author: json['author'] == null
          ? null
          : ReadarrAuthor.fromJson(json['author'] as Map<String, dynamic>),
      editions: (json['editions'] as List<dynamic>?)
          ?.map((e) => ReadarrEdition.fromJson(e as Map<String, dynamic>))
          .toList(),
      bookFiles: (json['bookFiles'] as List<dynamic>?)
          ?.map((e) => ReadarrBookFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      seriesLinks: (json['seriesLinks'] as List<dynamic>?)
          ?.map(
              (e) => ReadarrSeriesBookLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      statistics: json['statistics'] == null
          ? null
          : ReadarrBookStatistics.fromJson(
              json['statistics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReadarrBookToJson(ReadarrBook instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('authorId', instance.authorId);
  writeNotNull('foreignBookId', instance.foreignBookId);
  writeNotNull('titleSlug', instance.titleSlug);
  writeNotNull('title', instance.title);
  writeNotNull('releaseDate', instance.releaseDate?.toIso8601String());
  writeNotNull('links', instance.links?.map((e) => e.toJson()).toList());
  writeNotNull('genres', instance.genres);
  writeNotNull('ratings', instance.ratings?.toJson());
  writeNotNull('cleanTitle', instance.cleanTitle);
  writeNotNull('monitored', instance.monitored);
  writeNotNull('anyEditionOk', instance.anyEditionOk);
  writeNotNull('lastInfoSync', instance.lastInfoSync?.toIso8601String());
  writeNotNull('added', instance.added?.toIso8601String());
  writeNotNull('addOptions', instance.addOptions);
  writeNotNull('authorMetadata', instance.authorMetadata?.toJson());
  writeNotNull('author', instance.author?.toJson());
  writeNotNull('editions', instance.editions?.map((e) => e.toJson()).toList());
  writeNotNull(
      'bookFiles', instance.bookFiles?.map((e) => e.toJson()).toList());
  writeNotNull(
      'seriesLinks', instance.seriesLinks?.map((e) => e.toJson()).toList());
  writeNotNull('statistics', instance.statistics?.toJson());
  return val;
}
