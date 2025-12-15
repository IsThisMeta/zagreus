// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrQueue _$ReadarrQueueFromJson(Map<String, dynamic> json) => ReadarrQueue(
      page: (json['page'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      sortKey: json['sortKey'] as String?,
      sortDirection: json['sortDirection'] as String?,
      totalRecords: (json['totalRecords'] as num?)?.toInt(),
      records: (json['records'] as List<dynamic>?)
          ?.map((e) => ReadarrQueueRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReadarrQueueToJson(ReadarrQueue instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('page', instance.page);
  writeNotNull('pageSize', instance.pageSize);
  writeNotNull('sortKey', instance.sortKey);
  writeNotNull('sortDirection', instance.sortDirection);
  writeNotNull('totalRecords', instance.totalRecords);
  writeNotNull('records', instance.records?.map((e) => e.toJson()).toList());
  return val;
}
