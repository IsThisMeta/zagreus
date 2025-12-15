// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrAuthorStatistics _$ReadarrAuthorStatisticsFromJson(
        Map<String, dynamic> json) =>
    ReadarrAuthorStatistics(
      bookCount: (json['bookCount'] as num?)?.toInt(),
      bookFileCount: (json['bookFileCount'] as num?)?.toInt(),
      totalBookCount: (json['totalBookCount'] as num?)?.toInt(),
      sizeOnDisk: (json['sizeOnDisk'] as num?)?.toInt(),
      percentOfBooks: (json['percentOfBooks'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReadarrAuthorStatisticsToJson(
    ReadarrAuthorStatistics instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('bookCount', instance.bookCount);
  writeNotNull('bookFileCount', instance.bookFileCount);
  writeNotNull('totalBookCount', instance.totalBookCount);
  writeNotNull('sizeOnDisk', instance.sizeOnDisk);
  writeNotNull('percentOfBooks', instance.percentOfBooks);
  return val;
}
