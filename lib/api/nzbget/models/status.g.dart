// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NZBGetStatus _$NZBGetStatusFromJson(Map<String, dynamic> json) => NZBGetStatus(
      paused: json['DownloadPaused'] as bool,
      speed: (json['DownloadRate'] as num).toInt(),
      speedLimit: (json['DownloadLimit'] as num).toInt(),
      remainingSize: (json['RemainingSizeMB'] as num).toInt(),
    );

Map<String, dynamic> _$NZBGetStatusToJson(NZBGetStatus instance) =>
    <String, dynamic>{
      'DownloadPaused': instance.paused,
      'DownloadRate': instance.speed,
      'DownloadLimit': instance.speedLimit,
      'RemainingSizeMB': instance.remainingSize,
    };
