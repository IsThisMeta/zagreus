// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonarrFileSystemFile _$SonarrFileSystemFileFromJson(
        Map<String, dynamic> json) =>
    SonarrFileSystemFile(
      type: json['type'] as String?,
      name: json['name'] as String?,
      path: json['path'] as String?,
      extension: json['extension'] as String?,
      size: (json['size'] as num?)?.toInt(),
      lastModified:
          SonarrUtilities.dateTimeFromJson(json['lastModified'] as String?),
    );

Map<String, dynamic> _$SonarrFileSystemFileToJson(
    SonarrFileSystemFile instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', instance.type);
  writeNotNull('name', instance.name);
  writeNotNull('path', instance.path);
  writeNotNull('extension', instance.extension);
  writeNotNull('size', instance.size);
  writeNotNull(
      'lastModified', SonarrUtilities.dateTimeToJson(instance.lastModified));
  return val;
}
