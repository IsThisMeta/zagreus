// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disk_space.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrDiskSpace _$ReadarrDiskSpaceFromJson(Map<String, dynamic> json) =>
    ReadarrDiskSpace(
      path: json['path'] as String?,
      label: json['label'] as String?,
      freeSpace: (json['freeSpace'] as num?)?.toInt(),
      totalSpace: (json['totalSpace'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReadarrDiskSpaceToJson(ReadarrDiskSpace instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('path', instance.path);
  writeNotNull('label', instance.label);
  writeNotNull('freeSpace', instance.freeSpace);
  writeNotNull('totalSpace', instance.totalSpace);
  return val;
}
