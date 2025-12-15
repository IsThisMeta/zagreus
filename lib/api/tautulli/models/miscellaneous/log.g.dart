// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliLog _$TautulliLogFromJson(Map<String, dynamic> json) => TautulliLog(
      timestamp: TautulliUtilities.ensureStringFromJson(json['time']),
      level: TautulliUtilities.ensureStringFromJson(json['loglevel']),
      message: TautulliUtilities.ensureStringFromJson(json['msg']),
      thread: TautulliUtilities.ensureStringFromJson(json['thread']),
    );

Map<String, dynamic> _$TautulliLogToJson(TautulliLog instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('loglevel', instance.level);
  writeNotNull('time', instance.timestamp);
  writeNotNull('msg', instance.message);
  writeNotNull('thread', instance.thread);
  return val;
}
