// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtitle_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BazarrSubtitleSearchResult _$BazarrSubtitleSearchResultFromJson(
        Map<String, dynamic> json) =>
    BazarrSubtitleSearchResult(
      provider: json['provider'] as String?,
      language: json['language'] as String?,
      hearingImpaired: json['hearing_impaired'] as String?,
      forced: json['forced'] as String?,
      subtitle: json['subtitle'] as String?,
      uploader: json['uploader'] as String?,
      url: json['url'] as String?,
      score: (json['score'] as num?)?.toInt(),
      origScore: (json['orig_score'] as num?)?.toInt(),
      scoreWithoutHash: (json['score_without_hash'] as num?)?.toInt(),
      matches:
          (json['matches'] as List<dynamic>?)?.map((e) => e as String).toList(),
      dontMatches: (json['dont_matches'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      releaseInfo: (json['release_info'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$BazarrSubtitleSearchResultToJson(
    BazarrSubtitleSearchResult instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('provider', instance.provider);
  writeNotNull('language', instance.language);
  writeNotNull('hearing_impaired', instance.hearingImpaired);
  writeNotNull('forced', instance.forced);
  writeNotNull('subtitle', instance.subtitle);
  writeNotNull('uploader', instance.uploader);
  writeNotNull('url', instance.url);
  writeNotNull('score', instance.score);
  writeNotNull('orig_score', instance.origScore);
  writeNotNull('score_without_hash', instance.scoreWithoutHash);
  writeNotNull('matches', instance.matches);
  writeNotNull('dont_matches', instance.dontMatches);
  writeNotNull('release_info', instance.releaseInfo);
  return val;
}
