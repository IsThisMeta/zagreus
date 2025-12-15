// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'synced_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliSyncedItem _$TautulliSyncedItemFromJson(Map<String, dynamic> json) =>
    TautulliSyncedItem(
      deviceName: TautulliUtilities.ensureStringFromJson(json['device_name']),
      platform: TautulliUtilities.ensureStringFromJson(json['platform']),
      userId: TautulliUtilities.ensureIntegerFromJson(json['user_id']),
      user: TautulliUtilities.ensureStringFromJson(json['user']),
      username: TautulliUtilities.ensureStringFromJson(json['username']),
      rootTitle: TautulliUtilities.ensureStringFromJson(json['root_title']),
      syncTitle: TautulliUtilities.ensureStringFromJson(json['sync_title']),
      metadataType:
          TautulliUtilities.ensureStringFromJson(json['metadata_type']),
      contentType: TautulliUtilities.ensureStringFromJson(json['content_type']),
      ratingKey: TautulliUtilities.ensureIntegerFromJson(json['rating_key']),
      state: TautulliUtilities.ensureStringFromJson(json['state']),
      itemCount: TautulliUtilities.ensureIntegerFromJson(json['item_count']),
      itemCompleteCount:
          TautulliUtilities.ensureIntegerFromJson(json['item_complete_count']),
      itemDownloadedCount: TautulliUtilities.ensureIntegerFromJson(
          json['item_downloaded_count']),
      itemDownloadedPercentComplete: TautulliUtilities.ensureIntegerFromJson(
          json['item_downloaded_percent_complete']),
      videoBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['video_bitrate']),
      audioBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['audio_bitrate']),
      photoQuality:
          TautulliUtilities.ensureIntegerFromJson(json['photo_quality']),
      videoQuality:
          TautulliUtilities.ensureIntegerFromJson(json['video_quality']),
      totalSize: TautulliUtilities.ensureIntegerFromJson(json['total_size']),
      failure: TautulliUtilities.ensureStringFromJson(json['failure']),
      clientId: TautulliUtilities.ensureStringFromJson(json['client_id']),
      syncId: TautulliUtilities.ensureStringFromJson(json['sync_id']),
    );

Map<String, dynamic> _$TautulliSyncedItemToJson(TautulliSyncedItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('device_name', instance.deviceName);
  writeNotNull('platform', instance.platform);
  writeNotNull('user_id', instance.userId);
  writeNotNull('user', instance.user);
  writeNotNull('username', instance.username);
  writeNotNull('root_title', instance.rootTitle);
  writeNotNull('sync_title', instance.syncTitle);
  writeNotNull('metadata_type', instance.metadataType);
  writeNotNull('content_type', instance.contentType);
  writeNotNull('rating_key', instance.ratingKey);
  writeNotNull('state', instance.state);
  writeNotNull('item_count', instance.itemCount);
  writeNotNull('item_complete_count', instance.itemCompleteCount);
  writeNotNull('item_downloaded_count', instance.itemDownloadedCount);
  writeNotNull('item_downloaded_percent_complete',
      instance.itemDownloadedPercentComplete);
  writeNotNull('video_bitrate', instance.videoBitrate);
  writeNotNull('audio_bitrate', instance.audioBitrate);
  writeNotNull('photo_quality', instance.photoQuality);
  writeNotNull('video_quality', instance.videoQuality);
  writeNotNull('total_size', instance.totalSize);
  writeNotNull('failure', instance.failure);
  writeNotNull('client_id', instance.clientId);
  writeNotNull('sync_id', instance.syncId);
  return val;
}
