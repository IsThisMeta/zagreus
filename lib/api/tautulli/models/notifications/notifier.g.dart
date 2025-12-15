// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliNotifier _$TautulliNotifierFromJson(Map<String, dynamic> json) =>
    TautulliNotifier(
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      agentId: TautulliUtilities.ensureIntegerFromJson(json['agent_id']),
      agentName: TautulliUtilities.ensureStringFromJson(json['agent_name']),
      agentLabel: TautulliUtilities.ensureStringFromJson(json['agent_label']),
      friendlyName:
          TautulliUtilities.ensureStringFromJson(json['friendly_name']),
      active: TautulliUtilities.ensureBooleanFromJson(json['active']),
    );

Map<String, dynamic> _$TautulliNotifierToJson(TautulliNotifier instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('agent_id', instance.agentId);
  writeNotNull('agent_name', instance.agentName);
  writeNotNull('agent_label', instance.agentLabel);
  writeNotNull('friendly_name', instance.friendlyName);
  writeNotNull('active', instance.active);
  return val;
}
