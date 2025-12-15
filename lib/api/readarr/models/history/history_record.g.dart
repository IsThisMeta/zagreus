// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrHistoryRecord _$ReadarrHistoryRecordFromJson(
        Map<String, dynamic> json) =>
    ReadarrHistoryRecord(
      id: (json['id'] as num?)?.toInt(),
      bookId: (json['bookId'] as num?)?.toInt(),
      authorId: (json['authorId'] as num?)?.toInt(),
      sourceTitle: json['sourceTitle'] as String?,
      quality: json['quality'] == null
          ? null
          : ReadarrBookFileQuality.fromJson(
              json['quality'] as Map<String, dynamic>),
      qualityCutoffNotMet: json['qualityCutoffNotMet'] as bool?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      downloadId: json['downloadId'] as String?,
      eventType: json['eventType'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      author: json['author'] == null
          ? null
          : ReadarrAuthor.fromJson(json['author'] as Map<String, dynamic>),
      book: json['book'] == null
          ? null
          : ReadarrBook.fromJson(json['book'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReadarrHistoryRecordToJson(
    ReadarrHistoryRecord instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('bookId', instance.bookId);
  writeNotNull('authorId', instance.authorId);
  writeNotNull('sourceTitle', instance.sourceTitle);
  writeNotNull('quality', instance.quality?.toJson());
  writeNotNull('qualityCutoffNotMet', instance.qualityCutoffNotMet);
  writeNotNull('date', instance.date?.toIso8601String());
  writeNotNull('downloadId', instance.downloadId);
  writeNotNull('eventType', instance.eventType);
  writeNotNull('data', instance.data);
  writeNotNull('author', instance.author?.toJson());
  writeNotNull('book', instance.book?.toJson());
  return val;
}
