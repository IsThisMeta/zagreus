// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_import_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrManualImportItem _$ReadarrManualImportItemFromJson(
        Map<String, dynamic> json) =>
    ReadarrManualImportItem(
      id: (json['id'] as num?)?.toInt(),
      path: json['path'] as String?,
      name: json['name'] as String?,
      size: (json['size'] as num?)?.toInt(),
      authorId: (json['authorId'] as num?)?.toInt(),
      bookId: (json['bookId'] as num?)?.toInt(),
      foreignEditionId: json['foreignEditionId'] as String?,
      quality: json['quality'] as Map<String, dynamic>?,
      releaseGroup: json['releaseGroup'] as String?,
      downloadId: json['downloadId'] as String?,
      rejections: (json['rejections'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$ReadarrManualImportItemToJson(
    ReadarrManualImportItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('path', instance.path);
  writeNotNull('name', instance.name);
  writeNotNull('size', instance.size);
  writeNotNull('authorId', instance.authorId);
  writeNotNull('bookId', instance.bookId);
  writeNotNull('foreignEditionId', instance.foreignEditionId);
  writeNotNull('quality', instance.quality);
  writeNotNull('releaseGroup', instance.releaseGroup);
  writeNotNull('downloadId', instance.downloadId);
  writeNotNull('rejections', instance.rejections);
  return val;
}
