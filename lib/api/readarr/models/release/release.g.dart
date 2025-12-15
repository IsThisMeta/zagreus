// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrRelease _$ReadarrReleaseFromJson(Map<String, dynamic> json) =>
    ReadarrRelease(
      guid: json['guid'] as String?,
      quality: json['quality'] == null
          ? null
          : ReadarrBookFileQuality.fromJson(
              json['quality'] as Map<String, dynamic>),
      qualityWeight: (json['qualityWeight'] as num?)?.toInt(),
      age: (json['age'] as num?)?.toInt(),
      ageHours: (json['ageHours'] as num?)?.toDouble(),
      ageMinutes: (json['ageMinutes'] as num?)?.toDouble(),
      size: (json['size'] as num?)?.toInt(),
      indexerId: (json['indexerId'] as num?)?.toInt(),
      indexer: json['indexer'] as String?,
      releaseGroup: json['releaseGroup'] as String?,
      releaseHash: json['releaseHash'] as String?,
      title: json['title'] as String?,
      discography: json['discography'] as bool?,
      sceneSource: json['sceneSource'] as bool?,
      airDate: json['airDate'] as String?,
      authorName: json['authorName'] as String?,
      bookTitle: json['bookTitle'] as String?,
      approved: json['approved'] as bool?,
      temporarilyRejected: json['temporarilyRejected'] as bool?,
      rejected: json['rejected'] as bool?,
      rejections: (json['rejections'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      publishDate: json['publishDate'] == null
          ? null
          : DateTime.parse(json['publishDate'] as String),
      downloadUrl: json['downloadUrl'] as String?,
      infoUrl: json['infoUrl'] as String?,
      downloadAllowed: json['downloadAllowed'] as bool?,
      releaseWeight: (json['releaseWeight'] as num?)?.toInt(),
      preferredWordScore: (json['preferredWordScore'] as num?)?.toInt(),
      magnetUrl: json['magnetUrl'] as String?,
      infoHash: json['infoHash'] as String?,
      seeders: (json['seeders'] as num?)?.toInt(),
      leechers: (json['leechers'] as num?)?.toInt(),
      protocol: json['protocol'] as String?,
      authorId: (json['authorId'] as num?)?.toInt(),
      bookId: (json['bookId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReadarrReleaseToJson(ReadarrRelease instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('guid', instance.guid);
  writeNotNull('quality', instance.quality?.toJson());
  writeNotNull('qualityWeight', instance.qualityWeight);
  writeNotNull('age', instance.age);
  writeNotNull('ageHours', instance.ageHours);
  writeNotNull('ageMinutes', instance.ageMinutes);
  writeNotNull('size', instance.size);
  writeNotNull('indexerId', instance.indexerId);
  writeNotNull('indexer', instance.indexer);
  writeNotNull('releaseGroup', instance.releaseGroup);
  writeNotNull('releaseHash', instance.releaseHash);
  writeNotNull('title', instance.title);
  writeNotNull('discography', instance.discography);
  writeNotNull('sceneSource', instance.sceneSource);
  writeNotNull('airDate', instance.airDate);
  writeNotNull('authorName', instance.authorName);
  writeNotNull('bookTitle', instance.bookTitle);
  writeNotNull('approved', instance.approved);
  writeNotNull('temporarilyRejected', instance.temporarilyRejected);
  writeNotNull('rejected', instance.rejected);
  writeNotNull('rejections', instance.rejections);
  writeNotNull('publishDate', instance.publishDate?.toIso8601String());
  writeNotNull('downloadUrl', instance.downloadUrl);
  writeNotNull('infoUrl', instance.infoUrl);
  writeNotNull('downloadAllowed', instance.downloadAllowed);
  writeNotNull('releaseWeight', instance.releaseWeight);
  writeNotNull('preferredWordScore', instance.preferredWordScore);
  writeNotNull('magnetUrl', instance.magnetUrl);
  writeNotNull('infoHash', instance.infoHash);
  writeNotNull('seeders', instance.seeders);
  writeNotNull('leechers', instance.leechers);
  writeNotNull('protocol', instance.protocol);
  writeNotNull('authorId', instance.authorId);
  writeNotNull('bookId', instance.bookId);
  return val;
}
