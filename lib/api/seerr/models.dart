import 'package:zagreus/vendor.dart';

part 'models.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class SeerrResponse<T> {
  @JsonKey(name: 'pageInfo')
  final SeerrPageInfo pageInfo;

  @JsonKey(name: 'results')
  final List<T> results;

  SeerrResponse({
    required this.pageInfo,
    required this.results,
  });

  factory SeerrResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$SeerrResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$SeerrResponseToJson(this, toJsonT);
}

@JsonSerializable()
@HiveType(typeId: 87, adapterName: 'SeerrPageInfoAdapter')
class SeerrPageInfo extends HiveObject {
  @JsonKey(name: 'pages')
  @HiveField(0)
  final int pages;

  @JsonKey(name: 'pageSize')
  @HiveField(1)
  final int pageSize;

  @JsonKey(name: 'results')
  @HiveField(2)
  final int results;

  @JsonKey(name: 'page')
  @HiveField(3)
  final int page;

  SeerrPageInfo({
    required this.pages,
    required this.pageSize,
    required this.results,
    required this.page,
  });

  factory SeerrPageInfo.fromJson(Map<String, dynamic> json) =>
      _$SeerrPageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrPageInfoToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 88, adapterName: 'SeerrRequestAdapter')
class SeerrRequest extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'status')
  @HiveField(1)
  final int status;

  @JsonKey(name: 'createdAt')
  @HiveField(2)
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  @HiveField(3)
  final String updatedAt;

  @JsonKey(name: 'type')
  @HiveField(4)
  final String type;

  @JsonKey(name: 'is4k')
  @HiveField(5)
  final bool is4k;

  @JsonKey(name: 'serverId')
  @HiveField(6)
  final int? serverId;

  @JsonKey(name: 'profileId')
  @HiveField(7)
  final int? profileId;

  @JsonKey(name: 'rootFolder')
  @HiveField(8)
  final String? rootFolder;

  @JsonKey(name: 'languageProfileId')
  @HiveField(9)
  final int? languageProfileId;

  @JsonKey(name: 'tags')
  @HiveField(10)
  final List<int>? tags;

  @JsonKey(name: 'isAutoRequest')
  @HiveField(11)
  final bool isAutoRequest;

  @JsonKey(name: 'media')
  @HiveField(12)
  final SeerrMedia media;

  @JsonKey(name: 'seasons')
  @HiveField(13)
  final List<SeerrSeason> seasons;

  @JsonKey(name: 'modifiedBy')
  @HiveField(14)
  final SeerrUser? modifiedBy;

  @JsonKey(name: 'requestedBy')
  @HiveField(15)
  final SeerrUser requestedBy;

  @JsonKey(name: 'seasonCount')
  @HiveField(16)
  final int seasonCount;

  SeerrRequest({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    required this.is4k,
    this.serverId,
    this.profileId,
    this.rootFolder,
    this.languageProfileId,
    this.tags,
    required this.isAutoRequest,
    required this.media,
    required this.seasons,
    this.modifiedBy,
    required this.requestedBy,
    required this.seasonCount,
  });

  factory SeerrRequest.fromJson(Map<String, dynamic> json) =>
      _$SeerrRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrRequestToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 89, adapterName: 'SeerrIssueAdapter')
class SeerrIssue extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'issueType')
  @HiveField(1)
  final int issueType;

  @JsonKey(name: 'status')
  @HiveField(2)
  final int status;

  @JsonKey(name: 'problemSeason')
  @HiveField(3)
  final int problemSeason;

  @JsonKey(name: 'problemEpisode')
  @HiveField(4)
  final int problemEpisode;

  @JsonKey(name: 'createdAt')
  @HiveField(5)
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  @HiveField(6)
  final String updatedAt;

  @JsonKey(name: 'createdBy')
  @HiveField(7)
  final SeerrCreatedBy createdBy;

  @JsonKey(name: 'media')
  @HiveField(8)
  final SeerrMedia media;

  @JsonKey(name: 'comments')
  @HiveField(9)
  final List<SeerrComment>? comments;

  SeerrIssue({
    required this.id,
    required this.issueType,
    required this.status,
    required this.problemSeason,
    required this.problemEpisode,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.media,
    this.comments,
  });

  factory SeerrIssue.fromJson(Map<String, dynamic> json) =>
      _$SeerrIssueFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrIssueToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 90, adapterName: 'SeerrMediaAdapter')
