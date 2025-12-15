// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrBookStatistics _$ReadarrBookStatisticsFromJson(
        Map<String, dynamic> json) =>
    ReadarrBookStatistics(
      bookFileCount: (json['bookFileCount'] as num?)?.toInt(),
      bookCount: (json['bookCount'] as num?)?.toInt(),
      totalBookCount: (json['totalBookCount'] as num?)?.toInt(),
      sizeOnDisk: (json['sizeOnDisk'] as num?)?.toInt(),
      percentOfBooks: (json['percentOfBooks'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReadarrBookStatisticsToJson(
    ReadarrBookStatistics instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('bookFileCount', instance.bookFileCount);
  writeNotNull('bookCount', instance.bookCount);
  writeNotNull('totalBookCount', instance.totalBookCount);
  writeNotNull('sizeOnDisk', instance.sizeOnDisk);
  writeNotNull('percentOfBooks', instance.percentOfBooks);
  return val;
}
