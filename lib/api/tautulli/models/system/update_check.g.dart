// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliUpdateCheck _$TautulliUpdateCheckFromJson(Map<String, dynamic> json) =>
    TautulliUpdateCheck(
      update: TautulliUtilities.ensureBooleanFromJson(json['update']),
      release: TautulliUtilities.ensureBooleanFromJson(json['release']),
      currentRelease:
          TautulliUtilities.ensureStringFromJson(json['current_release']),
      latestRelease:
          TautulliUtilities.ensureStringFromJson(json['latest_release']),
      currentVersion:
          TautulliUtilities.ensureStringFromJson(json['current_version']),
      latestVersion:
          TautulliUtilities.ensureStringFromJson(json['latest_version']),
      commitsBehind:
          TautulliUtilities.ensureIntegerFromJson(json['commits_behind']),
      compareUrl: TautulliUtilities.ensureStringFromJson(json['compare_url']),
      releaseUrl: TautulliUtilities.ensureStringFromJson(json['release_url']),
      installType: TautulliUtilities.ensureStringFromJson(json['install_type']),
    );

Map<String, dynamic> _$TautulliUpdateCheckToJson(TautulliUpdateCheck instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('update', instance.update);
  writeNotNull('release', instance.release);
  writeNotNull('current_release', instance.currentRelease);
  writeNotNull('latest_release', instance.latestRelease);
  writeNotNull('current_version', instance.currentVersion);
  writeNotNull('latest_version', instance.latestVersion);
  writeNotNull('commits_behind', instance.commitsBehind);
  writeNotNull('compare_url', instance.compareUrl);
  writeNotNull('release_url', instance.releaseUrl);
  writeNotNull('install_type', instance.installType);
  return val;
}