class SeerrMedia extends HiveObject {
  @JsonKey(name: 'downloadStatus')
  @HiveField(0)
  final List<SeerrDownloadStatus> downloadStatus;

  @JsonKey(name: 'downloadStatus4k')
  @HiveField(1)
  final List<SeerrDownloadStatus> downloadStatus4k;

  @JsonKey(name: 'id')
  @HiveField(2)
  final int id;

  @JsonKey(name: 'mediaType')
  @HiveField(3)
  final String mediaType;

  @JsonKey(name: 'tmdbId')
  @HiveField(4)
  final int tmdbId;

  @JsonKey(name: 'tvdbId')
  @HiveField(5)
  final int? tvdbId;

  @JsonKey(name: 'imdbId')
  @HiveField(6)
  final String? imdbId;

  @JsonKey(name: 'status')
  @HiveField(7)
  final int status;

  @JsonKey(name: 'status4k')
  @HiveField(8)
  final int status4k;

  @JsonKey(name: 'createdAt')
  @HiveField(9)
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  @HiveField(10)
  final String updatedAt;

  @JsonKey(name: 'lastSeasonChange')
  @HiveField(11)
  final String lastSeasonChange;

  @JsonKey(name: 'mediaAddedAt')
  @HiveField(12)
  final String? mediaAddedAt;

  @JsonKey(name: 'serviceId')
  @HiveField(13)
  final int? serviceId;

  @JsonKey(name: 'serviceId4k')
  @HiveField(14)
  final int? serviceId4k;

  @JsonKey(name: 'externalServiceId')
  @HiveField(15)
  final int? externalServiceId;

  @JsonKey(name: 'externalServiceId4k')
  @HiveField(16)
  final int? externalServiceId4k;

  @JsonKey(name: 'externalServiceSlug')
  @HiveField(17)
  final String? externalServiceSlug;

  @JsonKey(name: 'externalServiceSlug4k')
  @HiveField(18)
  final String? externalServiceSlug4k;

  @JsonKey(name: 'ratingKey')
  @HiveField(19)
  final String? ratingKey;

  @JsonKey(name: 'ratingKey4k')
  @HiveField(20)
  final String? ratingKey4k;

  @JsonKey(name: 'jellyfinMediaId')
  @HiveField(21)
  final String? jellyfinMediaId;

  @JsonKey(name: 'jellyfinMediaId4k')
  @HiveField(22)
  final String? jellyfinMediaId4k;

  @JsonKey(name: 'serviceUrl')
  @HiveField(23)
  final String? serviceUrl;

  @JsonKey(name: 'movie')
  @HiveField(24)
  final SeerrMovie? movie;

  @JsonKey(name: 'series')
  @HiveField(25)
  final SeerrSeries? series;

  SeerrMedia({
    required this.downloadStatus,
    required this.downloadStatus4k,
    required this.id,
    required this.mediaType,
    required this.tmdbId,
    this.tvdbId,
    this.imdbId,
    required this.status,
    required this.status4k,
    required this.createdAt,
    required this.updatedAt,
    required this.lastSeasonChange,
    this.mediaAddedAt,
    this.serviceId,
    this.serviceId4k,
    this.externalServiceId,
    this.externalServiceId4k,
    this.externalServiceSlug,
    this.externalServiceSlug4k,
    this.ratingKey,
    this.ratingKey4k,
    this.jellyfinMediaId,
    this.jellyfinMediaId4k,
    this.serviceUrl,
    this.movie,
    this.series,
  });

  factory SeerrMedia.fromJson(Map<String, dynamic> json) =>
      _$SeerrMediaFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrMediaToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 91, adapterName: 'SeerrMovieAdapter')
