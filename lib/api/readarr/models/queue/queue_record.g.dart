// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrQueueRecord _$ReadarrQueueRecordFromJson(Map<String, dynamic> json) =>
    ReadarrQueueRecord(
      id: (json['id'] as num?)?.toInt(),
      authorId: (json['authorId'] as num?)?.toInt(),
      bookId: (json['bookId'] as num?)?.toInt(),
      author: json['author'] == null
          ? null
          : ReadarrAuthor.fromJson(json['author'] as Map<String, dynamic>),
      book: json['book'] == null
          ? null
          : ReadarrBook.fromJson(json['book'] as Map<String, dynamic>),
      quality: json['quality'] == null
          ? null
          : ReadarrBookFileQuality.fromJson(
              json['quality'] as Map<String, dynamic>),
      size: (json['size'] as num?)?.toDouble(),
      title: json['title'] as String?,
      sizeleft: (json['sizeleft'] as num?)?.toDouble(),
      timeleft: json['timeleft'] as String?,
      estimatedCompletionTime: json['estimatedCompletionTime'] == null
          ? null
          : DateTime.parse(json['estimatedCompletionTime'] as String),
      status: json['status'] as String?,
      trackedDownloadStatus: json['trackedDownloadStatus'] as String?,
      trackedDownloadState: json['trackedDownloadState'] as String?,
      statusMessages: (json['statusMessages'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      errorMessage: json['errorMessage'] as String?,
      downloadId: json['downloadId'] as String?,
      protocol: json['protocol'] as String?,
      downloadClient: json['downloadClient'] as String?,
      indexer: json['indexer'] as String?,
      outputPath: json['outputPath'] as String?,
    );

Map<String, dynamic> _$ReadarrQueueRecordToJson(ReadarrQueueRecord instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('authorId', instance.authorId);
  writeNotNull('bookId', instance.bookId);
  writeNotNull('author', instance.author?.toJson());
  writeNotNull('book', instance.book?.toJson());
  writeNotNull('quality', instance.quality?.toJson());
  writeNotNull('size', instance.size);
  writeNotNull('title', instance.title);
  writeNotNull('sizeleft', instance.sizeleft);
  writeNotNull('timeleft', instance.timeleft);
  writeNotNull('estimatedCompletionTime',
      instance.estimatedCompletionTime?.toIso8601String());
  writeNotNull('status', instance.status);
  writeNotNull('trackedDownloadStatus', instance.trackedDownloadStatus);
  writeNotNull('trackedDownloadState', instance.trackedDownloadState);
  writeNotNull('statusMessages', instance.statusMessages);
  writeNotNull('errorMessage', instance.errorMessage);
  writeNotNull('downloadId', instance.downloadId);
  writeNotNull('protocol', instance.protocol);
  writeNotNull('downloadClient', instance.downloadClient);
  writeNotNull('indexer', instance.indexer);
  writeNotNull('outputPath', instance.outputPath);
  return val;
}
