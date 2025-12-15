// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BazarrSystemStatus _$BazarrSystemStatusFromJson(Map<String, dynamic> json) =>
    BazarrSystemStatus(
      bazarrVersion: json['bazarr_version'] as String?,
      sonarrVersion: json['sonarr_version'] as String?,
      radarrVersion: json['radarr_version'] as String?,
      operatingSystem: json['operating_system'] as String?,
      pythonVersion: json['python_version'] as String?,
      bazarrDirectory: json['bazarr_directory'] as String?,
      bazarrConfigDirectory: json['bazarr_config_directory'] as String?,
    );

Map<String, dynamic> _$BazarrSystemStatusToJson(BazarrSystemStatus instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('bazarr_version', instance.bazarrVersion);
  writeNotNull('sonarr_version', instance.sonarrVersion);
  writeNotNull('radarr_version', instance.radarrVersion);
  writeNotNull('operating_system', instance.operatingSystem);
  writeNotNull('python_version', instance.pythonVersion);
  writeNotNull('bazarr_directory', instance.bazarrDirectory);
  writeNotNull('bazarr_config_directory', instance.bazarrConfigDirectory);
  return val;
}