class SeerrMovie extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'title')
  @HiveField(1)
  final String title;

  @JsonKey(name: 'posterPath')
  @HiveField(2)
  final String? posterPath;

  @JsonKey(name: 'backdropPath')
  @HiveField(3)
  final String? backdropPath;

  @JsonKey(name: 'releaseDate')
  @HiveField(4)
  final String? releaseDate;

  SeerrMovie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
  });

  factory SeerrMovie.fromJson(Map<String, dynamic> json) =>
      _$SeerrMovieFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrMovieToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 92, adapterName: 'SeerrSeriesAdapter')
class SeerrSeries extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'name')
  @HiveField(1)
  final String name;

  @JsonKey(name: 'posterPath')
  @HiveField(2)
  final String? posterPath;

  @JsonKey(name: 'backdropPath')
  @HiveField(3)
  final String? backdropPath;

  @JsonKey(name: 'firstAirDate')
  @HiveField(4)
  final String? firstAirDate;

  SeerrSeries({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
    this.firstAirDate,
  });

  factory SeerrSeries.fromJson(Map<String, dynamic> json) =>
      _$SeerrSeriesFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrSeriesToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 93, adapterName: 'SeerrUserAdapter')
class SeerrUser extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'email')
  @HiveField(1)
  final String email;

  @JsonKey(name: 'plexUsername')
  @HiveField(2)
  final String? plexUsername;

  @JsonKey(name: 'jellyfinUsername')
  @HiveField(3)
  final String? jellyfinUsername;

  @JsonKey(name: 'username')
  @HiveField(4)
  final String? username;

  @JsonKey(name: 'displayName')
  @HiveField(5)
  final String displayName;

  @JsonKey(name: 'avatar')
  @HiveField(6)
  final String avatar;

  @JsonKey(name: 'requestCount')
  @HiveField(7)
  final int requestCount;

  SeerrUser({
    required this.id,
    required this.email,
    this.plexUsername,
    this.jellyfinUsername,
    this.username,
    required this.displayName,
    required this.avatar,
    required this.requestCount,
  });

  factory SeerrUser.fromJson(Map<String, dynamic> json) =>
      _$SeerrUserFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrUserToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 94, adapterName: 'SeerrCreatedByAdapter')
class SeerrCreatedBy extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'displayName')
  @HiveField(1)
  final String displayName;

  @JsonKey(name: 'avatar')
  @HiveField(2)
  final String avatar;

  SeerrCreatedBy({
    required this.id,
    required this.displayName,
    required this.avatar,
  });

  factory SeerrCreatedBy.fromJson(Map<String, dynamic> json) =>
      _$SeerrCreatedByFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrCreatedByToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 95, adapterName: 'SeerrSeasonAdapter')
class SeerrSeason extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'seasonNumber')
  @HiveField(1)
  final int seasonNumber;

  @JsonKey(name: 'status')
  @HiveField(2)
  final int status;

  SeerrSeason({
    required this.id,
    required this.seasonNumber,
    required this.status,
  });

  factory SeerrSeason.fromJson(Map<String, dynamic> json) =>
      _$SeerrSeasonFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrSeasonToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 96, adapterName: 'SeerrCommentAdapter')
class SeerrComment extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'message')
  @HiveField(1)
  final String message;

  @JsonKey(name: 'createdAt')
  @HiveField(2)
  final String createdAt;

  @JsonKey(name: 'user')
  @HiveField(3)
  final SeerrUser user;

  SeerrComment({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.user,
  });

  factory SeerrComment.fromJson(Map<String, dynamic> json) =>
      _$SeerrCommentFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrCommentToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 97, adapterName: 'SeerrDownloadStatusAdapter')
class SeerrDownloadStatus extends HiveObject {
  @JsonKey(name: 'title')
  @HiveField(0)
  final String title;

  @JsonKey(name: 'size')
  @HiveField(1)
  final int size;

  @JsonKey(name: 'status')
  @HiveField(2)
  final String status;

  SeerrDownloadStatus({
    required this.title,
    required this.size,
    required this.status,
  });

  factory SeerrDownloadStatus.fromJson(Map<String, dynamic> json) =>
      _$SeerrDownloadStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrDownloadStatusToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 98, adapterName: 'SeerrServerConfigAdapter')
