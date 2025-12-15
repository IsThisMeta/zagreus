// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliGraphData _$TautulliGraphDataFromJson(Map<String, dynamic> json) =>
    TautulliGraphData(
      categories:
          TautulliUtilities.ensureStringListFromJson(json['categories']),
      series: TautulliGraphData._seriesFromJson(json['series'] as List),
    );

Map<String, dynamic> _$TautulliGraphDataToJson(TautulliGraphData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('categories', instance.categories);
  writeNotNull('series', TautulliGraphData._seriesToJson(instance.series));
  return val;
}
