import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/readarr/models/author/author.dart';
import 'package:zagreus/api/readarr/models/author/author_links.dart';
import 'package:zagreus/api/readarr/models/book/book_author_metadata.dart';
import 'package:zagreus/api/readarr/models/book/book_ratings.dart';
import 'package:zagreus/api/readarr/models/book/book_statistics.dart';
import 'package:zagreus/api/readarr/models/book_file/book_file.dart';
import 'package:zagreus/api/readarr/models/edition/edition.dart';
import 'package:zagreus/api/readarr/models/series/series_book_link.dart';

part 'book.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrBook {
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

  @JsonKey(name: 'lastInfoSync')
  DateTime? lastInfoSync;

  @JsonKey(name: 'added')
  DateTime? added;

  @JsonKey(name: 'addOptions')
  Map<String, dynamic>? addOptions;

  @JsonKey(name: 'authorMetadata')
  ReadarrBookAuthorMetadata? authorMetadata;

  @JsonKey(name: 'author')
  ReadarrAuthor? author;

  @JsonKey(name: 'editions')
  List<ReadarrEdition>? editions;

  @JsonKey(name: 'bookFiles')
  List<ReadarrBookFile>? bookFiles;

  @JsonKey(name: 'seriesLinks')
  List<ReadarrSeriesBookLink>? seriesLinks;

  @JsonKey(name: 'statistics')
  ReadarrBookStatistics? statistics;

  ReadarrBook({
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
    this.lastInfoSync,
    this.added,
    this.addOptions,
    this.authorMetadata,
    this.author,
    this.editions,
    this.bookFiles,
    this.seriesLinks,
    this.statistics,
  });

  factory ReadarrBook.fromJson(Map<String, dynamic> json) =>
      _$ReadarrBookFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrBookToJson(this);

  @override
  String toString() => json.encode(toJson());
}
