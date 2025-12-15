// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prowlarr_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProwlarrItem _$ProwlarrItemFromJson(Map<String, dynamic> json) => ProwlarrItem(
      guid: json['guid'] as String?,
      title: json['title'] as String?,
      size: (json['size'] as num?)?.toInt(),
      indexer: json['indexer'] as String?,
      indexerId: (json['indexerId'] as num?)?.toInt(),
      publishDate: json['publishDate'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      infoUrl: json['infoUrl'] as String?,
      commentUrl: json['commentUrl'] as String?,
      protocol: json['protocol'] as String?,
      age: (json['age'] as num?)?.toInt(),
      ageHours: (json['ageHours'] as num?)?.toDouble(),
      ageMinutes: (json['ageMinutes'] as num?)?.toDouble(),
      seeders: (json['seeders'] as num?)?.toInt(),
      leechers: (json['leechers'] as num?)?.toInt(),
      grabs: (json['grabs'] as num?)?.toInt(),
      files: (json['files'] as num?)?.toInt(),
      imdbId: (json['imdbId'] as num?)?.toInt(),
      posterUrl: json['posterUrl'] as String?,
      approved: json['approved'] as bool?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => ProwlarrCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      indexerFlags: json['indexerFlags'] as List<dynamic>?,
    );

Map<String, dynamic> _$ProwlarrItemToJson(ProwlarrItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('guid', instance.guid);
  writeNotNull('title', instance.title);
  writeNotNull('size', instance.size);
  writeNotNull('indexer', instance.indexer);
  writeNotNull('indexerId', instance.indexerId);
  writeNotNull('publishDate', instance.publishDate);
  writeNotNull('downloadUrl', instance.downloadUrl);
  writeNotNull('infoUrl', instance.infoUrl);
  writeNotNull('commentUrl', instance.commentUrl);
  writeNotNull('protocol', instance.protocol);
  writeNotNull('age', instance.age);
  writeNotNull('ageHours', instance.ageHours);
  writeNotNull('ageMinutes', instance.ageMinutes);
  writeNotNull('seeders', instance.seeders);
  writeNotNull('leechers', instance.leechers);
  writeNotNull('grabs', instance.grabs);
  writeNotNull('files', instance.files);
  writeNotNull('imdbId', instance.imdbId);
  writeNotNull('posterUrl', instance.posterUrl);
  writeNotNull('approved', instance.approved);
  writeNotNull(
      'categories', instance.categories?.map((e) => e.toJson()).toList());
  writeNotNull('indexerFlags', instance.indexerFlags);
  return val;
}
