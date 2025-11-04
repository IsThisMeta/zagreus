import 'package:zagreus/vendor.dart';

part 'models.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class OverseerrResponse<T> {
  @JsonKey(name: 'pageInfo')
  final OverseerrPageInfo pageInfo;

  @JsonKey(name: 'results')
  final List<T> results;

  OverseerrResponse({
    required this.pageInfo,
    required this.results,
  });

  factory OverseerrResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$OverseerrResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$OverseerrResponseToJson(this, toJsonT);
}

@JsonSerializable()
@HiveType(typeId: 87, adapterName: 'OverseerrPageInfoAdapter')
class OverseerrPageInfo extends HiveObject {
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

  OverseerrPageInfo({
    required this.pages,
    required this.pageSize,
    required this.results,
    required this.page,
  });

  factory OverseerrPageInfo.fromJson(Map<String, dynamic> json) =>
      _$OverseerrPageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrPageInfoToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 88, adapterName: 'OverseerrRequestAdapter')
class OverseerrRequest extends HiveObject {
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
  final OverseerrMedia media;

  @JsonKey(name: 'seasons')
  @HiveField(13)
  final List<OverseerrSeason> seasons;

  @JsonKey(name: 'modifiedBy')
  @HiveField(14)
  final OverseerrUser? modifiedBy;

  @JsonKey(name: 'requestedBy')
  @HiveField(15)
  final OverseerrUser requestedBy;

  @JsonKey(name: 'seasonCount')
  @HiveField(16)
  final int seasonCount;

  OverseerrRequest({
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

  factory OverseerrRequest.fromJson(Map<String, dynamic> json) =>
      _$OverseerrRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrRequestToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 89, adapterName: 'OverseerrIssueAdapter')
class OverseerrIssue extends HiveObject {
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
  final OverseerrCreatedBy createdBy;

  @JsonKey(name: 'media')
  @HiveField(8)
  final OverseerrMedia media;

  @JsonKey(name: 'comments')
  @HiveField(9)
  final List<OverseerrComment>? comments;

  OverseerrIssue({
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

  factory OverseerrIssue.fromJson(Map<String, dynamic> json) =>
      _$OverseerrIssueFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrIssueToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 90, adapterName: 'OverseerrMediaAdapter')
class OverseerrMedia extends HiveObject {
  @JsonKey(name: 'downloadStatus')
  @HiveField(0)
  final List<OverseerrDownloadStatus> downloadStatus;

  @JsonKey(name: 'downloadStatus4k')
  @HiveField(1)
  final List<OverseerrDownloadStatus> downloadStatus4k;

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
  final OverseerrMovie? movie;

  @JsonKey(name: 'series')
  @HiveField(25)
  final OverseerrSeries? series;

  OverseerrMedia({
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

  factory OverseerrMedia.fromJson(Map<String, dynamic> json) =>
      _$OverseerrMediaFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrMediaToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 91, adapterName: 'OverseerrMovieAdapter')
class OverseerrMovie extends HiveObject {
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

  OverseerrMovie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
  });

  factory OverseerrMovie.fromJson(Map<String, dynamic> json) =>
      _$OverseerrMovieFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrMovieToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 92, adapterName: 'OverseerrSeriesAdapter')
class OverseerrSeries extends HiveObject {
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

  OverseerrSeries({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
    this.firstAirDate,
  });

  factory OverseerrSeries.fromJson(Map<String, dynamic> json) =>
      _$OverseerrSeriesFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrSeriesToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 93, adapterName: 'OverseerrUserAdapter')
class OverseerrUser extends HiveObject {
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

  OverseerrUser({
    required this.id,
    required this.email,
    this.plexUsername,
    this.jellyfinUsername,
    this.username,
    required this.displayName,
    required this.avatar,
    required this.requestCount,
  });

  factory OverseerrUser.fromJson(Map<String, dynamic> json) =>
      _$OverseerrUserFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrUserToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 94, adapterName: 'OverseerrCreatedByAdapter')
class OverseerrCreatedBy extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'displayName')
  @HiveField(1)
  final String displayName;

  @JsonKey(name: 'avatar')
  @HiveField(2)
  final String avatar;

  OverseerrCreatedBy({
    required this.id,
    required this.displayName,
    required this.avatar,
  });

  factory OverseerrCreatedBy.fromJson(Map<String, dynamic> json) =>
      _$OverseerrCreatedByFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrCreatedByToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 95, adapterName: 'OverseerrSeasonAdapter')
class OverseerrSeason extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'seasonNumber')
  @HiveField(1)
  final int seasonNumber;

  @JsonKey(name: 'status')
  @HiveField(2)
  final int status;

  OverseerrSeason({
    required this.id,
    required this.seasonNumber,
    required this.status,
  });

