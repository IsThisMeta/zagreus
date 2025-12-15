// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_file_media_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrBookFileMediaInfo _$ReadarrBookFileMediaInfoFromJson(
        Map<String, dynamic> json) =>
    ReadarrBookFileMediaInfo(
      audioFormat: json['audioFormat'] as String?,
      audioBitrate: (json['audioBitrate'] as num?)?.toInt(),
      audioChannels: (json['audioChannels'] as num?)?.toDouble(),
      audioBits: (json['audioBits'] as num?)?.toInt(),
      audioSampleRate: (json['audioSampleRate'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReadarrBookFileMediaInfoToJson(
    ReadarrBookFileMediaInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('audioFormat', instance.audioFormat);
  writeNotNull('audioBitrate', instance.audioBitrate);
  writeNotNull('audioChannels', instance.audioChannels);
  writeNotNull('audioBits', instance.audioBits);
  writeNotNull('audioSampleRate', instance.audioSampleRate);
  return val;
}
