// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtitle_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliSubtitleStream _$TautulliSubtitleStreamFromJson(
        Map<String, dynamic> json) =>
    TautulliSubtitleStream(
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      type: TautulliUtilities.ensureIntegerFromJson(json['type']),
      subtitleCodec:
          TautulliUtilities.ensureStringFromJson(json['subtitle_codec']),
      subtitleContainer:
          TautulliUtilities.ensureStringFromJson(json['subtitle_container']),
      subtitleForced:
          TautulliUtilities.ensureBooleanFromJson(json['subtitle_forced']),
      subtitleFormat:
          TautulliUtilities.ensureStringFromJson(json['subtitle_format']),
      subtitleLanguage:
          TautulliUtilities.ensureStringFromJson(json['subtitle_language']),
      subtitleLanguageCode: TautulliUtilities.ensureStringFromJson(
          json['subtitle_language_code']),
      subtitleLocation:
          TautulliUtilities.ensureStringFromJson(json['subtitle_location']),
      selected: TautulliUtilities.ensureBooleanFromJson(json['selected']),
    );

Map<String, dynamic> _$TautulliSubtitleStreamToJson(
    TautulliSubtitleStream instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('type', instance.type);
  writeNotNull('subtitle_codec', instance.subtitleCodec);
  writeNotNull('subtitle_container', instance.subtitleContainer);
  writeNotNull('subtitle_format', instance.subtitleFormat);
  writeNotNull('subtitle_forced', instance.subtitleForced);
  writeNotNull('subtitle_location', instance.subtitleLocation);
  writeNotNull('subtitle_language', instance.subtitleLanguage);
  writeNotNull('subtitle_language_code', instance.subtitleLanguageCode);
  writeNotNull('selected', instance.selected);
  return val;
}
