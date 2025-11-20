import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/readarr/models/book_file/book_file_quality.dart';

part 'release.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrRelease {
  @JsonKey(name: 'guid')
  String? guid;

  @JsonKey(name: 'quality')
  ReadarrBookFileQuality? quality;

  @JsonKey(name: 'qualityWeight')
  int? qualityWeight;

  @JsonKey(name: 'age')
  int? age;

  @JsonKey(name: 'ageHours')
  double? ageHours;

  @JsonKey(name: 'ageMinutes')
  double? ageMinutes;

  @JsonKey(name: 'size')
  int? size;

  @JsonKey(name: 'indexerId')
  int? indexerId;

  @JsonKey(name: 'indexer')
  String? indexer;

  @JsonKey(name: 'releaseGroup')
  String? releaseGroup;

  @JsonKey(name: 'releaseHash')
  String? releaseHash;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'discography')
  bool? discography;

  @JsonKey(name: 'sceneSource')
  bool? sceneSource;

  @JsonKey(name: 'airDate')
  String? airDate;

  @JsonKey(name: 'authorName')
  String? authorName;

  @JsonKey(name: 'bookTitle')
  String? bookTitle;

  @JsonKey(name: 'approved')
  bool? approved;

  @JsonKey(name: 'temporarilyRejected')
  bool? temporarilyRejected;

  @JsonKey(name: 'rejected')
  bool? rejected;

  @JsonKey(name: 'rejections')
  List<String>? rejections;

  @JsonKey(name: 'publishDate')
  DateTime? publishDate;

  @JsonKey(name: 'downloadUrl')
  String? downloadUrl;

  @JsonKey(name: 'infoUrl')
  String? infoUrl;

  @JsonKey(name: 'downloadAllowed')
  bool? downloadAllowed;

  @JsonKey(name: 'releaseWeight')
  int? releaseWeight;

  @JsonKey(name: 'preferredWordScore')
  int? preferredWordScore;

  @JsonKey(name: 'magnetUrl')
  String? magnetUrl;

  @JsonKey(name: 'infoHash')
  String? infoHash;

  @JsonKey(name: 'seeders')
  int? seeders;

  @JsonKey(name: 'leechers')
  int? leechers;

  @JsonKey(name: 'protocol')
  String? protocol;

  @JsonKey(name: 'authorId')
  int? authorId;

  @JsonKey(name: 'bookId')
  int? bookId;

  ReadarrRelease({
    this.guid,
    this.quality,
    this.qualityWeight,
    this.age,
    this.ageHours,
    this.ageMinutes,
    this.size,
    this.indexerId,
    this.indexer,
    this.releaseGroup,
    this.releaseHash,
    this.title,
    this.discography,
    this.sceneSource,
    this.airDate,
    this.authorName,
    this.bookTitle,
    this.approved,
    this.temporarilyRejected,
    this.rejected,
    this.rejections,
    this.publishDate,
    this.downloadUrl,
    this.infoUrl,
    this.downloadAllowed,
    this.releaseWeight,
    this.preferredWordScore,
    this.magnetUrl,
    this.infoHash,
    this.seeders,
    this.leechers,
    this.protocol,
    this.authorId,
    this.bookId,
  });

  factory ReadarrRelease.fromJson(Map<String, dynamic> json) =>
      _$ReadarrReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrReleaseToJson(this);

  @override
  String toString() => json.encode(toJson());
}
