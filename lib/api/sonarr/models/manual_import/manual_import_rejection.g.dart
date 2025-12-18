// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_import_rejection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonarrManualImportRejection _$SonarrManualImportRejectionFromJson(
        Map<String, dynamic> json) =>
    SonarrManualImportRejection(
      reason: json['reason'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$SonarrManualImportRejectionToJson(
    SonarrManualImportRejection instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('reason', instance.reason);
  writeNotNull('type', instance.type);
  return val;
}
