import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/modules/readarr.dart';

part 'author.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrAuthor {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'authorName')
  String? authorName;

  @JsonKey(name: 'authorNameLastFirst')
  String? authorNameLastFirst;

  @JsonKey(name: 'foreignAuthorId')
  String? foreignAuthorId;

  @JsonKey(name: 'titleSlug')
  String? titleSlug;

  @JsonKey(name: 'overview')
  String? overview;

  @JsonKey(name: 'disambiguation')
  String? disambiguation;

  @JsonKey(name: 'links')
  List<ReadarrAuthorLinks>? links;

  @JsonKey(name: 'images')
  List<ReadarrImage>? images;

  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'qualityProfileId')
  int? qualityProfileId;

  @JsonKey(name: 'metadataProfileId')
  int? metadataProfileId;

  @JsonKey(name: 'monitored')
  bool? monitored;

  @JsonKey(name: 'monitorNewItems')
  String? monitorNewItems;

  @JsonKey(name: 'rootFolderPath')
  String? rootFolderPath;

  @JsonKey(name: 'genres')
  List<String>? genres;

  @JsonKey(name: 'cleanName')
  String? cleanName;

  @JsonKey(name: 'sortName')
  String? sortName;

  @JsonKey(name: 'sortNameLastFirst')
  String? sortNameLastFirst;

  @JsonKey(name: 'tags')
  List<int>? tags;

  @JsonKey(name: 'added')
  DateTime? added;

  @JsonKey(name: 'ratings')
  ReadarrAuthorRatings? ratings;

  @JsonKey(name: 'statistics')
  ReadarrAuthorStatistics? statistics;

  ReadarrAuthor({
    this.id,
    this.authorName,
    this.authorNameLastFirst,
    this.foreignAuthorId,
    this.titleSlug,
    this.overview,
    this.disambiguation,
    this.links,
    this.images,
    this.path,
    this.qualityProfileId,
    this.metadataProfileId,
    this.monitored,
    this.monitorNewItems,
    this.rootFolderPath,
    this.genres,
    this.cleanName,
    this.sortName,
    this.sortNameLastFirst,
    this.tags,
    this.added,
    this.ratings,
    this.statistics,
  });

  factory ReadarrAuthor.fromJson(Map<String, dynamic> json) =>
      _$ReadarrAuthorFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrAuthorToJson(this);

  @override
  String toString() => json.encode(toJson());
}
