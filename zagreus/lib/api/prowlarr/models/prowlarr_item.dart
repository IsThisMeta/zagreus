import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/prowlarr/models/category.dart';

part 'prowlarr_item.g.dart';

/// Prowlarr search result item
@JsonSerializable(explicitToJson: true)
class ProwlarrItem {
  @JsonKey(name: 'guid')
  String? guid;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'size')
  int? size;

  @JsonKey(name: 'indexer')
  String? indexer;

  @JsonKey(name: 'indexerId')
  int? indexerId;

  @JsonKey(name: 'publishDate')
  String? publishDate;

  @JsonKey(name: 'downloadUrl')
  String? downloadUrl;

  @JsonKey(name: 'infoUrl')
  String? infoUrl;

  @JsonKey(name: 'commentUrl')
  String? commentUrl;

  @JsonKey(name: 'protocol')
  String? protocol;

  @JsonKey(name: 'age')
  int? age;

  @JsonKey(name: 'ageHours')
  double? ageHours;

  @JsonKey(name: 'ageMinutes')
  double? ageMinutes;

  @JsonKey(name: 'seeders')
  int? seeders;

  @JsonKey(name: 'leechers')
  int? leechers;

  @JsonKey(name: 'grabs')
  int? grabs;

  @JsonKey(name: 'files')
  int? files;

  @JsonKey(name: 'imdbId')
  int? imdbId;

  @JsonKey(name: 'posterUrl')
  String? posterUrl;

  @JsonKey(name: 'approved')
  bool? approved;

  @JsonKey(name: 'categories')
  List<ProwlarrCategory>? categories;

  @JsonKey(name: 'indexerFlags')
  List<dynamic>? indexerFlags;

  ProwlarrItem({
    this.guid,
    this.title,
    this.size,
    this.indexer,
    this.indexerId,
    this.publishDate,
    this.downloadUrl,
    this.infoUrl,
    this.commentUrl,
    this.protocol,
    this.age,
    this.ageHours,
    this.ageMinutes,
    this.seeders,
    this.leechers,
    this.grabs,
    this.files,
    this.imdbId,
    this.posterUrl,
    this.approved,
    this.categories,
    this.indexerFlags,
  });

  factory ProwlarrItem.fromJson(Map<String, dynamic> json) =>
      _$ProwlarrItemFromJson(json);

  Map<String, dynamic> toJson() => _$ProwlarrItemToJson(this);
}
