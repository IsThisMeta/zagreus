import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'quality_profile_cutoff.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrQualityProfileCutoff {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  ReadarrQualityProfileCutoff({
    this.id,
    this.name,
  });

  factory ReadarrQualityProfileCutoff.fromJson(Map<String, dynamic> json) =>
      _$ReadarrQualityProfileCutoffFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrQualityProfileCutoffToJson(this);

  @override
  String toString() => json.encode(toJson());
}
