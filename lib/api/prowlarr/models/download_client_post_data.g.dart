// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_client_post_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadClientPostData _$DownloadClientPostDataFromJson(
        Map<String, dynamic> json) =>
    DownloadClientPostData(
      guid: json['guid'] as String,
      indexerId: (json['indexerId'] as num).toInt(),
    );

Map<String, dynamic> _$DownloadClientPostDataToJson(
        DownloadClientPostData instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'indexerId': instance.indexerId,
    };
