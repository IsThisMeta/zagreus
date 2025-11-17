import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'book_file_media_info.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrBookFileMediaInfo {
  @JsonKey(name: 'audioFormat')
  String? audioFormat;

  @JsonKey(name: 'audioBitrate')
  int? audioBitrate;

  @JsonKey(name: 'audioChannels')
  double? audioChannels;

  @JsonKey(name: 'audioBits')
  int? audioBits;

  @JsonKey(name: 'audioSampleRate')
  int? audioSampleRate;

  ReadarrBookFileMediaInfo({
    this.audioFormat,
    this.audioBitrate,
    this.audioChannels,
    this.audioBits,
    this.audioSampleRate,
  });

  factory ReadarrBookFileMediaInfo.fromJson(Map<String, dynamic> json) =>
      _$ReadarrBookFileMediaInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrBookFileMediaInfoToJson(this);

  @override
  String toString() => json.encode(toJson());
}
