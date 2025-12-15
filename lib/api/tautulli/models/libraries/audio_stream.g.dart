// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliAudioStream _$TautulliAudioStreamFromJson(Map<String, dynamic> json) =>
    TautulliAudioStream(
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      type: TautulliUtilities.ensureIntegerFromJson(json['type']),
      audioCodec: TautulliUtilities.ensureStringFromJson(json['audio_codec']),
      audioBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['audio_bitrate']),
      audioBitrateMode:
          TautulliUtilities.ensureStringFromJson(json['audio_bitrate_mode']),
      audioChannelLayout:
          TautulliUtilities.ensureStringFromJson(json['audio_channel_layout']),
      audioChannels:
          TautulliUtilities.ensureIntegerFromJson(json['audio_channels']),
      audioLanguage:
          TautulliUtilities.ensureStringFromJson(json['audio_language']),
      audioLanguageCode:
          TautulliUtilities.ensureStringFromJson(json['audio_language_code']),
      audioSampleRate:
          TautulliUtilities.ensureIntegerFromJson(json['audio_sample_rate']),
      audioProfile:
          TautulliUtilities.ensureStringFromJson(json['audio_profile']),
      selected: TautulliUtilities.ensureBooleanFromJson(json['selected']),
    );

Map<String, dynamic> _$TautulliAudioStreamToJson(TautulliAudioStream instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('type', instance.type);
  writeNotNull('audio_codec', instance.audioCodec);
  writeNotNull('audio_bitrate', instance.audioBitrate);
  writeNotNull('audio_bitrate_mode', instance.audioBitrateMode);
  writeNotNull('audio_channels', instance.audioChannels);
  writeNotNull('audio_channel_layout', instance.audioChannelLayout);
  writeNotNull('audio_sample_rate', instance.audioSampleRate);
  writeNotNull('audio_language', instance.audioLanguage);
  writeNotNull('audio_language_code', instance.audioLanguageCode);
  writeNotNull('audio_profile', instance.audioProfile);
  writeNotNull('selected', instance.selected);
  return val;
}
