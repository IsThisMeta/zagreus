// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliLibraryName _$TautulliLibraryNameFromJson(Map<String, dynamic> json) =>
    TautulliLibraryName(
      sectionId: TautulliUtilities.ensureIntegerFromJson(json['section_id']),
      sectionName: TautulliUtilities.ensureStringFromJson(json['section_name']),
      sectionType: TautulliUtilities.sectionTypeFromJson(
          json['section_type'] as String?),
      agent: TautulliUtilities.ensureStringFromJson(json['agent']),
    );

Map<String, dynamic> _$TautulliLibraryNameToJson(TautulliLibraryName instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('section_id', instance.sectionId);
  writeNotNull('section_name', instance.sectionName);
  writeNotNull('section_type',
      TautulliUtilities.sectionTypeToJson(instance.sectionType));
  writeNotNull('agent', instance.agent);
  return val;
}
