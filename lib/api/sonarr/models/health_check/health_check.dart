import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/sonarr/types.dart';
import 'package:zagreus/api/sonarr/utilities.dart';

part 'health_check.g.dart';

/// Model for health check details from Sonarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrHealthCheck {
  @JsonKey(name: 'source')
  String? source;

  @JsonKey(
      name: 'type',
      toJson: SonarrUtilities.healthCheckTypeToJson,
      fromJson: SonarrUtilities.healthCheckTypeFromJson)
  SonarrHealthCheckType? type;

  @JsonKey(name: 'message')
  String? message;

  @JsonKey(name: 'wikiUrl')
  String? wikiUrl;

  SonarrHealthCheck({
    this.source,
    this.type,
    this.message,
    this.wikiUrl,
  });

  /// Returns a JSON-encoded string version of this object.
  @override
  String toString() => json.encode(this.toJson());

  /// Deserialize a JSON map to a [SonarrHealthCheck] object.
  factory SonarrHealthCheck.fromJson(Map<String, dynamic> json) =>
      _$SonarrHealthCheckFromJson(json);

  /// Serialize a [SonarrHealthCheck] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrHealthCheckToJson(this);
}
