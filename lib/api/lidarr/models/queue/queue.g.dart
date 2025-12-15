// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LidarrQueuePage _$LidarrQueuePageFromJson(Map<String, dynamic> json) =>
    LidarrQueuePage(
      page: (json['page'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalRecords: (json['totalRecords'] as num?)?.toInt(),
      records: (json['records'] as List<dynamic>?)
          ?.map((e) => LidarrQueueRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LidarrQueuePageToJson(LidarrQueuePage instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('page', instance.page);
  writeNotNull('pageSize', instance.pageSize);
  writeNotNull('totalRecords', instance.totalRecords);
  writeNotNull('records', instance.records?.map((e) => e.toJson()).toList());
  return val;
}

LidarrQueueRecord _$LidarrQueueRecordFromJson(Map<String, dynamic> json) =>
    LidarrQueueRecord(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      artist: json['artist'] as Map<String, dynamic>?,
      album: json['album'] as Map<String, dynamic>?,
      status: json['status'] as String?,
      timeleft: json['timeleft'] as String?,
      size: json['size'] as num?,
      sizeleft: json['sizeleft'] as num?,
      estimatedCompletionTime: json['estimatedCompletionTime'] as String?,
    );

Map<String, dynamic> _$LidarrQueueRecordToJson(LidarrQueueRecord instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('title', instance.title);
  writeNotNull('artist', instance.artist);
  writeNotNull('album', instance.album);
  writeNotNull('status', instance.status);
  writeNotNull('timeleft', instance.timeleft);
  writeNotNull('size', instance.size);
  writeNotNull('sizeleft', instance.sizeleft);
  writeNotNull('estimatedCompletionTime', instance.estimatedCompletionTime);
  return val;
}
