// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliSearch _$TautulliSearchFromJson(Map<String, dynamic> json) =>
    TautulliSearch(
      count: TautulliUtilities.ensureIntegerFromJson(json['results_count']),
      results: TautulliSearch._resultsFromJson(
          json['results_list'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TautulliSearchToJson(TautulliSearch instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('results_count', instance.count);
  writeNotNull('results_list', TautulliSearch._resultsToJson(instance.results));
  return val;
}
