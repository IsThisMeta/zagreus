// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SABnzbdQueue _$SABnzbdQueueFromJson(Map<String, dynamic> json) => SABnzbdQueue(
      queue:
          _SABnzbdQueueResult.fromJson(json['queue'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SABnzbdQueueToJson(SABnzbdQueue instance) =>
    <String, dynamic>{
      'queue': instance.queue.toJson(),
    };

_SABnzbdQueueResult _$SABnzbdQueueResultFromJson(Map<String, dynamic> json) =>
    _SABnzbdQueueResult(
      status: json['status'] as String,
      paused: json['paused'] as bool,
      speed: json['kbpersec'] as String,
      timeLeft: json['timeleft'] as String,
      size: json['mb'] as String,
      sizeLeft: json['mbleft'] as String,
      slots: (json['slots'] as List<dynamic>)
          .map((e) => _SABnzbdQueueSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SABnzbdQueueResultToJson(_SABnzbdQueueResult instance) =>
    <String, dynamic>{
      'status': instance.status,
      'paused': instance.paused,
      'slots': instance.slots.map((e) => e.toJson()).toList(),
      'kbpersec': instance.speed,
      'timeleft': instance.timeLeft,
      'mb': instance.size,
      'mbleft': instance.sizeLeft,
    };

_SABnzbdQueueSlot _$SABnzbdQueueSlotFromJson(Map<String, dynamic> json) =>
    _SABnzbdQueueSlot(
      filename: json['filename'] as String,
      status: json['status'] as String,
      script: json['script'] as String,
      priority: json['priority'] as String,
      nzoId: json['nzo_id'] as String,
      size: json['mb'] as String,
      sizeLeft: json['mbleft'] as String,
      timeLeft: json['timeleft'] as String,
      category: json['cat'] as String,
    );

Map<String, dynamic> _$SABnzbdQueueSlotToJson(_SABnzbdQueueSlot instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'status': instance.status,
      'script': instance.script,
      'priority': instance.priority,
      'nzo_id': instance.nzoId,
      'mb': instance.size,
      'mbleft': instance.sizeLeft,
      'timeleft': instance.timeLeft,
      'cat': instance.category,
    };
