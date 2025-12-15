// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recently_added.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliRecentlyAdded _$TautulliRecentlyAddedFromJson(
        Map<String, dynamic> json) =>
    TautulliRecentlyAdded(
      mediaType:
          TautulliUtilities.mediaTypeFromJson(json['media_type'] as String?),
      sectionId: TautulliUtilities.ensureIntegerFromJson(json['section_id']),
      libraryName: TautulliUtilities.ensureStringFromJson(json['library_name']),
      ratingKey: TautulliUtilities.ensureIntegerFromJson(json['rating_key']),
      parentRatingKey:
          TautulliUtilities.ensureIntegerFromJson(json['parent_rating_key']),
      grandparentRatingKey: TautulliUtilities.ensureIntegerFromJson(
          json['grandparent_rating_key']),
      title: TautulliUtilities.ensureStringFromJson(json['title']),
      parentTitle: TautulliUtilities.ensureStringFromJson(json['parent_title']),
      grandparentTitle:
          TautulliUtilities.ensureStringFromJson(json['grandparent_title']),
      originalTitle:
          TautulliUtilities.ensureStringFromJson(json['original_title']),
      sortTitle: TautulliUtilities.ensureStringFromJson(json['sort_title']),
      mediaIndex: TautulliUtilities.ensureIntegerFromJson(json['media_index']),
      parentMediaIndex:
          TautulliUtilities.ensureIntegerFromJson(json['parent_media_index']),
      studio: TautulliUtilities.ensureStringFromJson(json['studio']),
      contentRating:
          TautulliUtilities.ensureStringFromJson(json['content_rating']),
      summary: TautulliUtilities.ensureStringFromJson(json['summary']),
      tagline: TautulliUtilities.ensureStringFromJson(json['tagline']),
      rating: TautulliUtilities.ensureDoubleFromJson(json['rating']),
      ratingImage: TautulliUtilities.ensureStringFromJson(json['rating_image']),
      audienceRating:
          TautulliUtilities.ensureDoubleFromJson(json['audience_rating']),
      audienceRatingImage:
          TautulliUtilities.ensureStringFromJson(json['audience_rating_image']),
      userRating: TautulliUtilities.ensureDoubleFromJson(json['user_rating']),
      duration:
          TautulliUtilities.millisecondsDurationFromJson(json['duration']),
      year: TautulliUtilities.ensureIntegerFromJson(json['year']),
      thumb: TautulliUtilities.ensureStringFromJson(json['thumb']),
      parentThumb: TautulliUtilities.ensureStringFromJson(json['parent_thumb']),
      grandparentThumb:
          TautulliUtilities.ensureStringFromJson(json['grandparent_thumb']),
      art: TautulliUtilities.ensureStringFromJson(json['art']),
      banner: TautulliUtilities.ensureStringFromJson(json['banner']),
      originallyAvailableAt: TautulliUtilities.ensureStringFromJson(
          json['originally_available_at']),
      addedAt: TautulliUtilities.millisecondsDateTimeFromJson(json['added_at']),
      updatedAt:
          TautulliUtilities.millisecondsDateTimeFromJson(json['updated_at']),
      lastViewedAt: TautulliUtilities.millisecondsDateTimeFromJson(
          json['last_viewed_at']),
      guid: TautulliUtilities.ensureStringFromJson(json['guid']),
      directors: TautulliUtilities.ensureStringListFromJson(json['directors']),
      actors: TautulliUtilities.ensureStringListFromJson(json['actors']),
      writers: TautulliUtilities.ensureStringListFromJson(json['writers']),
      genres: TautulliUtilities.ensureStringListFromJson(json['genres']),
      labels: TautulliUtilities.ensureStringListFromJson(json['labels']),
      collections:
          TautulliUtilities.ensureStringListFromJson(json['collections']),
      fullTitle: TautulliUtilities.ensureStringFromJson(json['full_title']),
      childrenCount:
          TautulliUtilities.ensureIntegerFromJson(json['children_count']),
    );

Map<String, dynamic> _$TautulliRecentlyAddedToJson(
    TautulliRecentlyAdded instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'media_type', TautulliUtilities.mediaTypeToJson(instance.mediaType));
  writeNotNull('section_id', instance.sectionId);
  writeNotNull('library_name', instance.libraryName);
  writeNotNull('rating_key', instance.ratingKey);
  writeNotNull('parent_rating_key', instance.parentRatingKey);
  writeNotNull('grandparent_rating_key', instance.grandparentRatingKey);
  writeNotNull('title', instance.title);
  writeNotNull('parent_title', instance.parentTitle);
  writeNotNull('grandparent_title', instance.grandparentTitle);
  writeNotNull('original_title', instance.originalTitle);
  writeNotNull('sort_title', instance.sortTitle);
  writeNotNull('media_index', instance.mediaIndex);
  writeNotNull('parent_media_index', instance.parentMediaIndex);
  writeNotNull('studio', instance.studio);
  writeNotNull('content_rating', instance.contentRating);
  writeNotNull('summary', instance.summary);
  writeNotNull('tagline', instance.tagline);
  writeNotNull('rating', instance.rating);
  writeNotNull('rating_image', instance.ratingImage);
  writeNotNull('audience_rating', instance.audienceRating);
  writeNotNull('audience_rating_image', instance.audienceRatingImage);
  writeNotNull('user_rating', instance.userRating);
  writeNotNull('duration', instance.duration?.inMicroseconds);
  writeNotNull('year', instance.year);
  writeNotNull('thumb', instance.thumb);
  writeNotNull('parent_thumb', instance.parentThumb);
  writeNotNull('grandparent_thumb', instance.grandparentThumb);
  writeNotNull('art', instance.art);
  writeNotNull('banner', instance.banner);
  writeNotNull('originally_available_at', instance.originallyAvailableAt);
  writeNotNull('added_at', instance.addedAt?.toIso8601String());
  writeNotNull('updated_at', instance.updatedAt?.toIso8601String());
  writeNotNull('last_viewed_at', instance.lastViewedAt?.toIso8601String());
  writeNotNull('guid', instance.guid);
  writeNotNull('directors', instance.directors);
  writeNotNull('writers', instance.writers);
  writeNotNull('actors', instance.actors);
  writeNotNull('genres', instance.genres);
  writeNotNull('labels', instance.labels);
  writeNotNull('collections', instance.collections);
  writeNotNull('full_title', instance.fullTitle);
  writeNotNull('children_count', instance.childrenCount);
  return val;
}
