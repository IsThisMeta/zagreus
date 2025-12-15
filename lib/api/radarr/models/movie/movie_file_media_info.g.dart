// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_file_media_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RadarrMovieFileMediaInfo _$RadarrMovieFileMediaInfoFromJson(
        Map<String, dynamic> json) =>
    RadarrMovieFileMediaInfo(
      audioBitrate: (json['audioBitrate'] as num?)?.toInt(),
      audioChannels: (json['audioChannels'] as num?)?.toDouble(),
      audioCodec: json['audioCodec'] as String?,
      audioLanguages: json['audioLanguages'] as String?,
      audioStreamCount: (json['audioStreamCount'] as num?)?.toInt(),
      videoBitDepth: (json['videoBitDepth'] as num?)?.toInt(),
      videoBitrate: (json['videoBitrate'] as num?)?.toInt(),
      videoCodec: json['videoCodec'] as String?,
      videoDynamicRangeType: json['videoDynamicRangeType'] as String?,
      videoFps: (json['videoFps'] as num?)?.toDouble(),
      resolution: json['resolution'] as String?,
      runTime: json['runTime'] as String?,
      scanType: json['scanType'] as String?,
      subtitles: json['subtitles'] as String?,
    );

Map<String, dynamic> _$RadarrMovieFileMediaInfoToJson(
    RadarrMovieFileMediaInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('audioBitrate', instance.audioBitrate);
  writeNotNull('audioChannels', instance.audioChannels);
  writeNotNull('audioCodec', instance.audioCodec);
  writeNotNull('audioLanguages', instance.audioLanguages);
  writeNotNull('audioStreamCount', instance.audioStreamCount);
  writeNotNull('videoBitDepth', instance.videoBitDepth);
  writeNotNull('videoBitrate', instance.videoBitrate);
  writeNotNull('videoCodec', instance.videoCodec);
  writeNotNull('videoDynamicRangeType', instance.videoDynamicRangeType);
  writeNotNull('videoFps', instance.videoFps);
  writeNotNull('resolution', instance.resolution);
  writeNotNull('runTime', instance.runTime);
  writeNotNull('scanType', instance.scanType);
  writeNotNull('subtitles', instance.subtitles);
  return val;
}
