import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'image.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrImage {
  @JsonKey(name: 'url')
  String? url;

  @JsonKey(name: 'coverType')
  String? coverType;

  @JsonKey(name: 'extension')
  String? extension;

  ReadarrImage({
    this.url,
    this.coverType,
    this.extension,
  });

  factory ReadarrImage.fromJson(Map<String, dynamic> json) =>
      _$ReadarrImageFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrImageToJson(this);

  @override
  String toString() => json.encode(toJson());
}
