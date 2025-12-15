// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliVideoStream _$TautulliVideoStreamFromJson(Map<String, dynamic> json) =>
    TautulliVideoStream(
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      type: TautulliUtilities.ensureIntegerFromJson(json['type']),
      videoCodec: TautulliUtilities.ensureStringFromJson(json['video_codec']),
      videoCodecLevel:
          TautulliUtilities.ensureStringFromJson(json['video_codec_level']),
      videoBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['video_bitrate']),
      videoBitDepth:
          TautulliUtilities.ensureIntegerFromJson(json['video_bit_depth']),
      videoChromaSubsampling: TautulliUtilities.ensureStringFromJson(
          json['video_chroma_subsampling']),
      videoColorPrimaries:
          TautulliUtilities.ensureStringFromJson(json['video_color_primaries']),
      videoColorRange:
          TautulliUtilities.ensureStringFromJson(json['video_color_range']),
      videoColorSpace:
          TautulliUtilities.ensureStringFromJson(json['video_color_space']),
      videoColorTRC:
          TautulliUtilities.ensureStringFromJson(json['video_color_trc']),
      videoFrameRate:
          TautulliUtilities.ensureDoubleFromJson(json['video_frame_rate']),
      videoRefFrames:
          TautulliUtilities.ensureIntegerFromJson(json['video_ref_frames']),
      videoHeight:
          TautulliUtilities.ensureIntegerFromJson(json['video_height']),
      videoWidth: TautulliUtilities.ensureIntegerFromJson(json['video_width']),
      videoLanguage:
          TautulliUtilities.ensureStringFromJson(json['video_language']),
      videoLanguageCode:
          TautulliUtilities.ensureStringFromJson(json['video_language_code']),
      videoProfile:
          TautulliUtilities.ensureStringFromJson(json['video_profile']),
      videoScanType:
          TautulliUtilities.ensureStringFromJson(json['video_scan_type']),
      selected: TautulliUtilities.ensureBooleanFromJson(json['selected']),
    );

Map<String, dynamic> _$TautulliVideoStreamToJson(TautulliVideoStream instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('type', instance.type);
  writeNotNull('video_codec', instance.videoCodec);
  writeNotNull('video_codec_level', instance.videoCodecLevel);
  writeNotNull('video_bitrate', instance.videoBitrate);
  writeNotNull('video_bit_depth', instance.videoBitDepth);
  writeNotNull('video_chroma_subsampling', instance.videoChromaSubsampling);
  writeNotNull('video_color_primaries', instance.videoColorPrimaries);
  writeNotNull('video_color_range', instance.videoColorRange);
  writeNotNull('video_color_space', instance.videoColorSpace);
  writeNotNull('video_color_trc', instance.videoColorTRC);
  writeNotNull('video_frame_rate', instance.videoFrameRate);
  writeNotNull('video_ref_frames', instance.videoRefFrames);
  writeNotNull('video_height', instance.videoHeight);
  writeNotNull('video_width', instance.videoWidth);
  writeNotNull('video_language', instance.videoLanguage);
  writeNotNull('video_language_code', instance.videoLanguageCode);
  writeNotNull('video_profile', instance.videoProfile);
  writeNotNull('video_scan_type', instance.videoScanType);
  writeNotNull('selected', instance.selected);
  return val;
}
