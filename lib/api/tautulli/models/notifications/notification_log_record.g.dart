// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_log_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliNotificationLogRecord _$TautulliNotificationLogRecordFromJson(
        Map<String, dynamic> json) =>
    TautulliNotificationLogRecord(
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      timestamp:
          TautulliUtilities.millisecondsDateTimeFromJson(json['timestamp']),
      sessionKey: TautulliUtilities.ensureIntegerFromJson(json['session_key']),
      ratingKey: TautulliUtilities.ensureIntegerFromJson(json['rating_key']),
      userId: TautulliUtilities.ensureIntegerFromJson(json['user_id']),
      user: TautulliUtilities.ensureStringFromJson(json['user']),
      notifierId: TautulliUtilities.ensureIntegerFromJson(json['notifier_id']),
      agentId: TautulliUtilities.ensureIntegerFromJson(json['agent_id']),
      agentName: TautulliUtilities.ensureStringFromJson(json['agent_name']),
      notifyAction:
          TautulliUtilities.ensureStringFromJson(json['notify_action']),
      subjectText: TautulliUtilities.ensureStringFromJson(json['subject_text']),
      bodyText: TautulliUtilities.ensureStringFromJson(json['body_text']),
      success: TautulliUtilities.ensureBooleanFromJson(json['success']),
    );

Map<String, dynamic> _$TautulliNotificationLogRecordToJson(
    TautulliNotificationLogRecord instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('timestamp', instance.timestamp?.toIso8601String());
  writeNotNull('session_key', instance.sessionKey);
  writeNotNull('rating_key', instance.ratingKey);
  writeNotNull('user_id', instance.userId);
  writeNotNull('user', instance.user);
  writeNotNull('notifier_id', instance.notifierId);
  writeNotNull('agent_id', instance.agentId);
  writeNotNull('agent_name', instance.agentName);
  writeNotNull('notify_action', instance.notifyAction);
  writeNotNull('subject_text', instance.subjectText);
  writeNotNull('body_text', instance.bodyText);
  writeNotNull('success', instance.success);
  return val;
}
