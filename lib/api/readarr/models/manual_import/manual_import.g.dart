// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_import.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrManualImport _$ReadarrManualImportFromJson(Map<String, dynamic> json) =>
    ReadarrManualImport(
      path: json['path'] as String?,
      name: json['name'] as String?,
      size: (json['size'] as num?)?.toInt(),
      author: json['author'] == null
          ? null
          : ReadarrAuthor.fromJson(json['author'] as Map<String, dynamic>),
      book: json['book'] == null
          ? null
          : ReadarrBook.fromJson(json['book'] as Map<String, dynamic>),
      foreignEditionId: json['foreignEditionId'] as String?,
      quality: json['quality'] == null
          ? null
          : ReadarrBookFileQuality.fromJson(
              json['quality'] as Map<String, dynamic>),
      qualityWeight: (json['qualityWeight'] as num?)?.toInt(),
      downloadId: json['downloadId'] as String?,
      rejections: (json['rejections'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      audioTags: json['audioTags'] as Map<String, dynamic>?,
      additionalFile: json['additionalFile'] as bool?,
      replaceExistingFiles: json['replaceExistingFiles'] as bool?,
      disableReleaseSwitching: json['disableReleaseSwitching'] as bool?,
    );

Map<String, dynamic> _$ReadarrManualImportToJson(ReadarrManualImport instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('path', instance.path);
  writeNotNull('name', instance.name);
  writeNotNull('size', instance.size);
  writeNotNull('author', instance.author?.toJson());
  writeNotNull('book', instance.book?.toJson());
  writeNotNull('foreignEditionId', instance.foreignEditionId);
  writeNotNull('quality', instance.quality?.toJson());
  writeNotNull('qualityWeight', instance.qualityWeight);
  writeNotNull('downloadId', instance.downloadId);
  writeNotNull('rejections', instance.rejections);
  writeNotNull('audioTags', instance.audioTags);
  writeNotNull('additionalFile', instance.additionalFile);
  writeNotNull('replaceExistingFiles', instance.replaceExistingFiles);
  writeNotNull('disableReleaseSwitching', instance.disableReleaseSwitching);
  return val;
}
