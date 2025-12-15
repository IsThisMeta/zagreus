import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'custom_format.g.dart';

/// Model for a custom format from Sonarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrCustomFormat {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  SonarrCustomFormat({
    this.id,
    this.name,
  });

  /// Returns a JSON-encoded string version of this object.
  @override
  String toString() => json.encode(this.toJson());

  /// Deserialize a JSON map to a [SonarrCustomFormat] object.
  factory SonarrCustomFormat.fromJson(Map<String, dynamic> json) =>
      _$SonarrCustomFormatFromJson(json);

  /// Serialize a [SonarrCustomFormat] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrCustomFormatToJson(this);
}
