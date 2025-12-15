import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'status.g.dart';

/// Model for the system status from Bazarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BazarrSystemStatus {
  @JsonKey(name: 'bazarr_version')
  String? bazarrVersion;

  @JsonKey(name: 'sonarr_version')
  String? sonarrVersion;

  @JsonKey(name: 'radarr_version')
  String? radarrVersion;

  @JsonKey(name: 'operating_system')
  String? operatingSystem;

  @JsonKey(name: 'python_version')
  String? pythonVersion;

  @JsonKey(name: 'bazarr_directory')
  String? bazarrDirectory;

  @JsonKey(name: 'bazarr_config_directory')
  String? bazarrConfigDirectory;

  BazarrSystemStatus({
    this.bazarrVersion,
    this.sonarrVersion,
    this.radarrVersion,
    this.operatingSystem,
    this.pythonVersion,
    this.bazarrDirectory,
    this.bazarrConfigDirectory,
  });

  @override
  String toString() => json.encode(this.toJson());

  factory BazarrSystemStatus.fromJson(Map<String, dynamic> json) =>
      _$BazarrSystemStatusFromJson(json);

  Map<String, dynamic> toJson() => _$BazarrSystemStatusToJson(this);
}
