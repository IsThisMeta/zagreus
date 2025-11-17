import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'book_author_metadata.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrBookAuthorMetadata {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'foreignAuthorId')
  String? foreignAuthorId;

  @JsonKey(name: 'titleSlug')
  String? titleSlug;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'sortName')
  String? sortName;

  @JsonKey(name: 'nameLastFirst')
  String? nameLastFirst;

  @JsonKey(name: 'sortNameLastFirst')
  String? sortNameLastFirst;

  @JsonKey(name: 'aliases')
  List<String>? aliases;

  @JsonKey(name: 'overview')
  String? overview;

  @JsonKey(name: 'gender')
  String? gender;

  @JsonKey(name: 'hometown')
  String? hometown;

  @JsonKey(name: 'born')
  DateTime? born;

  @JsonKey(name: 'died')
  DateTime? died;

  @JsonKey(name: 'status')
  String? status;

  ReadarrBookAuthorMetadata({
    this.id,
    this.foreignAuthorId,
    this.titleSlug,
    this.name,
    this.sortName,
    this.nameLastFirst,
    this.sortNameLastFirst,
    this.aliases,
    this.overview,
    this.gender,
    this.hometown,
    this.born,
    this.died,
    this.status,
  });

  factory ReadarrBookAuthorMetadata.fromJson(Map<String, dynamic> json) =>
      _$ReadarrBookAuthorMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrBookAuthorMetadataToJson(this);

  @override
  String toString() => json.encode(toJson());
}
