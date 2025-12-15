// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliHistory _$TautulliHistoryFromJson(Map<String, dynamic> json) =>
    TautulliHistory(
      records: TautulliHistory._entriesFromJson(json['data'] as List),
      draw: TautulliUtilities.ensureIntegerFromJson(json['draw']),
      recordsTotal:
          TautulliUtilities.ensureIntegerFromJson(json['recordsTotal']),
      recordsFiltered:
          TautulliUtilities.ensureIntegerFromJson(json['recordsFiltered']),
      totalDuration:
          TautulliUtilities.ensureStringFromJson(json['total_duration']),
      filterDuration:
          TautulliUtilities.ensureStringFromJson(json['filter_duration']),
    );

Map<String, dynamic> _$TautulliHistoryToJson(TautulliHistory instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('data', TautulliHistory._entriesToJson(instance.records));
  writeNotNull('draw', instance.draw);
  writeNotNull('recordsTotal', instance.recordsTotal);
  writeNotNull('recordsFiltered', instance.recordsFiltered);
  writeNotNull('total_duration', instance.totalDuration);
  writeNotNull('filter_duration', instance.filterDuration);
  return val;
}
