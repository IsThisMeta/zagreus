// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newsletter_log_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliNewsletterLogRecord _$TautulliNewsletterLogRecordFromJson(
        Map<String, dynamic> json) =>
    TautulliNewsletterLogRecord(
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      timestamp:
          TautulliUtilities.millisecondsDateTimeFromJson(json['timestamp']),
      endDate: TautulliUtilities.ensureStringFromJson(json['end_date']),
      startDate: TautulliUtilities.ensureStringFromJson(json['start_date']),
      uuid: TautulliUtilities.ensureStringFromJson(json['uuid']),
      newsletterId:
          TautulliUtilities.ensureIntegerFromJson(json['newsletter_id']),
      agentId: TautulliUtilities.ensureIntegerFromJson(json['agent_id']),
      agentName: TautulliUtilities.ensureStringFromJson(json['agent_name']),
      notifyAction:
          TautulliUtilities.ensureStringFromJson(json['notify_action']),
      subjectText: TautulliUtilities.ensureStringFromJson(json['subject_text']),
      bodyText: TautulliUtilities.ensureStringFromJson(json['body_text']),
      success: TautulliUtilities.ensureBooleanFromJson(json['success']),
    );

Map<String, dynamic> _$TautulliNewsletterLogRecordToJson(
    TautulliNewsletterLogRecord instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('timestamp', instance.timestamp?.toIso8601String());
  writeNotNull('end_date', instance.endDate);
  writeNotNull('start_date', instance.startDate);
  writeNotNull('uuid', instance.uuid);
  writeNotNull('newsletter_id', instance.newsletterId);
  writeNotNull('agent_id', instance.agentId);
  writeNotNull('agent_name', instance.agentName);
  writeNotNull('notify_action', instance.notifyAction);
  writeNotNull('subject_text', instance.subjectText);
  writeNotNull('body_text', instance.bodyText);
  writeNotNull('success', instance.success);
  return val;
}
