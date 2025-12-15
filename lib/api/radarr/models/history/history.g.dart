// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RadarrHistory _$RadarrHistoryFromJson(Map<String, dynamic> json) =>
    RadarrHistory(
      page: (json['page'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      sortKey:
          RadarrUtilities.historySortKeyFromJson(json['sortKey'] as String?),
      sortDirection: RadarrUtilities.sortDirectionFromJson(
          json['sortDirection'] as String?),
      totalRecords: (json['totalRecords'] as num?)?.toInt(),
      records: (json['records'] as List<dynamic>?)
          ?.map((e) => RadarrHistoryRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RadarrHistoryToJson(RadarrHistory instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('page', instance.page);
  writeNotNull('pageSize', instance.pageSize);
  writeNotNull(
      'sortKey', RadarrUtilities.historySortKeyToJson(instance.sortKey));
  writeNotNull('sortDirection',
      RadarrUtilities.sortDirectionToJson(instance.sortDirection));
  writeNotNull('totalRecords', instance.totalRecords);
  writeNotNull('records', instance.records?.map((e) => e.toJson()).toList());
  return val;
}
