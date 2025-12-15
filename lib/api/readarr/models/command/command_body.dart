import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'command_body.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrCommandBody {
  @JsonKey(name: 'sendUpdatesToClient')
  bool? sendUpdatesToClient;

  @JsonKey(name: 'updateScheduledTask')
  bool? updateScheduledTask;

  @JsonKey(name: 'completionMessage')
  String? completionMessage;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'trigger')
  String? trigger;

  ReadarrCommandBody({
    this.sendUpdatesToClient,
    this.updateScheduledTask,
    this.completionMessage,
    this.name,
    this.trigger,
  });

  factory ReadarrCommandBody.fromJson(Map<String, dynamic> json) =>
      _$ReadarrCommandBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrCommandBodyToJson(this);

  @override
  String toString() => json.encode(toJson());
}
