// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrCommand _$ReadarrCommandFromJson(Map<String, dynamic> json) =>
    ReadarrCommand(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      commandName: json['commandName'] as String?,
      message: json['message'] as String?,
      body: json['body'] == null
          ? null
          : ReadarrCommandBody.fromJson(json['body'] as Map<String, dynamic>),
      priority: json['priority'] as String?,
      status: json['status'] as String?,
      queued: json['queued'] == null
          ? null
          : DateTime.parse(json['queued'] as String),
      started: json['started'] == null
          ? null
          : DateTime.parse(json['started'] as String),
      ended: json['ended'] == null
          ? null
          : DateTime.parse(json['ended'] as String),
      duration: json['duration'] as String?,
      trigger: json['trigger'] as String?,
      stateChangeTime: json['stateChangeTime'] == null
          ? null
          : DateTime.parse(json['stateChangeTime'] as String),
      sendUpdatesToClient: json['sendUpdatesToClient'] as bool?,
      updateScheduledTask: json['updateScheduledTask'] as bool?,
      lastExecutionTime: json['lastExecutionTime'] == null
          ? null
          : DateTime.parse(json['lastExecutionTime'] as String),
    );

Map<String, dynamic> _$ReadarrCommandToJson(ReadarrCommand instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('commandName', instance.commandName);
  writeNotNull('message', instance.message);
  writeNotNull('body', instance.body?.toJson());
  writeNotNull('priority', instance.priority);
  writeNotNull('status', instance.status);
  writeNotNull('queued', instance.queued?.toIso8601String());
  writeNotNull('started', instance.started?.toIso8601String());
  writeNotNull('ended', instance.ended?.toIso8601String());
  writeNotNull('duration', instance.duration);
  writeNotNull('trigger', instance.trigger);
  writeNotNull('stateChangeTime', instance.stateChangeTime?.toIso8601String());
  writeNotNull('sendUpdatesToClient', instance.sendUpdatesToClient);
  writeNotNull('updateScheduledTask', instance.updateScheduledTask);
  writeNotNull(
      'lastExecutionTime', instance.lastExecutionTime?.toIso8601String());
  return val;
}