  factory OverseerrSeason.fromJson(Map<String, dynamic> json) =>
      _$OverseerrSeasonFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrSeasonToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 96, adapterName: 'OverseerrCommentAdapter')
class OverseerrComment extends HiveObject {
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
  final OverseerrUser user;

  OverseerrComment({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.user,
  });

  factory OverseerrComment.fromJson(Map<String, dynamic> json) =>
      _$OverseerrCommentFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrCommentToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 97, adapterName: 'OverseerrDownloadStatusAdapter')
class OverseerrDownloadStatus extends HiveObject {
  @JsonKey(name: 'title')
  @HiveField(0)
  final String title;

  @JsonKey(name: 'size')
  @HiveField(1)
  final int size;

  @JsonKey(name: 'status')
  @HiveField(2)
  final String status;

  OverseerrDownloadStatus({
    required this.title,
    required this.size,
    required this.status,
  });

  factory OverseerrDownloadStatus.fromJson(Map<String, dynamic> json) =>
      _$OverseerrDownloadStatusFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrDownloadStatusToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 98, adapterName: 'OverseerrServerConfigAdapter')
class OverseerrServerConfig extends HiveObject {
  @JsonKey(name: 'server')
  @HiveField(0)
  final OverseerrServer server;

  @JsonKey(name: 'profiles')
  @HiveField(1)
  final List<OverseerrProfile> profiles;

  @JsonKey(name: 'rootFolders')
  @HiveField(2)
  final List<OverseerrRootFolder> rootFolders;

  @JsonKey(name: 'tags')
  @HiveField(3)
  final List<OverseerrTag> tags;

  OverseerrServerConfig({
    required this.server,
    required this.profiles,
    required this.rootFolders,
    required this.tags,
  });

  factory OverseerrServerConfig.fromJson(Map<String, dynamic> json) =>
      _$OverseerrServerConfigFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrServerConfigToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 99, adapterName: 'OverseerrServerAdapter')
class OverseerrServer extends HiveObject {
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

  OverseerrServer({
    required this.id,
    required this.name,
    required this.hostname,
    required this.port,
    required this.isDefault,
  });

  factory OverseerrServer.fromJson(Map<String, dynamic> json) =>
      _$OverseerrServerFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrServerToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 100, adapterName: 'OverseerrProfileAdapter')
class OverseerrProfile extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'name')
  @HiveField(1)
  final String name;

  OverseerrProfile({
    required this.id,
    required this.name,
  });

  factory OverseerrProfile.fromJson(Map<String, dynamic> json) =>
      _$OverseerrProfileFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrProfileToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 101, adapterName: 'OverseerrRootFolderAdapter')
class OverseerrRootFolder extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'path')
  @HiveField(1)
  final String path;

  OverseerrRootFolder({
    required this.id,
    required this.path,
  });

  factory OverseerrRootFolder.fromJson(Map<String, dynamic> json) =>
      _$OverseerrRootFolderFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrRootFolderToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 102, adapterName: 'OverseerrTagAdapter')
class OverseerrTag extends HiveObject {
  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'label')
  @HiveField(1)
  final String label;

  OverseerrTag({
    required this.id,
    required this.label,
  });

  factory OverseerrTag.fromJson(Map<String, dynamic> json) =>
      _$OverseerrTagFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrTagToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 103, adapterName: 'OverseerrApiStatusAdapter')
class OverseerrApiStatus extends HiveObject {
  @JsonKey(name: 'version')
  @HiveField(0)
  final String version;

  @JsonKey(name: 'commitTag')
  @HiveField(1)
  final String? commitTag;

  @JsonKey(name: 'updateAvailable')
  @HiveField(2)
  final bool updateAvailable;

  OverseerrApiStatus({
    required this.version,
    this.commitTag,
    required this.updateAvailable,
  });

  factory OverseerrApiStatus.fromJson(Map<String, dynamic> json) =>
      _$OverseerrApiStatusFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrApiStatusToJson(this);
}

@JsonSerializable()
class OverseerrMediaRequest {
  @JsonKey(name: 'serverId')
  final int? serverId;

  @JsonKey(name: 'profileId')
  final int? profileId;

  @JsonKey(name: 'rootFolder')
  final String? rootFolder;

  @JsonKey(name: 'tags')
  final List<int>? tags;

  OverseerrMediaRequest({
    this.serverId,
    this.profileId,
    this.rootFolder,
    this.tags,
  });

  factory OverseerrMediaRequest.fromJson(Map<String, dynamic> json) =>
      _$OverseerrMediaRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrMediaRequestToJson(this);
}

@JsonSerializable()
class OverseerrMessage {
  @JsonKey(name: 'message')
  final String message;

  OverseerrMessage({
    required this.message,
  });

  factory OverseerrMessage.fromJson(Map<String, dynamic> json) =>
      _$OverseerrMessageFromJson(json);

  Map<String, dynamic> toJson() => _$OverseerrMessageToJson(this);
}
