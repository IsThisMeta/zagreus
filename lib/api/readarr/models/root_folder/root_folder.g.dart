// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrRootFolder _$ReadarrRootFolderFromJson(Map<String, dynamic> json) =>
    ReadarrRootFolder(
      id: (json['id'] as num?)?.toInt(),
      path: json['path'] as String?,
      accessible: json['accessible'] as bool?,
      freeSpace: (json['freeSpace'] as num?)?.toInt(),
      totalSpace: (json['totalSpace'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReadarrRootFolderToJson(ReadarrRootFolder instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('path', instance.path);
  writeNotNull('accessible', instance.accessible);
  writeNotNull('freeSpace', instance.freeSpace);
  writeNotNull('totalSpace', instance.totalSpace);
  return val;
}
