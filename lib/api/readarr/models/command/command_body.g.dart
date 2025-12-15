// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrCommandBody _$ReadarrCommandBodyFromJson(Map<String, dynamic> json) =>
    ReadarrCommandBody(
      sendUpdatesToClient: json['sendUpdatesToClient'] as bool?,
      updateScheduledTask: json['updateScheduledTask'] as bool?,
      completionMessage: json['completionMessage'] as String?,
      name: json['name'] as String?,
      trigger: json['trigger'] as String?,
    );

Map<String, dynamic> _$ReadarrCommandBodyToJson(ReadarrCommandBody instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sendUpdatesToClient', instance.sendUpdatesToClient);
  writeNotNull('updateScheduledTask', instance.updateScheduledTask);
  writeNotNull('completionMessage', instance.completionMessage);
  writeNotNull('name', instance.name);
  writeNotNull('trigger', instance.trigger);
  return val;
}
