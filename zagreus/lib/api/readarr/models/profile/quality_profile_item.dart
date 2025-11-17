import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/modules/readarr.dart';

part 'quality_profile_item.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrQualityProfileItem {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'quality')
  ReadarrQualityProfileItemQuality? quality;

  @JsonKey(name: 'items')
  List<ReadarrQualityProfileItem>? items;

  @JsonKey(name: 'allowed')
  bool? allowed;

  ReadarrQualityProfileItem({
    this.id,
    this.name,
    this.quality,
    this.items,
    this.allowed,
  });

  factory ReadarrQualityProfileItem.fromJson(Map<String, dynamic> json) =>
      _$ReadarrQualityProfileItemFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrQualityProfileItemToJson(this);

  @override
  String toString() => json.encode(toJson());
}
