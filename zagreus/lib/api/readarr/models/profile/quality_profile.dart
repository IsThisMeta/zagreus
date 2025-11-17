import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/modules/readarr.dart';

part 'quality_profile.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrQualityProfile {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'upgradeAllowed')
  bool? upgradeAllowed;

  @JsonKey(name: 'cutoff')
  int? cutoff;

  @JsonKey(name: 'items')
  List<ReadarrQualityProfileItem>? items;

  ReadarrQualityProfile({
    this.id,
    this.name,
    this.upgradeAllowed,
    this.cutoff,
    this.items,
  });

  factory ReadarrQualityProfile.fromJson(Map<String, dynamic> json) =>
      _$ReadarrQualityProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrQualityProfileToJson(this);

  @override
  String toString() => json.encode(toJson());
}
