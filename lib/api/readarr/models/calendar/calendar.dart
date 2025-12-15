import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/readarr/models/author/author.dart';
import 'package:zagreus/api/readarr/models/author/author_links.dart';
import 'package:zagreus/api/readarr/models/book/book_ratings.dart';
import 'package:zagreus/api/readarr/models/book_file/book_file.dart';
import 'package:zagreus/api/readarr/models/edition/edition.dart';

part 'calendar.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrCalendar {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'authorId')
  int? authorId;

  @JsonKey(name: 'foreignBookId')
  String? foreignBookId;

  @JsonKey(name: 'titleSlug')
  String? titleSlug;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'releaseDate')
  DateTime? releaseDate;

  @JsonKey(name: 'links')
  List<ReadarrAuthorLinks>? links;

  @JsonKey(name: 'genres')
  List<String>? genres;

  @JsonKey(name: 'ratings')
  ReadarrBookRatings? ratings;

  @JsonKey(name: 'cleanTitle')
  String? cleanTitle;

  @JsonKey(name: 'monitored')
  bool? monitored;

  @JsonKey(name: 'anyEditionOk')
  bool? anyEditionOk;

  @JsonKey(name: 'author')
  ReadarrAuthor? author;

  @JsonKey(name: 'editions')
  List<ReadarrEdition>? editions;

  @JsonKey(name: 'bookFiles')
  List<ReadarrBookFile>? bookFiles;

  ReadarrCalendar({
    this.id,
    this.authorId,
    this.foreignBookId,
    this.titleSlug,
    this.title,
    this.releaseDate,
    this.links,
    this.genres,
    this.ratings,
    this.cleanTitle,
    this.monitored,
    this.anyEditionOk,
    this.author,
    this.editions,
    this.bookFiles,
  });

  factory ReadarrCalendar.fromJson(Map<String, dynamic> json) =>
      _$ReadarrCalendarFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrCalendarToJson(this);

  @override
  String toString() => json.encode(toJson());
}
