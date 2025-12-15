// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrEdition _$ReadarrEditionFromJson(Map<String, dynamic> json) =>
    ReadarrEdition(
      id: (json['id'] as num?)?.toInt(),
      bookId: (json['bookId'] as num?)?.toInt(),
      foreignEditionId: json['foreignEditionId'] as String?,
      titleSlug: json['titleSlug'] as String?,
      isbn13: json['isbn13'] as String?,
      asin: json['asin'] as String?,
      title: json['title'] as String?,
      language: json['language'] as String?,
      overview: json['overview'] as String?,
      format: json['format'] as String?,
      isEbook: json['isEbook'] as bool?,
      disambiguation: json['disambiguation'] as String?,
      publisher: json['publisher'] as String?,
      pageCount: (json['pageCount'] as num?)?.toInt(),
      releaseDate: json['releaseDate'] == null
          ? null
          : DateTime.parse(json['releaseDate'] as String),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ReadarrImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => ReadarrAuthorLinks.fromJson(e as Map<String, dynamic>))
          .toList(),
      ratings: json['ratings'] == null
          ? null
          : ReadarrBookRatings.fromJson(
              json['ratings'] as Map<String, dynamic>),
      monitored: json['monitored'] as bool?,
      manualAdd: json['manualAdd'] as bool?,
    );

Map<String, dynamic> _$ReadarrEditionToJson(ReadarrEdition instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('bookId', instance.bookId);
  writeNotNull('foreignEditionId', instance.foreignEditionId);
  writeNotNull('titleSlug', instance.titleSlug);
  writeNotNull('isbn13', instance.isbn13);
  writeNotNull('asin', instance.asin);
  writeNotNull('title', instance.title);
  writeNotNull('language', instance.language);
  writeNotNull('overview', instance.overview);
  writeNotNull('format', instance.format);
  writeNotNull('isEbook', instance.isEbook);
  writeNotNull('disambiguation', instance.disambiguation);
  writeNotNull('publisher', instance.publisher);
  writeNotNull('pageCount', instance.pageCount);
  writeNotNull('releaseDate', instance.releaseDate?.toIso8601String());
  writeNotNull('images', instance.images?.map((e) => e.toJson()).toList());
  writeNotNull('links', instance.links?.map((e) => e.toJson()).toList());
  writeNotNull('ratings', instance.ratings?.toJson());
  writeNotNull('monitored', instance.monitored);
  writeNotNull('manualAdd', instance.manualAdd);
  return val;
}
