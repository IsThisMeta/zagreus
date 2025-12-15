// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SABnzbdCategories _$SABnzbdCategoriesFromJson(Map<String, dynamic> json) =>
    SABnzbdCategories(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SABnzbdCategoriesToJson(SABnzbdCategories instance) =>
    <String, dynamic>{
      'categories': instance.categories,
    };
