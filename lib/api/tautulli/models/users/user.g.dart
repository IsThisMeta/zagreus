// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliUser _$TautulliUserFromJson(Map<String, dynamic> json) => TautulliUser(
      rowId: TautulliUtilities.ensureIntegerFromJson(json['row_id']),
      userId: TautulliUtilities.ensureIntegerFromJson(json['user_id']),
      friendlyName:
          TautulliUtilities.ensureStringFromJson(json['friendly_name']),
      thumb: TautulliUtilities.ensureStringFromJson(json['thumb']),
      userThumb: TautulliUtilities.ensureStringFromJson(json['user_thumb']),
      email: TautulliUtilities.ensureStringFromJson(json['email']),
      isActive: TautulliUtilities.ensureBooleanFromJson(json['is_active']),
      isAdmin: TautulliUtilities.ensureBooleanFromJson(json['is_admin']),
      isHomeUser: TautulliUtilities.ensureBooleanFromJson(json['is_home_user']),
      isAllowSync:
          TautulliUtilities.ensureBooleanFromJson(json['is_allow_sync']),
      isRestricted:
          TautulliUtilities.ensureBooleanFromJson(json['is_restricted']),
      doNotify: TautulliUtilities.ensureBooleanFromJson(json['do_notify']),
      keepHistory:
          TautulliUtilities.ensureBooleanFromJson(json['keep_history']),
      allowGuest: TautulliUtilities.ensureBooleanFromJson(json['allow_guest']),
      serverToken: TautulliUtilities.ensureStringFromJson(json['server_token']),
      sharedLibraries:
          TautulliUtilities.ensureStringListFromJson(json['shared_libraries']),
      filterAll: TautulliUtilities.ensureStringFromJson(json['filter_all']),
      filterMovies:
          TautulliUtilities.ensureStringFromJson(json['filter_movies']),
      filterTv: TautulliUtilities.ensureStringFromJson(json['filter_tv']),
      filterMusic: TautulliUtilities.ensureStringFromJson(json['filter_music']),
      filterPhotos:
          TautulliUtilities.ensureStringFromJson(json['filter_photos']),
    );

Map<String, dynamic> _$TautulliUserToJson(TautulliUser instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('row_id', instance.rowId);
  writeNotNull('user_id', instance.userId);
  writeNotNull('friendly_name', instance.friendlyName);
  writeNotNull('thumb', instance.thumb);
  writeNotNull('user_thumb', instance.userThumb);
  writeNotNull('email', instance.email);
  writeNotNull('is_active', instance.isActive);
  writeNotNull('is_admin', instance.isAdmin);
  writeNotNull('is_home_user', instance.isHomeUser);
  writeNotNull('is_allow_sync', instance.isAllowSync);
  writeNotNull('is_restricted', instance.isRestricted);
  writeNotNull('do_notify', instance.doNotify);
  writeNotNull('keep_history', instance.keepHistory);
  writeNotNull('allow_guest', instance.allowGuest);
  writeNotNull('server_token', instance.serverToken);
  writeNotNull('shared_libraries', instance.sharedLibraries);
  writeNotNull('filter_all', instance.filterAll);
  writeNotNull('filter_movies', instance.filterMovies);
  writeNotNull('filter_tv', instance.filterTv);
  writeNotNull('filter_music', instance.filterMusic);
  writeNotNull('filter_photos', instance.filterPhotos);
  return val;
}
