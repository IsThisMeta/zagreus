import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// Category model for Prowlarr indexer categories
@JsonSerializable(explicitToJson: true)
class ProwlarrCategory {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'description')
  String? description;

  @JsonKey(name: 'subCategories')
  List<ProwlarrCategory>? subCategories;

  ProwlarrCategory({
    this.id,
    this.name,
    this.description,
    this.subCategories,
  });

  factory ProwlarrCategory.fromJson(Map<String, dynamic> json) =>
      _$ProwlarrCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ProwlarrCategoryToJson(this);
}
