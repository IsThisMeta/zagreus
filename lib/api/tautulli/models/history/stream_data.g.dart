// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliStreamData _$TautulliStreamDataFromJson(Map<String, dynamic> json) =>
    TautulliStreamData(
      bitrate: TautulliUtilities.ensureIntegerFromJson(json['bitrate']),
      videoFullResolution:
          TautulliUtilities.ensureStringFromJson(json['video_full_resolution']),
      optimizedVersion:
          TautulliUtilities.ensureBooleanFromJson(json['optimized_version']),
      optimizedVersionProfile: TautulliUtilities.ensureStringFromJson(
          json['optimized_version_profile']),
      optimizedVersionTitle: TautulliUtilities.ensureStringFromJson(
          json['optimized_version_title']),
      syncedVersion:
          TautulliUtilities.ensureBooleanFromJson(json['synced_version']),
      syncedVersionProfile: TautulliUtilities.ensureStringFromJson(
          json['synced_version_profile']),
      container: TautulliUtilities.ensureStringFromJson(json['container']),
      videoBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['video_bitrate']),
      videoCodec: TautulliUtilities.ensureStringFromJson(json['video_codec']),
      videoHeight:
          TautulliUtilities.ensureIntegerFromJson(json['video_height']),
      videoWidth: TautulliUtilities.ensureIntegerFromJson(json['video_width']),
      videoFramerate:
          TautulliUtilities.ensureStringFromJson(json['video_framerate']),
      videoDynamicRange:
          TautulliUtilities.ensureStringFromJson(json['video_dynamic_range']),
      aspectRatio: TautulliUtilities.ensureDoubleFromJson(json['aspect_ratio']),
      audioCodec: TautulliUtilities.ensureStringFromJson(json['audio_codec']),
      audioBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['audio_bitrate']),
      audioChannels:
          TautulliUtilities.ensureIntegerFromJson(json['audio_channels']),
      subtitleCodec:
          TautulliUtilities.ensureStringFromJson(json['subtitle_codec']),
      qualityProfile:
          TautulliUtilities.ensureStringFromJson(json['quality_profile']),
      streamBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['stream_bitrate']),
      streamContainer:
          TautulliUtilities.ensureStringFromJson(json['stream_container']),
      streamContainerDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['stream_container_decision'] as String?),
      streamVideoBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['stream_video_bitrate']),
      streamVideoCodec:
          TautulliUtilities.ensureStringFromJson(json['stream_video_codec']),
      streamVideoDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['stream_video_decision'] as String?),
      streamVideoFullResolution: TautulliUtilities.ensureStringFromJson(
          json['stream_video_full_resolution']),
      streamVideoHeight:
          TautulliUtilities.ensureIntegerFromJson(json['stream_video_height']),
      streamVideoWidth:
          TautulliUtilities.ensureIntegerFromJson(json['stream_video_width']),
      streamAudioBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['stream_audio_bitrate']),
      streamAudioChannels: TautulliUtilities.ensureIntegerFromJson(
          json['stream_audio_channels']),
      streamAudioCodec:
          TautulliUtilities.ensureStringFromJson(json['stream_audio_codec']),
      streamAudioDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['stream_audio_decision'] as String?),
      streamVideoDynamicRange: TautulliUtilities.ensureStringFromJson(
          json['stream_video_dynamic_range']),
      streamVideoFramerate: TautulliUtilities.ensureStringFromJson(
          json['stream_video_framerate']),
      subtitles: TautulliUtilities.ensureBooleanFromJson(json['subtitles']),
      streamSubtitleDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['stream_subtitle_decision'] as String?),
      streamSubtitleCodec:
          TautulliUtilities.ensureStringFromJson(json['stream_subtitle_codec']),
      transcodeHardwareDecoding: TautulliUtilities.ensureBooleanFromJson(
          json['transcode_hw_decoding']),
      transcodeHardwareEncoding: TautulliUtilities.ensureBooleanFromJson(
          json['transcode_hw_encoding']),
      videoDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['audio_decision'] as String?),
      audioDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['video_decision'] as String?),
      mediaType:
          TautulliUtilities.mediaTypeFromJson(json['media_type'] as String?),
      title: TautulliUtilities.ensureStringFromJson(json['title']),
      originalTitle:
          TautulliUtilities.ensureStringFromJson(json['original_title']),
      grandparentTitle:
          TautulliUtilities.ensureStringFromJson(json['grandparent_title']),
      currentSession:
          TautulliUtilities.ensureBooleanFromJson(json['current_session']),
      preTautulli: TautulliUtilities.ensureStringFromJson(json['pre_tautulli']),
    );

