// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrCalendar _$ReadarrCalendarFromJson(Map<String, dynamic> json) =>
    ReadarrCalendar(
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
      author: json['author'] == null
          ? null
          : ReadarrAuthor.fromJson(json['author'] as Map<String, dynamic>),
      editions: (json['editions'] as List<dynamic>?)
          ?.map((e) => ReadarrEdition.fromJson(e as Map<String, dynamic>))
          .toList(),
      bookFiles: (json['bookFiles'] as List<dynamic>?)
          ?.map((e) => ReadarrBookFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReadarrCalendarToJson(ReadarrCalendar instance) {
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
  writeNotNull('author', instance.author?.toJson());
  writeNotNull('editions', instance.editions?.map((e) => e.toJson()).toList());
  writeNotNull(
      'bookFiles', instance.bookFiles?.map((e) => e.toJson()).toList());
  return val;
}
