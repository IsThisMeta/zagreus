// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrSeries _$ReadarrSeriesFromJson(Map<String, dynamic> json) =>
    ReadarrSeries(
      id: (json['id'] as num?)?.toInt(),
      foreignSeriesId: json['foreignSeriesId'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      numbered: json['numbered'] as bool?,
      workCount: (json['workCount'] as num?)?.toInt(),
      primaryWorkCount: (json['primaryWorkCount'] as num?)?.toInt(),
      books: (json['books'] as List<dynamic>?)
          ?.map((e) => ReadarrBook.fromJson(e as Map<String, dynamic>))
          .toList(),
      foreignAuthorId: json['foreignAuthorId'] as String?,
    );

Map<String, dynamic> _$ReadarrSeriesToJson(ReadarrSeries instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('foreignSeriesId', instance.foreignSeriesId);
  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  writeNotNull('numbered', instance.numbered);
  writeNotNull('workCount', instance.workCount);
  writeNotNull('primaryWorkCount', instance.primaryWorkCount);
  writeNotNull('books', instance.books?.map((e) => e.toJson()).toList());
  writeNotNull('foreignAuthorId', instance.foreignAuthorId);
  return val;
}
