import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'author_links.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrAuthorLinks {
  @JsonKey(name: 'url')
  String? url;

  @JsonKey(name: 'name')
  String? name;

  ReadarrAuthorLinks({
    this.url,
    this.name,
  });

  factory ReadarrAuthorLinks.fromJson(Map<String, dynamic> json) =>
      _$ReadarrAuthorLinksFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrAuthorLinksToJson(this);

  @override
  String toString() => json.encode(toJson());
}
