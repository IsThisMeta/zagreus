// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_media_info_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliLibraryMediaInfoRecord _$TautulliLibraryMediaInfoRecordFromJson(
        Map<String, dynamic> json) =>
    TautulliLibraryMediaInfoRecord(
      sectionId: TautulliUtilities.ensureIntegerFromJson(json['section_id']),
      sectionType: TautulliUtilities.sectionTypeFromJson(
          json['section_type'] as String?),
      addedAt: TautulliUtilities.millisecondsDateTimeFromJson(json['added_at']),
      mediaType:
          TautulliUtilities.mediaTypeFromJson(json['media_type'] as String?),
      ratingKey: TautulliUtilities.ensureIntegerFromJson(json['rating_key']),
      parentRatingKey:
          TautulliUtilities.ensureIntegerFromJson(json['parent_rating_key']),
      grandparentRatingKey: TautulliUtilities.ensureIntegerFromJson(
          json['grandparent_rating_key']),
      title: TautulliUtilities.ensureStringFromJson(json['title']),
      sortTitle: TautulliUtilities.ensureStringFromJson(json['sort_title']),
      year: TautulliUtilities.ensureIntegerFromJson(json['year']),
      mediaIndex: TautulliUtilities.ensureIntegerFromJson(json['media_index']),
      parentMediaIndex:
          TautulliUtilities.ensureIntegerFromJson(json['parent_media_index']),
      thumb: TautulliUtilities.ensureStringFromJson(json['thumb']),
      container: TautulliUtilities.ensureStringFromJson(json['container']),
      bitrate: TautulliUtilities.ensureIntegerFromJson(json['bitrate']),
      videoCodec: TautulliUtilities.ensureStringFromJson(json['video_codec']),
      videoResolution:
          TautulliUtilities.ensureStringFromJson(json['video_resolution']),
      videoFramerate:
          TautulliUtilities.ensureStringFromJson(json['video_framerate']),
      audioCodec: TautulliUtilities.ensureStringFromJson(json['audio_codec']),
      audioChannels:
          TautulliUtilities.ensureIntegerFromJson(json['audio_channels']),
      fileSize: TautulliUtilities.ensureIntegerFromJson(json['file_size']),
      lastPlayed:
          TautulliUtilities.millisecondsDateTimeFromJson(json['last_played']),
      playCount: TautulliUtilities.ensureIntegerFromJson(json['play_count']),
    );

Map<String, dynamic> _$TautulliLibraryMediaInfoRecordToJson(
    TautulliLibraryMediaInfoRecord instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('section_id', instance.sectionId);
  writeNotNull('section_type',
      TautulliUtilities.sectionTypeToJson(instance.sectionType));
  writeNotNull('added_at', instance.addedAt?.toIso8601String());
  writeNotNull(
      'media_type', TautulliUtilities.mediaTypeToJson(instance.mediaType));
  writeNotNull('rating_key', instance.ratingKey);
  writeNotNull('parent_rating_key', instance.parentRatingKey);
  writeNotNull('grandparent_rating_key', instance.grandparentRatingKey);
  writeNotNull('title', instance.title);
  writeNotNull('sort_title', instance.sortTitle);
  writeNotNull('year', instance.year);
  writeNotNull('media_index', instance.mediaIndex);
  writeNotNull('parent_media_index', instance.parentMediaIndex);
  writeNotNull('thumb', instance.thumb);
  writeNotNull('container', instance.container);
  writeNotNull('bitrate', instance.bitrate);
  writeNotNull('video_codec', instance.videoCodec);
  writeNotNull('video_resolution', instance.videoResolution);
  writeNotNull('video_framerate', instance.videoFramerate);
  writeNotNull('audio_codec', instance.audioCodec);
  writeNotNull('audio_channels', instance.audioChannels);
  writeNotNull('file_size', instance.fileSize);
  writeNotNull('last_played', instance.lastPlayed?.toIso8601String());
  writeNotNull('play_count', instance.playCount);
  return val;
}
