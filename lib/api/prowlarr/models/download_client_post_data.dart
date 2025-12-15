import 'package:json_annotation/json_annotation.dart';

part 'download_client_post_data.g.dart';

/// Data for downloading a release to a client
@JsonSerializable()
class DownloadClientPostData {
  @JsonKey(name: 'guid')
  String guid;

  @JsonKey(name: 'indexerId')
  int indexerId;

  DownloadClientPostData({
    required this.guid,
    required this.indexerId,
  });

  factory DownloadClientPostData.fromJson(Map<String, dynamic> json) =>
      _$DownloadClientPostDataFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadClientPostDataToJson(this);
}
