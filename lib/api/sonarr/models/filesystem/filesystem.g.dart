// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filesystem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonarrFileSystem _$SonarrFileSystemFromJson(Map<String, dynamic> json) =>
    SonarrFileSystem(
      parent: json['parent'] as String?,
      directories: (json['directories'] as List<dynamic>?)
          ?.map((e) =>
              SonarrFileSystemDirectory.fromJson(e as Map<String, dynamic>))
          .toList(),
      files: (json['files'] as List<dynamic>?)
          ?.map((e) => SonarrFileSystemFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SonarrFileSystemToJson(SonarrFileSystem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('parent', instance.parent);
  writeNotNull(
      'directories', instance.directories?.map((e) => e.toJson()).toList());
  writeNotNull('files', instance.files?.map((e) => e.toJson()).toList());
  return val;
}
