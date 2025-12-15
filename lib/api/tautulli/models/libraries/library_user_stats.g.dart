// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliLibraryUserStats _$TautulliLibraryUserStatsFromJson(
        Map<String, dynamic> json) =>
    TautulliLibraryUserStats(
      friendlyName:
          TautulliUtilities.ensureStringFromJson(json['friendly_name']),
      userId: TautulliUtilities.ensureIntegerFromJson(json['user_id']),
      userThumb: TautulliUtilities.ensureStringFromJson(json['user_thumb']),
      totalPlays: TautulliUtilities.ensureIntegerFromJson(json['total_plays']),
    );

Map<String, dynamic> _$TautulliLibraryUserStatsToJson(
    TautulliLibraryUserStats instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('friendly_name', instance.friendlyName);
  writeNotNull('user_thumb', instance.userThumb);
  writeNotNull('user_id', instance.userId);
  writeNotNull('total_plays', instance.totalPlays);
  return val;
}
