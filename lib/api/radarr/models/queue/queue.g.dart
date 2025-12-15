// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RadarrQueue _$RadarrQueueFromJson(Map<String, dynamic> json) => RadarrQueue(
      page: (json['page'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      sortKey: RadarrUtilities.queueSortKeyFromJson(json['sortKey'] as String?),
      sortDirection: RadarrUtilities.sortDirectionFromJson(
          json['sortDirection'] as String?),
      totalRecords: (json['totalRecords'] as num?)?.toInt(),
      records: (json['records'] as List<dynamic>?)
          ?.map((e) => RadarrQueueRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RadarrQueueToJson(RadarrQueue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('page', instance.page);
  writeNotNull('pageSize', instance.pageSize);
  writeNotNull('sortKey', RadarrUtilities.queueSortKeyToJson(instance.sortKey));
  writeNotNull('sortDirection',
      RadarrUtilities.sortDirectionToJson(instance.sortDirection));
  writeNotNull('totalRecords', instance.totalRecords);
  writeNotNull('records', instance.records?.map((e) => e.toJson()).toList());
  return val;
}
