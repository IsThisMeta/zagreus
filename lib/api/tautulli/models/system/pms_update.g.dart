// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pms_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliPMSUpdate _$TautulliPMSUpdateFromJson(Map<String, dynamic> json) =>
    TautulliPMSUpdate(
      updateAvailable:
          TautulliUtilities.ensureBooleanFromJson(json['update_available']),
      platform: TautulliUtilities.ensureStringFromJson(json['platform']),
      releaseDate:
          TautulliUtilities.millisecondsDateTimeFromJson(json['release_date']),
      version: TautulliUtilities.ensureStringFromJson(json['version']),
      requirements:
          TautulliUtilities.ensureStringFromJson(json['requirements']),
      extraInfo: TautulliUtilities.ensureStringFromJson(json['extra_info']),
      changelogAdded: TautulliPMSUpdate._releaseNotesFromJson(
          json['changelog_added'] as String?),
      changelogFixed: TautulliPMSUpdate._releaseNotesFromJson(
          json['changelog_fixed'] as String?),
      label: TautulliUtilities.ensureStringFromJson(json['label']),
      distro: TautulliUtilities.ensureStringFromJson(json['distro']),
      distroBuild: TautulliUtilities.ensureStringFromJson(json['distro_build']),
      downloadUrl: TautulliUtilities.ensureStringFromJson(json['download_url']),
    );

Map<String, dynamic> _$TautulliPMSUpdateToJson(TautulliPMSUpdate instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('update_available', instance.updateAvailable);
  writeNotNull('platform', instance.platform);
  writeNotNull('release_date', instance.releaseDate?.toIso8601String());
  writeNotNull('version', instance.version);
  writeNotNull('requirements', instance.requirements);
  writeNotNull('extra_info', instance.extraInfo);
  writeNotNull('changelog_added',
      TautulliPMSUpdate._releaseNotesToJson(instance.changelogAdded));
  writeNotNull('changelog_fixed',
      TautulliPMSUpdate._releaseNotesToJson(instance.changelogFixed));
  writeNotNull('label', instance.label);
  writeNotNull('distro', instance.distro);
  writeNotNull('distro_build', instance.distroBuild);
  writeNotNull('download_url', instance.downloadUrl);
  return val;
}
