// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'libraries_table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliLibrariesTable _$TautulliLibrariesTableFromJson(
        Map<String, dynamic> json) =>
    TautulliLibrariesTable(
      libraries:
          TautulliLibrariesTable._librariesFromJson(json['data'] as List),
      draw: TautulliUtilities.ensureIntegerFromJson(json['draw']),
      recordsTotal:
          TautulliUtilities.ensureIntegerFromJson(json['recordsTotal']),
      recordsFiltered:
          TautulliUtilities.ensureIntegerFromJson(json['recordsFiltered']),
    );

Map<String, dynamic> _$TautulliLibrariesTableToJson(
    TautulliLibrariesTable instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'data', TautulliLibrariesTable._librariesToJson(instance.libraries));
  writeNotNull('draw', instance.draw);
  writeNotNull('recordsTotal', instance.recordsTotal);
  writeNotNull('recordsFiltered', instance.recordsFiltered);
  return val;
}
