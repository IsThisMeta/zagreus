// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliSingleLibrary _$TautulliSingleLibraryFromJson(
        Map<String, dynamic> json) =>
    TautulliSingleLibrary(
      rowId: TautulliUtilities.ensureIntegerFromJson(json['row_id']),
      serverId: TautulliUtilities.ensureStringFromJson(json['server_id']),
      sectionId: TautulliUtilities.ensureIntegerFromJson(json['section_id']),
      sectionName: TautulliUtilities.ensureStringFromJson(json['section_name']),
      sectionType: TautulliUtilities.sectionTypeFromJson(
          json['section_type'] as String?),
      libraryThumb:
          TautulliUtilities.ensureStringFromJson(json['library_thumb']),
      libraryArt: TautulliUtilities.ensureStringFromJson(json['library_art']),
      count: TautulliUtilities.ensureIntegerFromJson(json['count']),
      childCount: TautulliUtilities.ensureIntegerFromJson(json['child_count']),
      parentCount:
          TautulliUtilities.ensureIntegerFromJson(json['parent_count']),
      isActive: TautulliUtilities.ensureBooleanFromJson(json['is_active']),
      doNotify: TautulliUtilities.ensureBooleanFromJson(json['do_notify']),
      doNotifyCreated:
          TautulliUtilities.ensureBooleanFromJson(json['do_notify_created']),
      keepSection:
          TautulliUtilities.ensureBooleanFromJson(json['keep_history']),
      deletedSection:
          TautulliUtilities.ensureBooleanFromJson(json['deleted_section']),
    );

Map<String, dynamic> _$TautulliSingleLibraryToJson(
    TautulliSingleLibrary instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('row_id', instance.rowId);
  writeNotNull('server_id', instance.serverId);
  writeNotNull('section_id', instance.sectionId);
  writeNotNull('section_name', instance.sectionName);
  writeNotNull('section_type',
      TautulliUtilities.sectionTypeToJson(instance.sectionType));
  writeNotNull('library_thumb', instance.libraryThumb);
  writeNotNull('library_art', instance.libraryArt);
  writeNotNull('count', instance.count);
  writeNotNull('parent_count', instance.parentCount);
  writeNotNull('child_count', instance.childCount);
  writeNotNull('is_active', instance.isActive);
  writeNotNull('do_notify', instance.doNotify);
  writeNotNull('do_notify_created', instance.doNotifyCreated);
  writeNotNull('keep_history', instance.keepSection);
  writeNotNull('deleted_section', instance.deletedSection);
  return val;
}
