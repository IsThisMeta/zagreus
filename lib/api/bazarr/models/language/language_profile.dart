import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'language_profile.g.dart';

/// Model for language profile from Bazarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BazarrLanguageProfile {
  @JsonKey(name: 'profileId')
  int? profileId;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'items')
  List<BazarrLanguageProfileItem>? items;

  @JsonKey(name: 'cutoff')
  int? cutoff;

  BazarrLanguageProfile({
    this.profileId,
    this.name,
    this.items,
    this.cutoff,
  });

  @override
  String toString() => json.encode(this.toJson());

  factory BazarrLanguageProfile.fromJson(Map<String, dynamic> json) =>
      _$BazarrLanguageProfileFromJson(json);

  Map<String, dynamic> toJson() => _$BazarrLanguageProfileToJson(this);
}

/// Model for language profile item from Bazarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BazarrLanguageProfileItem {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'language')
  String? language;

  @JsonKey(name: 'forced')
  String? forced;

  @JsonKey(name: 'hi')
  String? hearingImpaired;

  @JsonKey(name: 'audio_exclude')
  String? audioExclude;

  BazarrLanguageProfileItem({
    this.id,
    this.language,
    this.forced,
    this.hearingImpaired,
    this.audioExclude,
  });

  @override
  String toString() => json.encode(this.toJson());

  factory BazarrLanguageProfileItem.fromJson(Map<String, dynamic> json) =>
      _$BazarrLanguageProfileItemFromJson(json);

  Map<String, dynamic> toJson() => _$BazarrLanguageProfileItemToJson(this);
}
