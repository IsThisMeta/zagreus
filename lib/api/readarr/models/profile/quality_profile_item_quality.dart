import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'quality_profile_item_quality.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrQualityProfileItemQuality {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  ReadarrQualityProfileItemQuality({
    this.id,
    this.name,
  });

  factory ReadarrQualityProfileItemQuality.fromJson(Map<String, dynamic> json) =>
      _$ReadarrQualityProfileItemQualityFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrQualityProfileItemQualityToJson(this);

  @override
  String toString() => json.encode(toJson());
}
