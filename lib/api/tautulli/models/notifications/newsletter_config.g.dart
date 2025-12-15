// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newsletter_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliNewsletterConfig _$TautulliNewsletterConfigFromJson(
        Map<String, dynamic> json) =>
    TautulliNewsletterConfig(
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      idName: TautulliUtilities.ensureStringFromJson(json['id_name']),
      agentId: TautulliUtilities.ensureIntegerFromJson(json['agent_id']),
      agentName: TautulliUtilities.ensureStringFromJson(json['agent_name']),
      agentLabel: TautulliUtilities.ensureStringFromJson(json['agent_label']),
      friendlyName:
          TautulliUtilities.ensureStringFromJson(json['friendly_name']),
      cron: TautulliUtilities.ensureStringFromJson(json['cron']),
      active: TautulliUtilities.ensureBooleanFromJson(json['active']),
      body: TautulliUtilities.ensureStringFromJson(json['body']),
      subject: TautulliUtilities.ensureStringFromJson(json['subject']),
      message: TautulliUtilities.ensureStringFromJson(json['message']),
      config: json['config'] as Map<String, dynamic>?,
      configOptions: (json['config_options'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      emailConfig: json['email_config'] as Map<String, dynamic>?,
      emailConfigOptions: (json['email_config_options'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$TautulliNewsletterConfigToJson(
    TautulliNewsletterConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('id_name', instance.idName);
  writeNotNull('agent_id', instance.agentId);
  writeNotNull('agent_name', instance.agentName);
  writeNotNull('agent_label', instance.agentLabel);
  writeNotNull('friendly_name', instance.friendlyName);
  writeNotNull('cron', instance.cron);
  writeNotNull('active', instance.active);
  writeNotNull('subject', instance.subject);
  writeNotNull('body', instance.body);
  writeNotNull('message', instance.message);
  writeNotNull('config', instance.config);
  writeNotNull('config_options', instance.configOptions);
  writeNotNull('email_config', instance.emailConfig);
  writeNotNull('email_config_options', instance.emailConfigOptions);
  return val;
}
