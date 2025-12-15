// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifier_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliNotifierConfig _$TautulliNotifierConfigFromJson(
        Map<String, dynamic> json) =>
    TautulliNotifierConfig(
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      agentId: TautulliUtilities.ensureIntegerFromJson(json['agent_id']),
      agentName: TautulliUtilities.ensureStringFromJson(json['agent_name']),
      agentLabel: TautulliUtilities.ensureStringFromJson(json['agent_label']),
      friendlyName:
          TautulliUtilities.ensureStringFromJson(json['friendly_name']),
      customConditions: (json['custom_conditions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      customConditionsLogic: TautulliUtilities.ensureStringFromJson(
          json['custom_conditions_logic']),
      config: json['config'] as Map<String, dynamic>?,
      configOptions: (json['config_options'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      actions: TautulliNotifierConfig._optionsFromJson(
          json['actions'] as Map<String, dynamic>),
      notifyText: json['notify_text'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TautulliNotifierConfigToJson(
    TautulliNotifierConfig instance) {
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
  writeNotNull('custom_conditions', instance.customConditions);
  writeNotNull('custom_conditions_logic', instance.customConditionsLogic);
  writeNotNull('config', instance.config);
  writeNotNull('config_options', instance.configOptions);
  writeNotNull(
      'actions', TautulliNotifierConfig._optionsToJson(instance.actions));
  writeNotNull('notify_text', instance.notifyText);
  return val;
}
