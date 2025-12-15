// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_media_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliLibraryMediaInfo _$TautulliLibraryMediaInfoFromJson(
        Map<String, dynamic> json) =>
    TautulliLibraryMediaInfo(
      recordsFiltered:
          TautulliUtilities.ensureIntegerFromJson(json['recordsFiltered']),
      recordsTotal:
          TautulliUtilities.ensureIntegerFromJson(json['recordsTotal']),
      filteredFileSize:
          TautulliUtilities.ensureIntegerFromJson(json['filtered_file_size']),
      totalFileSize:
          TautulliUtilities.ensureIntegerFromJson(json['total_file_size']),
      draw: TautulliUtilities.ensureIntegerFromJson(json['draw']),
      mediaInfo: TautulliLibraryMediaInfo._infoFromJson(json['data']),
    );

Map<String, dynamic> _$TautulliLibraryMediaInfoToJson(
    TautulliLibraryMediaInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('recordsFiltered', instance.recordsFiltered);
  writeNotNull('recordsTotal', instance.recordsTotal);
  writeNotNull('filtered_file_size', instance.filteredFileSize);
  writeNotNull('total_file_size', instance.totalFileSize);
  writeNotNull('draw', instance.draw);
  writeNotNull(
      'data', TautulliLibraryMediaInfo._infoToJson(instance.mediaInfo));
  return val;
}
