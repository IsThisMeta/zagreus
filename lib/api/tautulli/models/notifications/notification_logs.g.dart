// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_logs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliNotificationLogs _$TautulliNotificationLogsFromJson(
        Map<String, dynamic> json) =>
    TautulliNotificationLogs(
      recordsFiltered:
          TautulliUtilities.ensureIntegerFromJson(json['recordsFiltered']),
      recordsTotal:
          TautulliUtilities.ensureIntegerFromJson(json['recordsTotal']),
      draw: TautulliUtilities.ensureIntegerFromJson(json['draw']),
      logs: TautulliNotificationLogs._logsFromJson(json['data'] as List),
    );

Map<String, dynamic> _$TautulliNotificationLogsToJson(
    TautulliNotificationLogs instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('recordsFiltered', instance.recordsFiltered);
  writeNotNull('recordsTotal', instance.recordsTotal);
  writeNotNull('draw', instance.draw);
  writeNotNull('data', TautulliNotificationLogs._logsToJson(instance.logs));
  return val;
}
