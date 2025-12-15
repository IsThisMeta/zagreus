// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_book_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrSeriesBookLink _$ReadarrSeriesBookLinkFromJson(
        Map<String, dynamic> json) =>
    ReadarrSeriesBookLink(
      id: (json['id'] as num?)?.toInt(),
      position: json['position'] as String?,
      seriesId: (json['seriesId'] as num?)?.toInt(),
      bookId: (json['bookId'] as num?)?.toInt(),
      isPrimary: json['isPrimary'] as bool?,
      series: json['series'] as String?,
      foreignSeriesId: json['foreignSeriesId'] as String?,
    );

Map<String, dynamic> _$ReadarrSeriesBookLinkToJson(
    ReadarrSeriesBookLink instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('position', instance.position);
  writeNotNull('seriesId', instance.seriesId);
  writeNotNull('bookId', instance.bookId);
  writeNotNull('isPrimary', instance.isPrimary);
  writeNotNull('series', instance.series);
  writeNotNull('foreignSeriesId', instance.foreignSeriesId);
  return val;
}