class SeerrServerConfig extends HiveObject {
  @JsonKey(name: 'server')
  @HiveField(0)
  final SeerrServer server;

  @JsonKey(name: 'profiles')
  @HiveField(1)
  final List<SeerrProfile> profiles;

  @JsonKey(name: 'rootFolders')
  @HiveField(2)
  final List<SeerrRootFolder> rootFolders;

  @JsonKey(name: 'tags')
  @HiveField(3)
  final List<SeerrTag> tags;

  SeerrServerConfig({
    required this.server,
    required this.profiles,
    required this.rootFolders,
    required this.tags,
  });

  factory SeerrServerConfig.fromJson(Map<String, dynamic> json) =>
      _$SeerrServerConfigFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrServerConfigToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 99, adapterName: 'SeerrServerAdapter')
class SeerrServer extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'name')
  @HiveField(1)
  final String name;

  @JsonKey(name: 'hostname')
  @HiveField(2)
  final String hostname;

  @JsonKey(name: 'port')
  @HiveField(3)
  final int port;

  @JsonKey(name: 'isDefault')
  @HiveField(4)
  final bool isDefault;

  SeerrServer({
    required this.id,
    required this.name,
    required this.hostname,
    required this.port,
    required this.isDefault,
  });

  factory SeerrServer.fromJson(Map<String, dynamic> json) =>
      _$SeerrServerFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrServerToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 100, adapterName: 'SeerrProfileAdapter')
class SeerrProfile extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'name')
  @HiveField(1)
  final String name;

  SeerrProfile({
    required this.id,
    required this.name,
  });

  factory SeerrProfile.fromJson(Map<String, dynamic> json) =>
      _$SeerrProfileFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrProfileToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 101, adapterName: 'SeerrRootFolderAdapter')
class SeerrRootFolder extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'path')
  @HiveField(1)
  final String path;

  SeerrRootFolder({
    required this.id,
    required this.path,
  });

  factory SeerrRootFolder.fromJson(Map<String, dynamic> json) =>
      _$SeerrRootFolderFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrRootFolderToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 102, adapterName: 'SeerrTagAdapter')
class SeerrTag extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'label')
  @HiveField(1)
  final String label;

  SeerrTag({
    required this.id,
    required this.label,
  });

  factory SeerrTag.fromJson(Map<String, dynamic> json) =>
      _$SeerrTagFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrTagToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 103, adapterName: 'SeerrApiStatusAdapter')
class SeerrApiStatus extends HiveObject {
  @JsonKey(name: 'version')
  @HiveField(0)
  final String version;

  @JsonKey(name: 'commitTag')
  @HiveField(1)
  final String? commitTag;

  @JsonKey(name: 'updateAvailable')
  @HiveField(2)
  final bool updateAvailable;

  SeerrApiStatus({
    required this.version,
    this.commitTag,
    required this.updateAvailable,
  });

  factory SeerrApiStatus.fromJson(Map<String, dynamic> json) =>
      _$SeerrApiStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrApiStatusToJson(this);
}

@JsonSerializable()
class SeerrMediaRequest {
  @JsonKey(name: 'serverId')
  final int? serverId;

  @JsonKey(name: 'profileId')
  final int? profileId;

  @JsonKey(name: 'rootFolder')
  final String? rootFolder;

  @JsonKey(name: 'tags')
  final List<int>? tags;

  SeerrMediaRequest({
    this.serverId,
    this.profileId,
    this.rootFolder,
    this.tags,
  });

  factory SeerrMediaRequest.fromJson(Map<String, dynamic> json) =>
      _$SeerrMediaRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrMediaRequestToJson(this);
}

@JsonSerializable()
class SeerrMessage {
  @JsonKey(name: 'message')
  final String message;

  SeerrMessage({
    required this.message,
  });

  factory SeerrMessage.fromJson(Map<String, dynamic> json) =>
      _$SeerrMessageFromJson(json);

  Map<String, dynamic> toJson() => _$SeerrMessageToJson(this);
}
