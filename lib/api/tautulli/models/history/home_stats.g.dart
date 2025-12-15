// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliHomeStats _$TautulliHomeStatsFromJson(Map<String, dynamic> json) =>
    TautulliHomeStats(
      id: TautulliUtilities.ensureStringFromJson(json['stat_id']),
      title: TautulliUtilities.ensureStringFromJson(json['stat_title']),
      type: TautulliUtilities.ensureStringFromJson(json['stat_type']),
      data: (json['rows'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$TautulliHomeStatsToJson(TautulliHomeStats instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('stat_id', instance.id);
  writeNotNull('stat_type', instance.type);
  writeNotNull('stat_title', instance.title);
  writeNotNull('rows', instance.data);
  return val;
}