Map<String, dynamic> _$TautulliStreamDataToJson(TautulliStreamData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('bitrate', instance.bitrate);
  writeNotNull('video_full_resolution', instance.videoFullResolution);
  writeNotNull('optimized_version', instance.optimizedVersion);
  writeNotNull('optimized_version_title', instance.optimizedVersionTitle);
  writeNotNull('optimized_version_profile', instance.optimizedVersionProfile);
  writeNotNull('synced_version', instance.syncedVersion);
  writeNotNull('synced_version_profile', instance.syncedVersionProfile);
  writeNotNull('container', instance.container);
  writeNotNull('video_codec', instance.videoCodec);
  writeNotNull('video_bitrate', instance.videoBitrate);
  writeNotNull('video_height', instance.videoHeight);
  writeNotNull('video_width', instance.videoWidth);
  writeNotNull('video_framerate', instance.videoFramerate);
  writeNotNull('video_dynamic_range', instance.videoDynamicRange);
  writeNotNull('aspect_ratio', instance.aspectRatio);
  writeNotNull('audio_codec', instance.audioCodec);
  writeNotNull('audio_bitrate', instance.audioBitrate);
  writeNotNull('audio_channels', instance.audioChannels);
  writeNotNull('subtitle_codec', instance.subtitleCodec);
  writeNotNull('stream_bitrate', instance.streamBitrate);
  writeNotNull(
      'stream_video_full_resolution', instance.streamVideoFullResolution);
  writeNotNull('quality_profile', instance.qualityProfile);
  writeNotNull(
      'stream_container_decision',
      TautulliUtilities.transcodeDecisionToJson(
          instance.streamContainerDecision));
  writeNotNull('stream_container', instance.streamContainer);
  writeNotNull('stream_video_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.streamVideoDecision));
  writeNotNull('stream_video_codec', instance.streamVideoCodec);
  writeNotNull('stream_video_bitrate', instance.streamVideoBitrate);
  writeNotNull('stream_video_height', instance.streamVideoHeight);
  writeNotNull('stream_video_width', instance.streamVideoWidth);
  writeNotNull('stream_video_framerate', instance.streamVideoFramerate);
  writeNotNull('stream_video_dynamic_range', instance.streamVideoDynamicRange);
  writeNotNull('stream_audio_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.streamAudioDecision));
  writeNotNull('stream_audio_codec', instance.streamAudioCodec);
  writeNotNull('stream_audio_bitrate', instance.streamAudioBitrate);
  writeNotNull('stream_audio_channels', instance.streamAudioChannels);
  writeNotNull('subtitles', instance.subtitles);
  writeNotNull(
      'stream_subtitle_decision',
      TautulliUtilities.transcodeDecisionToJson(
          instance.streamSubtitleDecision));
  writeNotNull('stream_subtitle_codec', instance.streamSubtitleCodec);
  writeNotNull('transcode_hw_decoding', instance.transcodeHardwareDecoding);
  writeNotNull('transcode_hw_encoding', instance.transcodeHardwareEncoding);
  writeNotNull('video_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.audioDecision));
  writeNotNull('audio_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.videoDecision));
  writeNotNull(
      'media_type', TautulliUtilities.mediaTypeToJson(instance.mediaType));
  writeNotNull('title', instance.title);
  writeNotNull('grandparent_title', instance.grandparentTitle);
  writeNotNull('original_title', instance.originalTitle);
  writeNotNull('current_session', instance.currentSession);
  writeNotNull('pre_tautulli', instance.preTautulli);
  return val;
}
