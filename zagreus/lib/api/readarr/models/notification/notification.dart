import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrNotification {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'fields')
  List<Map<String, dynamic>>? fields;

  @JsonKey(name: 'implementationName')
  String? implementationName;

  @JsonKey(name: 'implementation')
  String? implementation;

  @JsonKey(name: 'configContract')
  String? configContract;

  @JsonKey(name: 'infoLink')
  String? infoLink;

  @JsonKey(name: 'tags')
  List<int>? tags;

  ReadarrNotification({
    this.id,
    this.name,
    this.fields,
    this.implementationName,
    this.implementation,
    this.configContract,
    this.infoLink,
    this.tags,
  });

  factory ReadarrNotification.fromJson(Map<String, dynamic> json) =>
      _$ReadarrNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrNotificationToJson(this);

  @override
  String toString() => json.encode(toJson());
}
