import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/modules/readarr.dart';

part 'book_file.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrBookFile {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'authorId')
  int? authorId;

  @JsonKey(name: 'bookId')
  int? bookId;

  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'size')
  int? size;

  @JsonKey(name: 'dateAdded')
  DateTime? dateAdded;

  @JsonKey(name: 'quality')
  ReadarrBookFileQuality? quality;

  @JsonKey(name: 'qualityWeight')
  int? qualityWeight;

  @JsonKey(name: 'mediaInfo')
  ReadarrBookFileMediaInfo? mediaInfo;

  @JsonKey(name: 'editionId')
  int? editionId;

  @JsonKey(name: 'calibreId')
  int? calibreId;

  @JsonKey(name: 'part')
  int? part;

  @JsonKey(name: 'author')
  ReadarrAuthor? author;

  @JsonKey(name: 'edition')
  ReadarrEdition? edition;

  @JsonKey(name: 'partCount')
  int? partCount;

  ReadarrBookFile({
    this.id,
    this.authorId,
    this.bookId,
    this.path,
    this.size,
    this.dateAdded,
    this.quality,
    this.qualityWeight,
    this.mediaInfo,
    this.editionId,
    this.calibreId,
    this.part,
    this.author,
    this.edition,
    this.partCount,
  });

  factory ReadarrBookFile.fromJson(Map<String, dynamic> json) =>
      _$ReadarrBookFileFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrBookFileToJson(this);

  @override
  String toString() => json.encode(toJson());
}
