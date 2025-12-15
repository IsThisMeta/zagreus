// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliMediaInfo _$TautulliMediaInfoFromJson(Map<String, dynamic> json) =>
    TautulliMediaInfo(
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      container: TautulliUtilities.ensureStringFromJson(json['container']),
      bitrate: TautulliUtilities.ensureIntegerFromJson(json['bitrate']),
      height: TautulliUtilities.ensureIntegerFromJson(json['height']),
      width: TautulliUtilities.ensureIntegerFromJson(json['width']),
      aspectRatio: TautulliUtilities.ensureDoubleFromJson(json['aspect_ratio']),
      videoCodec: TautulliUtilities.ensureStringFromJson(json['video_codec']),
      videoResolution:
          TautulliUtilities.ensureStringFromJson(json['video_resolution']),
      videoFullResolution:
          TautulliUtilities.ensureStringFromJson(json['video_full_resolution']),
      videoFramerate:
          TautulliUtilities.ensureStringFromJson(json['video_framerate']),
      videoProfile:
          TautulliUtilities.ensureStringFromJson(json['video_profile']),
      audioCodec: TautulliUtilities.ensureStringFromJson(json['audio_codec']),
      audioChannels:
          TautulliUtilities.ensureIntegerFromJson(json['audio_channels']),
      audioChannelLayout:
          TautulliUtilities.ensureStringFromJson(json['audio_channel_layout']),
      audioProfile:
          TautulliUtilities.ensureStringFromJson(json['audio_profile']),
      optimizedVersion:
          TautulliUtilities.ensureBooleanFromJson(json['optimized_version']),
      channelCallSign:
          TautulliUtilities.ensureStringFromJson(json['channel_call_sign']),
      channelIdentifier:
          TautulliUtilities.ensureStringFromJson(json['channel_identifier']),
      channelThumb:
          TautulliUtilities.ensureStringFromJson(json['channel_thumb']),
      parts: TautulliMediaInfo._partsFromJson(json['parts'] as List),
    );

Map<String, dynamic> _$TautulliMediaInfoToJson(TautulliMediaInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('container', instance.container);
  writeNotNull('bitrate', instance.bitrate);
  writeNotNull('height', instance.height);
  writeNotNull('width', instance.width);
  writeNotNull('aspect_ratio', instance.aspectRatio);
  writeNotNull('video_codec', instance.videoCodec);
  writeNotNull('video_resolution', instance.videoResolution);
  writeNotNull('video_full_resolution', instance.videoFullResolution);
  writeNotNull('video_framerate', instance.videoFramerate);
  writeNotNull('video_profile', instance.videoProfile);
  writeNotNull('audio_codec', instance.audioCodec);
  writeNotNull('audio_channels', instance.audioChannels);
  writeNotNull('audio_channel_layout', instance.audioChannelLayout);
  writeNotNull('audio_profile', instance.audioProfile);
  writeNotNull('optimized_version', instance.optimizedVersion);
  writeNotNull('channel_call_sign', instance.channelCallSign);
  writeNotNull('channel_identifier', instance.channelIdentifier);
  writeNotNull('channel_thumb', instance.channelThumb);
  writeNotNull('parts', TautulliMediaInfo._partsToJson(instance.parts));
  return val;
}
