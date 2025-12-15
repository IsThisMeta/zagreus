// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SABnzbdHistory _$SABnzbdHistoryFromJson(Map<String, dynamic> json) =>
    SABnzbdHistory(
      history: _SABnzbdHistoryResult.fromJson(
          json['history'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SABnzbdHistoryToJson(SABnzbdHistory instance) =>
    <String, dynamic>{
      'history': instance.history.toJson(),
    };

_SABnzbdHistoryResult _$SABnzbdHistoryResultFromJson(
        Map<String, dynamic> json) =>
    _SABnzbdHistoryResult(
      slots: (json['slots'] as List<dynamic>)
          .map((e) => _SABnzbdHistorySlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailySize: json['day_size'] as String,
      weeklySize: json['week_size'] as String,
      monthlySize: json['month_size'] as String,
      totalSize: json['total_size'] as String,
    );

Map<String, dynamic> _$SABnzbdHistoryResultToJson(
        _SABnzbdHistoryResult instance) =>
    <String, dynamic>{
      'slots': instance.slots.map((e) => e.toJson()).toList(),
      'day_size': instance.dailySize,
      'week_size': instance.weeklySize,
      'month_size': instance.monthlySize,
      'total_size': instance.totalSize,
    };

_SABnzbdHistorySlot _$SABnzbdHistorySlotFromJson(Map<String, dynamic> json) =>
    _SABnzbdHistorySlot(
      name: json['name'] as String,
      status: json['status'] as String,
      script: json['script'] as String,
      category: json['category'] as String,
      nzoId: json['nzo_id'] as String,
      size: (json['bytes'] as num).toInt(),
      failMessage: json['fail_message'] as String,
      timestamp: (json['completed'] as num).toInt(),
      actionLine: json['action_line'] as String,
      downloadTime: (json['download_time'] as num).toInt(),
      stageLog: (json['stage_log'] as List<dynamic>)
          .map((e) => SABnzbdStageLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      storage: json['storage'] as String,
    );

Map<String, dynamic> _$SABnzbdHistorySlotToJson(_SABnzbdHistorySlot instance) =>
    <String, dynamic>{
      'name': instance.name,
      'status': instance.status,
      'script': instance.script,
      'category': instance.category,
      'storage': instance.storage,
      'completed': instance.timestamp,
      'nzo_id': instance.nzoId,
      'bytes': instance.size,
      'fail_message': instance.failMessage,
      'action_line': instance.actionLine,
      'download_time': instance.downloadTime,
      'stage_log': instance.stageLog.map((e) => e.toJson()).toList(),
    };
