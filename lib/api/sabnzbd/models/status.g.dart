// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SABnzbdStatus _$SABnzbdStatusFromJson(Map<String, dynamic> json) =>
    SABnzbdStatus(
      status:
          _SABnzbdStatusResult.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SABnzbdStatusToJson(SABnzbdStatus instance) =>
    <String, dynamic>{
      'status': instance.status.toJson(),
    };

_SABnzbdStatusResult _$SABnzbdStatusResultFromJson(Map<String, dynamic> json) =>
    _SABnzbdStatusResult(
      uptime: json['uptime'] as String,
      version: json['version'] as String,
      paused: json['paused'] as bool,
      tempDiskSpace: json['diskspace1'] as String,
      finalDiskSpace: json['diskspace2'] as String,
      speedLimit: json['speedlimit_abs'] as String,
      speedLimitPercentage: json['speedlimit'] as String,
    );

Map<String, dynamic> _$SABnzbdStatusResultToJson(
        _SABnzbdStatusResult instance) =>
    <String, dynamic>{
      'uptime': instance.uptime,
      'version': instance.version,
      'paused': instance.paused,
      'diskspace1': instance.tempDiskSpace,
      'diskspace2': instance.finalDiskSpace,
      'speedlimit_abs': instance.speedLimit,
      'speedlimit': instance.speedLimitPercentage,
    };
