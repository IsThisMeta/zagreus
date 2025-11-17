import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'health_check.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrHealthCheck {
  @JsonKey(name: 'source')
  String? source;

  @JsonKey(name: 'type')
  String? type;

  @JsonKey(name: 'message')
  String? message;

  @JsonKey(name: 'wikiUrl')
  String? wikiUrl;

  ReadarrHealthCheck({
    this.source,
    this.type,
    this.message,
    this.wikiUrl,
  });

  factory ReadarrHealthCheck.fromJson(Map<String, dynamic> json) =>
      _$ReadarrHealthCheckFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrHealthCheckToJson(this);

  @override
  String toString() => json.encode(toJson());
}
