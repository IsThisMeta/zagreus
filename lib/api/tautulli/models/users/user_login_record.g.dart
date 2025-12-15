// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_login_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliUserLoginRecord _$TautulliUserLoginRecordFromJson(
        Map<String, dynamic> json) =>
    TautulliUserLoginRecord(
      timestamp:
          TautulliUtilities.millisecondsDateTimeFromJson(json['timestamp']),
      userId: TautulliUtilities.ensureIntegerFromJson(json['user_id']),
      userGroup:
          TautulliUtilities.userGroupFromJson(json['user_group'] as String?),
      ipAddress: TautulliUtilities.ensureStringFromJson(json['ip_address']),
      host: TautulliUtilities.ensureStringFromJson(json['host']),
      userAgent: TautulliUtilities.ensureStringFromJson(json['user_agent']),
      os: TautulliUtilities.ensureStringFromJson(json['os']),
      browser: TautulliUtilities.ensureStringFromJson(json['browser']),
      success: TautulliUtilities.ensureBooleanFromJson(json['success']),
      friendlyName:
          TautulliUtilities.ensureStringFromJson(json['friendly_name']),
    );

Map<String, dynamic> _$TautulliUserLoginRecordToJson(
    TautulliUserLoginRecord instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('timestamp', instance.timestamp?.toIso8601String());
  writeNotNull('user_id', instance.userId);
  writeNotNull(
      'user_group', TautulliUtilities.userGroupToJson(instance.userGroup));
  writeNotNull('ip_address', instance.ipAddress);
  writeNotNull('host', instance.host);
  writeNotNull('user_agent', instance.userAgent);
  writeNotNull('os', instance.os);
  writeNotNull('browser', instance.browser);
  writeNotNull('success', instance.success);
  writeNotNull('friendly_name', instance.friendlyName);
  return val;
}
