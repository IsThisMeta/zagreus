import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'subtitle.g.dart';

/// Model for subtitle language information from Bazarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BazarrSubtitle {
  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'code2')
  String? code2;

  @JsonKey(name: 'code3')
  String? code3;

  @JsonKey(name: 'forced')
  bool? forced;

  @JsonKey(name: 'hi')
  bool? hearingImpaired;

  @JsonKey(name: 'path')
  String? path;

  BazarrSubtitle({
    this.name,
    this.code2,
    this.code3,
    this.forced,
    this.hearingImpaired,
    this.path,
  });

  @override
  String toString() => json.encode(this.toJson());

  factory BazarrSubtitle.fromJson(Map<String, dynamic> json) =>
      _$BazarrSubtitleFromJson(json);

  Map<String, dynamic> toJson() => _$BazarrSubtitleToJson(this);
}
