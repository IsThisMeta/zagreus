// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newsletter_logs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliNewsletterLogs _$TautulliNewsletterLogsFromJson(
        Map<String, dynamic> json) =>
    TautulliNewsletterLogs(
      recordsFiltered:
          TautulliUtilities.ensureIntegerFromJson(json['recordsFiltered']),
      recordsTotal:
          TautulliUtilities.ensureIntegerFromJson(json['recordsTotal']),
      draw: TautulliUtilities.ensureIntegerFromJson(json['draw']),
      logs: TautulliNewsletterLogs._logsFromJson(json['data'] as List),
    );

Map<String, dynamic> _$TautulliNewsletterLogsToJson(
    TautulliNewsletterLogs instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('recordsFiltered', instance.recordsFiltered);
  writeNotNull('recordsTotal', instance.recordsTotal);
  writeNotNull('draw', instance.draw);
  writeNotNull('data', TautulliNewsletterLogs._logsToJson(instance.logs));
  return val;
}
