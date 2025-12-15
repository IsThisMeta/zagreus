// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliHistoryRecord _$TautulliHistoryRecordFromJson(
        Map<String, dynamic> json) =>
    TautulliHistoryRecord(
      referenceId:
          TautulliUtilities.ensureIntegerFromJson(json['reference_id']),
      rowId: TautulliUtilities.ensureIntegerFromJson(json['row_id']),
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      date: TautulliUtilities.millisecondsDateTimeFromJson(json['date']),
      started: TautulliUtilities.millisecondsDateTimeFromJson(json['started']),
      stopped: TautulliUtilities.millisecondsDateTimeFromJson(json['stopped']),
      duration: TautulliUtilities.secondsDurationFromJson(json['duration']),
      pausedCounter:
          TautulliUtilities.secondsDurationFromJson(json['paused_counter']),
      userId: TautulliUtilities.ensureIntegerFromJson(json['user_id']),
      user: TautulliUtilities.ensureStringFromJson(json['user']),
      friendlyName:
          TautulliUtilities.ensureStringFromJson(json['friendly_name']),
      platform: TautulliUtilities.ensureStringFromJson(json['platform']),
      player: TautulliUtilities.ensureStringFromJson(json['player']),
      product: TautulliUtilities.ensureStringFromJson(json['product']),
      ipAddress: TautulliUtilities.ensureStringFromJson(json['ip_address']),
      live: TautulliUtilities.ensureBooleanFromJson(json['live']),
      mediaType:
          TautulliUtilities.mediaTypeFromJson(json['media_type'] as String?),
      ratingKey: TautulliUtilities.ensureIntegerFromJson(json['rating_key']),
      parentRatingKey:
          TautulliUtilities.ensureIntegerFromJson(json['parent_rating_key']),
      grandparentRatingKey: TautulliUtilities.ensureIntegerFromJson(
          json['grandparent_rating_key']),
      fullTitle: TautulliUtilities.ensureStringFromJson(json['full_title']),
      title: TautulliUtilities.ensureStringFromJson(json['title']),
      parentTitle: TautulliUtilities.ensureStringFromJson(json['parent_title']),
      grandparentTitle:
          TautulliUtilities.ensureStringFromJson(json['grandparent_title']),
      originalTitle:
          TautulliUtilities.ensureStringFromJson(json['original_title']),
      year: TautulliUtilities.ensureIntegerFromJson(json['year']),
      mediaIndex: TautulliUtilities.ensureIntegerFromJson(json['media_index']),
      parentMediaIndex:
          TautulliUtilities.ensureIntegerFromJson(json['parent_media_index']),
      thumb: TautulliUtilities.ensureStringFromJson(json['thumb']),
      originallyAvailableAt: TautulliUtilities.ensureStringFromJson(
          json['originally_available_at']),
      guid: TautulliUtilities.ensureStringFromJson(json['guid']),
      transcodeDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['transcode_decision'] as String?),
      percentComplete:
          TautulliUtilities.ensureIntegerFromJson(json['percent_complete']),
      watchedStatus: TautulliUtilities.watchedStatusFromJson(
          json['watched_status'] as num?),
      groupCount: TautulliUtilities.ensureIntegerFromJson(json['group_count']),
      groupIds: TautulliUtilities.stringToListStringFromJson(
          json['group_ids'] as String?),
      state: TautulliUtilities.sessionStateFromJson(json['state'] as String?),
      sessionKey: TautulliUtilities.ensureIntegerFromJson(json['session_key']),
    );

Map<String, dynamic> _$TautulliHistoryRecordToJson(
    TautulliHistoryRecord instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('reference_id', instance.referenceId);
  writeNotNull('row_id', instance.rowId);
  writeNotNull('id', instance.id);
  writeNotNull('date', instance.date?.toIso8601String());
  writeNotNull('started', instance.started?.toIso8601String());
  writeNotNull('stopped', instance.stopped?.toIso8601String());
  writeNotNull('duration', instance.duration?.inMicroseconds);
  writeNotNull('paused_counter', instance.pausedCounter?.inMicroseconds);
  writeNotNull('user_id', instance.userId);
  writeNotNull('user', instance.user);
  writeNotNull('friendly_name', instance.friendlyName);
  writeNotNull('platform', instance.platform);
  writeNotNull('product', instance.product);
  writeNotNull('player', instance.player);
  writeNotNull('ip_address', instance.ipAddress);
  writeNotNull('live', instance.live);
  writeNotNull(
      'media_type', TautulliUtilities.mediaTypeToJson(instance.mediaType));
  writeNotNull('rating_key', instance.ratingKey);
  writeNotNull('parent_rating_key', instance.parentRatingKey);
  writeNotNull('grandparent_rating_key', instance.grandparentRatingKey);
  writeNotNull('full_title', instance.fullTitle);
  writeNotNull('title', instance.title);
  writeNotNull('parent_title', instance.parentTitle);
  writeNotNull('grandparent_title', instance.grandparentTitle);
  writeNotNull('original_title', instance.originalTitle);
  writeNotNull('year', instance.year);
  writeNotNull('media_index', instance.mediaIndex);
  writeNotNull('parent_media_index', instance.parentMediaIndex);
  writeNotNull('thumb', instance.thumb);
  writeNotNull('originally_available_at', instance.originallyAvailableAt);
  writeNotNull('guid', instance.guid);
  writeNotNull('transcode_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.transcodeDecision));
  writeNotNull('percent_complete', instance.percentComplete);
  writeNotNull('watched_status',
      TautulliUtilities.watchedStatusToJson(instance.watchedStatus));
  writeNotNull('group_count', instance.groupCount);
  writeNotNull('group_ids', instance.groupIds);
  writeNotNull('state', TautulliUtilities.sessionStateToJson(instance.state));
  writeNotNull('session_key', instance.sessionKey);
  return val;
}
