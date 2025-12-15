// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_ip_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliUserIPRecord _$TautulliUserIPRecordFromJson(
        Map<String, dynamic> json) =>
    TautulliUserIPRecord(
      historyRowId:
          TautulliUtilities.ensureIntegerFromJson(json['history_row_id']),
      lastSeen:
          TautulliUtilities.millisecondsDateTimeFromJson(json['last_seen']),
      firstSeen:
          TautulliUtilities.millisecondsDateTimeFromJson(json['first_seen']),
      ipAddress: TautulliUtilities.ensureStringFromJson(json['ip_address']),
      playCount: TautulliUtilities.ensureIntegerFromJson(json['play_count']),
      platform: TautulliUtilities.ensureStringFromJson(json['platform']),
      player: TautulliUtilities.ensureStringFromJson(json['player']),
      lastPlayed: TautulliUtilities.ensureStringFromJson(json['last_played']),
      ratingKey: TautulliUtilities.ensureIntegerFromJson(json['rating_key']),
      thumb: TautulliUtilities.ensureStringFromJson(json['thumb']),
      mediaType:
          TautulliUtilities.mediaTypeFromJson(json['media_type'] as String?),
      parentTitle: TautulliUtilities.ensureStringFromJson(json['parent_title']),
      year: TautulliUtilities.ensureIntegerFromJson(json['year']),
      mediaIndex: TautulliUtilities.ensureIntegerFromJson(json['media_index']),
      parentMediaIndex:
          TautulliUtilities.ensureIntegerFromJson(json['parent_media_index']),
      live: TautulliUtilities.ensureBooleanFromJson(json['live']),
      originallyAvailableAt: TautulliUtilities.ensureStringFromJson(
          json['originally_available_at']),
      guid: TautulliUtilities.ensureStringFromJson(json['guid']),
      friendlyName:
          TautulliUtilities.ensureStringFromJson(json['friendly_name']),
      userId: TautulliUtilities.ensureIntegerFromJson(json['user_id']),
      transcodedecision: TautulliUtilities.transcodeDecisionFromJson(
          json['transcode_decision'] as String?),
    );

Map<String, dynamic> _$TautulliUserIPRecordToJson(
    TautulliUserIPRecord instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('history_row_id', instance.historyRowId);
  writeNotNull('last_seen', instance.lastSeen?.toIso8601String());
  writeNotNull('first_seen', instance.firstSeen?.toIso8601String());
  writeNotNull('ip_address', instance.ipAddress);
  writeNotNull('play_count', instance.playCount);
  writeNotNull('platform', instance.platform);
  writeNotNull('player', instance.player);
  writeNotNull('last_played', instance.lastPlayed);
  writeNotNull('rating_key', instance.ratingKey);
  writeNotNull('thumb', instance.thumb);
  writeNotNull(
      'media_type', TautulliUtilities.mediaTypeToJson(instance.mediaType));
  writeNotNull('parent_title', instance.parentTitle);
  writeNotNull('year', instance.year);
  writeNotNull('media_index', instance.mediaIndex);
  writeNotNull('parent_media_index', instance.parentMediaIndex);
  writeNotNull('live', instance.live);
  writeNotNull('originally_available_at', instance.originallyAvailableAt);
  writeNotNull('guid', instance.guid);
  writeNotNull('friendly_name', instance.friendlyName);
  writeNotNull('user_id', instance.userId);
  writeNotNull('transcode_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.transcodedecision));
  return val;
}
