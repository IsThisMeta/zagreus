// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'directory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonarrFileSystemDirectory _$SonarrFileSystemDirectoryFromJson(
        Map<String, dynamic> json) =>
    SonarrFileSystemDirectory(
      type: json['type'] as String?,
      name: json['name'] as String?,
      path: json['path'] as String?,
      size: (json['size'] as num?)?.toInt(),
      lastModified:
          SonarrUtilities.dateTimeFromJson(json['lastModified'] as String?),
    );

Map<String, dynamic> _$SonarrFileSystemDirectoryToJson(
    SonarrFileSystemDirectory instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', instance.type);
  writeNotNull('name', instance.name);
  writeNotNull('path', instance.path);
  writeNotNull('size', instance.size);
  writeNotNull(
      'lastModified', SonarrUtilities.dateTimeToJson(instance.lastModified));
  return val;
}
