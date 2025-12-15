// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProwlarrCategory _$ProwlarrCategoryFromJson(Map<String, dynamic> json) =>
    ProwlarrCategory(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) => ProwlarrCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProwlarrCategoryToJson(ProwlarrCategory instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('description', instance.description);
  writeNotNull(
      'subCategories', instance.subCategories?.map((e) => e.toJson()).toList());
  return val;
}
