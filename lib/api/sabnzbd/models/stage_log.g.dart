// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SABnzbdStageLog _$SABnzbdStageLogFromJson(Map<String, dynamic> json) =>
    SABnzbdStageLog(
      name: json['name'] as String,
      actions:
          (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SABnzbdStageLogToJson(SABnzbdStageLog instance) =>
    <String, dynamic>{
      'name': instance.name,
      'actions': instance.actions,
    };
