import 'package:flutter/material.dart';
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

  /// Returns an icon based on the Newznab category ID ranges
  IconData get icon {
    final categoryId = id ?? 0;
    if (categoryId >= 1000 && categoryId <= 1999) return Icons.games_rounded;
    if (categoryId >= 2000 && categoryId <= 2999) return Icons.movie_rounded;
    if (categoryId >= 3000 && categoryId <= 3999) return Icons.music_note_rounded;
    if (categoryId >= 4000 && categoryId <= 4999) return Icons.computer_rounded;
    if (categoryId >= 5000 && categoryId <= 5999) return Icons.live_tv_rounded;
    if (categoryId >= 6000 && categoryId <= 6999) return Icons.lock_rounded;
    if (categoryId >= 7000 && categoryId <= 7999) return Icons.book_rounded;
    return Icons.category_rounded;
  }
}
