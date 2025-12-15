// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_info_parts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliMediaInfoParts _$TautulliMediaInfoPartsFromJson(
        Map<String, dynamic> json) =>
    TautulliMediaInfoParts(
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      file: TautulliUtilities.ensureStringFromJson(json['file']),
      fileSize: TautulliUtilities.ensureIntegerFromJson(json['file_size']),
      indexes: TautulliUtilities.ensureBooleanFromJson(json['indexes']),
      selected: TautulliUtilities.ensureBooleanFromJson(json['selected']),
      videoStreams: TautulliMediaInfoParts._videoStreamToObjectArray(
          json['video_streams'] as List),
      audioStreams: TautulliMediaInfoParts._audioStreamToObjectArray(
          json['audio_streams'] as List),
      subtitleStreams: TautulliMediaInfoParts._subtitleStreamToObjectArray(
          json['subtitle_streams'] as List),
    );

Map<String, dynamic> _$TautulliMediaInfoPartsToJson(
    TautulliMediaInfoParts instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('file', instance.file);
  writeNotNull('file_size', instance.fileSize);
  writeNotNull('indexes', instance.indexes);
  writeNotNull('selected', instance.selected);
  writeNotNull('video_streams',
      TautulliMediaInfoParts._videoStreamToMap(instance.videoStreams));
  writeNotNull('audio_streams',
      TautulliMediaInfoParts._audioStreamToMap(instance.audioStreams));
  writeNotNull('subtitle_streams',
      TautulliMediaInfoParts._subtitleStreamToMap(instance.subtitleStreams));
  return val;
}
