// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrBookFile _$ReadarrBookFileFromJson(Map<String, dynamic> json) =>
    ReadarrBookFile(
      id: (json['id'] as num?)?.toInt(),
      authorId: (json['authorId'] as num?)?.toInt(),
      bookId: (json['bookId'] as num?)?.toInt(),
      path: json['path'] as String?,
      size: (json['size'] as num?)?.toInt(),
      dateAdded: json['dateAdded'] == null
          ? null
          : DateTime.parse(json['dateAdded'] as String),
      quality: json['quality'] == null
          ? null
          : ReadarrBookFileQuality.fromJson(
              json['quality'] as Map<String, dynamic>),
      qualityWeight: (json['qualityWeight'] as num?)?.toInt(),
      mediaInfo: json['mediaInfo'] == null
          ? null
          : ReadarrBookFileMediaInfo.fromJson(
              json['mediaInfo'] as Map<String, dynamic>),
      editionId: (json['editionId'] as num?)?.toInt(),
      calibreId: (json['calibreId'] as num?)?.toInt(),
      part: (json['part'] as num?)?.toInt(),
      author: json['author'] == null
          ? null
          : ReadarrAuthor.fromJson(json['author'] as Map<String, dynamic>),
      edition: json['edition'] == null
          ? null
          : ReadarrEdition.fromJson(json['edition'] as Map<String, dynamic>),
      partCount: (json['partCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReadarrBookFileToJson(ReadarrBookFile instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('authorId', instance.authorId);
  writeNotNull('bookId', instance.bookId);
  writeNotNull('path', instance.path);
  writeNotNull('size', instance.size);
  writeNotNull('dateAdded', instance.dateAdded?.toIso8601String());
  writeNotNull('quality', instance.quality?.toJson());
  writeNotNull('qualityWeight', instance.qualityWeight);
  writeNotNull('mediaInfo', instance.mediaInfo?.toJson());
  writeNotNull('editionId', instance.editionId);
  writeNotNull('calibreId', instance.calibreId);
  writeNotNull('part', instance.part);
  writeNotNull('author', instance.author?.toJson());
  writeNotNull('edition', instance.edition?.toJson());
  writeNotNull('partCount', instance.partCount);
  return val;
}
