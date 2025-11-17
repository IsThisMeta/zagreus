import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/modules/readarr.dart';

part 'command.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrCommand {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'commandName')
  String? commandName;

  @JsonKey(name: 'message')
  String? message;

  @JsonKey(name: 'body')
  ReadarrCommandBody? body;

  @JsonKey(name: 'priority')
  String? priority;

  @JsonKey(name: 'status')
  String? status;

  @JsonKey(name: 'queued')
  DateTime? queued;

  @JsonKey(name: 'started')
  DateTime? started;

  @JsonKey(name: 'ended')
  DateTime? ended;

  @JsonKey(name: 'duration')
  String? duration;

  @JsonKey(name: 'trigger')
  String? trigger;

  @JsonKey(name: 'stateChangeTime')
  DateTime? stateChangeTime;

  @JsonKey(name: 'sendUpdatesToClient')
  bool? sendUpdatesToClient;

  @JsonKey(name: 'updateScheduledTask')
  bool? updateScheduledTask;

  @JsonKey(name: 'lastExecutionTime')
  DateTime? lastExecutionTime;

  ReadarrCommand({
    this.id,
    this.name,
    this.commandName,
    this.message,
    this.body,
    this.priority,
    this.status,
    this.queued,
    this.started,
    this.ended,
    this.duration,
    this.trigger,
    this.stateChangeTime,
    this.sendUpdatesToClient,
    this.updateScheduledTask,
    this.lastExecutionTime,
  });

  factory ReadarrCommand.fromJson(Map<String, dynamic> json) =>
      _$ReadarrCommandFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrCommandToJson(this);

  @override
  String toString() => json.encode(toJson());
}
