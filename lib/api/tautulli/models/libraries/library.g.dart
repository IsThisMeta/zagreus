// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliLibrary _$TautulliLibraryFromJson(Map<String, dynamic> json) =>
    TautulliLibrary(
      sectionId: TautulliUtilities.ensureIntegerFromJson(json['section_id']),
      sectionName: TautulliUtilities.ensureStringFromJson(json['section_name']),
      sectionType: TautulliUtilities.sectionTypeFromJson(
          json['section_type'] as String?),
      agent: TautulliUtilities.ensureStringFromJson(json['agent']),
      thumb: TautulliUtilities.ensureStringFromJson(json['thumb']),
      art: TautulliUtilities.ensureStringFromJson(json['art']),
      count: TautulliUtilities.ensureIntegerFromJson(json['count']),
      isActive: TautulliUtilities.ensureBooleanFromJson(json['is_active']),
      parentCount:
          TautulliUtilities.ensureIntegerFromJson(json['parent_count']),
      childCount: TautulliUtilities.ensureIntegerFromJson(json['child_count']),
    );

Map<String, dynamic> _$TautulliLibraryToJson(TautulliLibrary instance) {
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
  writeNotNull('thumb', instance.thumb);
  writeNotNull('art', instance.art);
  writeNotNull('count', instance.count);
  writeNotNull('is_active', instance.isActive);
  writeNotNull('parent_count', instance.parentCount);
  writeNotNull('child_count', instance.childCount);
  return val;
}
