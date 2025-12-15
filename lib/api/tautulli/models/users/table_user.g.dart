// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliTableUser _$TautulliTableUserFromJson(Map<String, dynamic> json) =>
    TautulliTableUser(
      rowId: TautulliUtilities.ensureIntegerFromJson(json['row_id']),
      userId: TautulliUtilities.ensureIntegerFromJson(json['user_id']),
      friendlyName:
          TautulliUtilities.ensureStringFromJson(json['friendly_name']),
      userThumb: TautulliUtilities.ensureStringFromJson(json['user_thumb']),
      plays: TautulliUtilities.ensureIntegerFromJson(json['plays']),
      duration: TautulliUtilities.secondsDurationFromJson(json['duration']),
      lastSeen:
          TautulliUtilities.millisecondsDateTimeFromJson(json['last_seen']),
      lastPlayed: TautulliUtilities.ensureStringFromJson(json['last_played']),
      historyRowId:
          TautulliUtilities.ensureIntegerFromJson(json['history_row_id']),
      ipAddress: TautulliUtilities.ensureStringFromJson(json['ip_address']),
      platform: TautulliUtilities.ensureStringFromJson(json['platform']),
      player: TautulliUtilities.ensureStringFromJson(json['player']),
      ratingKey: TautulliUtilities.ensureIntegerFromJson(json['rating_key']),
      mediaType:
          TautulliUtilities.mediaTypeFromJson(json['media_type'] as String?),
      thumb: TautulliUtilities.ensureStringFromJson(json['thumb']),
      parentTitle: TautulliUtilities.ensureStringFromJson(json['parent_title']),
      year: TautulliUtilities.ensureIntegerFromJson(json['year']),
      mediaIndex: TautulliUtilities.ensureIntegerFromJson(json['media_index']),
      parentMediaIndex:
          TautulliUtilities.ensureIntegerFromJson(json['parent_media_index']),
      live: TautulliUtilities.ensureBooleanFromJson(json['live']),
      originallyAvailableAt: TautulliUtilities.ensureStringFromJson(
          json['originally_available_at']),
      guid: TautulliUtilities.ensureStringFromJson(json['guid']),
      transcodeDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['transcode_decision'] as String?),
      doNotify: TautulliUtilities.ensureBooleanFromJson(json['do_notify']),
      keepHistory:
          TautulliUtilities.ensureBooleanFromJson(json['keep_history']),
      allowGuest: TautulliUtilities.ensureBooleanFromJson(json['allow_guest']),
      isActive: TautulliUtilities.ensureBooleanFromJson(json['is_active']),
    );

Map<String, dynamic> _$TautulliTableUserToJson(TautulliTableUser instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('row_id', instance.rowId);
  writeNotNull('user_id', instance.userId);
  writeNotNull('friendly_name', instance.friendlyName);
  writeNotNull('user_thumb', instance.userThumb);
  writeNotNull('plays', instance.plays);
  writeNotNull('duration', instance.duration?.inMicroseconds);
  writeNotNull('last_seen', instance.lastSeen?.toIso8601String());
  writeNotNull('last_played', instance.lastPlayed);
  writeNotNull('history_row_id', instance.historyRowId);
  writeNotNull('ip_address', instance.ipAddress);
  writeNotNull('platform', instance.platform);
  writeNotNull('player', instance.player);
  writeNotNull('rating_key', instance.ratingKey);
  writeNotNull(
      'media_type', TautulliUtilities.mediaTypeToJson(instance.mediaType));
  writeNotNull('thumb', instance.thumb);
  writeNotNull('parent_title', instance.parentTitle);
  writeNotNull('year', instance.year);
  writeNotNull('media_index', instance.mediaIndex);
  writeNotNull('parent_media_index', instance.parentMediaIndex);
  writeNotNull('live', instance.live);
  writeNotNull('originally_available_at', instance.originallyAvailableAt);
  writeNotNull('guid', instance.guid);
  writeNotNull('transcode_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.transcodeDecision));
  writeNotNull('do_notify', instance.doNotify);
  writeNotNull('keep_history', instance.keepHistory);
  writeNotNull('allow_guest', instance.allowGuest);
  writeNotNull('is_active', instance.isActive);
  return val;
}
