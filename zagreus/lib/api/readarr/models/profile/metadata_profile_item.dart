import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'metadata_profile_item.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrMetadataProfileItem {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'allowed')
  bool? allowed;

  ReadarrMetadataProfileItem({
    this.id,
    this.name,
    this.allowed,
  });

  factory ReadarrMetadataProfileItem.fromJson(Map<String, dynamic> json) =>
      _$ReadarrMetadataProfileItemFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrMetadataProfileItemToJson(this);

  @override
  String toString() => json.encode(toJson());
}
