import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'book_file_quality_quality.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrBookFileQualityQuality {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  ReadarrBookFileQualityQuality({
    this.id,
    this.name,
  });

  factory ReadarrBookFileQualityQuality.fromJson(Map<String, dynamic> json) =>
      _$ReadarrBookFileQualityQualityFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrBookFileQualityQualityToJson(this);

  @override
  String toString() => json.encode(toJson());
}
