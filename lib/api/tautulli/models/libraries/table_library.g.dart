// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliTableLibrary _$TautulliTableLibraryFromJson(
        Map<String, dynamic> json) =>
    TautulliTableLibrary(
      rowId: TautulliUtilities.ensureIntegerFromJson(json['row_id']),
      serverId: TautulliUtilities.ensureStringFromJson(json['server_id']),
      sectionId: TautulliUtilities.ensureIntegerFromJson(json['section_id']),
      sectionName: TautulliUtilities.ensureStringFromJson(json['section_name']),
      sectionType: TautulliUtilities.sectionTypeFromJson(
          json['section_type'] as String?),
      count: TautulliUtilities.ensureIntegerFromJson(json['count']),
      parentCount:
          TautulliUtilities.ensureIntegerFromJson(json['parent_count']),
      childCount: TautulliUtilities.ensureIntegerFromJson(json['child_count']),
      libraryArt: TautulliUtilities.ensureStringFromJson(json['library_art']),
      libraryThumb:
          TautulliUtilities.ensureStringFromJson(json['library_thumb']),
      plays: TautulliUtilities.ensureIntegerFromJson(json['plays']),
      duration: TautulliUtilities.secondsDurationFromJson(json['duration']),
      lastAccessed:
          TautulliUtilities.millisecondsDateTimeFromJson(json['last_accessed']),
      historyRowId:
          TautulliUtilities.ensureIntegerFromJson(json['history_row_id']),
      lastPlayed: TautulliUtilities.ensureStringFromJson(json['last_played']),
      ratingKey: TautulliUtilities.ensureIntegerFromJson(json['rating_key']),
      mediaType:
          TautulliUtilities.mediaTypeFromJson(json['media_type'] as String?),
      thumb: TautulliUtilities.ensureStringFromJson(json['thumb']),
      parentTitle: TautulliUtilities.ensureStringFromJson(json['parent_title']),
      year: TautulliUtilities.ensureIntegerFromJson(json['year']),
      mediaIndex: TautulliUtilities.ensureIntegerFromJson(json['media_index']),
      parentMediaIndex:
          TautulliUtilities.ensureIntegerFromJson(json['parent_media_index']),
      contentRating:
          TautulliUtilities.ensureStringFromJson(json['content_rating']),
      labels: TautulliUtilities.ensureStringListFromJson(json['labels']),
      live: TautulliUtilities.ensureBooleanFromJson(json['live']),
      originallyAvailableAt: TautulliUtilities.ensureStringFromJson(
          json['originally_available_at']),
      guid: TautulliUtilities.ensureStringFromJson(json['guid']),
      doNotify: TautulliUtilities.ensureBooleanFromJson(json['do_notify']),
      doNotifyCreated:
          TautulliUtilities.ensureBooleanFromJson(json['do_notify_created']),
      isActive: TautulliUtilities.ensureBooleanFromJson(json['is_active']),
      keepHistory:
          TautulliUtilities.ensureBooleanFromJson(json['keep_history']),
    );

Map<String, dynamic> _$TautulliTableLibraryToJson(
    TautulliTableLibrary instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('row_id', instance.rowId);
  writeNotNull('server_id', instance.serverId);
  writeNotNull('section_id', instance.sectionId);
  writeNotNull('section_name', instance.sectionName);
  writeNotNull('section_type',
      TautulliUtilities.sectionTypeToJson(instance.sectionType));
  writeNotNull('count', instance.count);
  writeNotNull('parent_count', instance.parentCount);
  writeNotNull('child_count', instance.childCount);
  writeNotNull('library_thumb', instance.libraryThumb);
  writeNotNull('library_art', instance.libraryArt);
  writeNotNull('plays', instance.plays);
  writeNotNull('duration', instance.duration?.inMicroseconds);
  writeNotNull('last_accessed', instance.lastAccessed?.toIso8601String());
  writeNotNull('history_row_id', instance.historyRowId);
  writeNotNull('last_played', instance.lastPlayed);
  writeNotNull('rating_key', instance.ratingKey);
  writeNotNull(
      'media_type', TautulliUtilities.mediaTypeToJson(instance.mediaType));
  writeNotNull('thumb', instance.thumb);
  writeNotNull('parent_title', instance.parentTitle);
  writeNotNull('year', instance.year);
  writeNotNull('media_index', instance.mediaIndex);
  writeNotNull('parent_media_index', instance.parentMediaIndex);
  writeNotNull('content_rating', instance.contentRating);
  writeNotNull('labels', instance.labels);
  writeNotNull('live', instance.live);
  writeNotNull('originally_available_at', instance.originallyAvailableAt);
  writeNotNull('guid', instance.guid);
  writeNotNull('do_notify', instance.doNotify);
  writeNotNull('do_notify_created', instance.doNotifyCreated);
  writeNotNull('keep_history', instance.keepHistory);
  writeNotNull('is_active', instance.isActive);
  return val;
}
