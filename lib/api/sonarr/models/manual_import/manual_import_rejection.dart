import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'manual_import_rejection.g.dart';

/// Model for a manual import rejection reason.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrManualImportRejection {
  @JsonKey(name: 'reason')
  String? reason;

  @JsonKey(name: 'type')
  String? type;

  SonarrManualImportRejection({
    this.reason,
    this.type,
  });

  /// Returns a JSON-encoded string version of this object.
  @override
  String toString() => json.encode(this.toJson());

  /// Deserialize a JSON map to a [SonarrManualImportRejection] object.
  factory SonarrManualImportRejection.fromJson(Map<String, dynamic> json) =>
      _$SonarrManualImportRejectionFromJson(json);

  /// Serialize a [SonarrManualImportRejection] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrManualImportRejectionToJson(this);
}
