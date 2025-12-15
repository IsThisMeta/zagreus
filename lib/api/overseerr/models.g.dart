// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OverseerrPageInfoAdapter extends TypeAdapter<OverseerrPageInfo> {
  @override
  final int typeId = 87;

  @override
  OverseerrPageInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrPageInfo(
      pages: fields[0] as int,
      pageSize: fields[1] as int,
      results: fields[2] as int,
      page: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrPageInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.pages)
      ..writeByte(1)
      ..write(obj.pageSize)
      ..writeByte(2)
      ..write(obj.results)
      ..writeByte(3)
      ..write(obj.page);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrPageInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrRequestAdapter extends TypeAdapter<OverseerrRequest> {
  @override
  final int typeId = 88;

  @override
  OverseerrRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrRequest(
      id: fields[0] as int,
      status: fields[1] as int,
      createdAt: fields[2] as String,
      updatedAt: fields[3] as String,
      type: fields[4] as String,
      is4k: fields[5] as bool,
      serverId: fields[6] as int?,
      profileId: fields[7] as int?,
      rootFolder: fields[8] as String?,
      languageProfileId: fields[9] as int?,
      tags: (fields[10] as List?)?.cast<int>(),
      isAutoRequest: fields[11] as bool,
      media: fields[12] as OverseerrMedia,
      seasons: (fields[13] as List).cast<OverseerrSeason>(),
      modifiedBy: fields[14] as OverseerrUser?,
      requestedBy: fields[15] as OverseerrUser,
      seasonCount: fields[16] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrRequest obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.is4k)
      ..writeByte(6)
      ..write(obj.serverId)
      ..writeByte(7)
      ..write(obj.profileId)
      ..writeByte(8)
      ..write(obj.rootFolder)
      ..writeByte(9)
      ..write(obj.languageProfileId)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.isAutoRequest)
      ..writeByte(12)
      ..write(obj.media)
      ..writeByte(13)
      ..write(obj.seasons)
      ..writeByte(14)
      ..write(obj.modifiedBy)
      ..writeByte(15)
      ..write(obj.requestedBy)
      ..writeByte(16)
      ..write(obj.seasonCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrIssueAdapter extends TypeAdapter<OverseerrIssue> {
  @override
  final int typeId = 89;

  @override
  OverseerrIssue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrIssue(
      id: fields[0] as int,
      issueType: fields[1] as int,
      status: fields[2] as int,
      problemSeason: fields[3] as int,
      problemEpisode: fields[4] as int,
      createdAt: fields[5] as String,
      updatedAt: fields[6] as String,
      createdBy: fields[7] as OverseerrCreatedBy,
      media: fields[8] as OverseerrMedia,
      comments: (fields[9] as List?)?.cast<OverseerrComment>(),
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrIssue obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.issueType)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.problemSeason)
      ..writeByte(4)
      ..write(obj.problemEpisode)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.createdBy)
      ..writeByte(8)
      ..write(obj.media)
      ..writeByte(9)
      ..write(obj.comments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrIssueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrMediaAdapter extends TypeAdapter<OverseerrMedia> {
  @override
  final int typeId = 90;

  @override
  OverseerrMedia read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrMedia(
      downloadStatus: (fields[0] as List).cast<OverseerrDownloadStatus>(),
      downloadStatus4k: (fields[1] as List).cast<OverseerrDownloadStatus>(),
      id: fields[2] as int,
      mediaType: fields[3] as String,
      tmdbId: fields[4] as int,
      tvdbId: fields[5] as int?,
      imdbId: fields[6] as String?,
      status: fields[7] as int,
      status4k: fields[8] as int,
      createdAt: fields[9] as String,
      updatedAt: fields[10] as String,
      lastSeasonChange: fields[11] as String,
      mediaAddedAt: fields[12] as String?,
      serviceId: fields[13] as int?,
      serviceId4k: fields[14] as int?,
      externalServiceId: fields[15] as int?,
      externalServiceId4k: fields[16] as int?,
      externalServiceSlug: fields[17] as String?,
      externalServiceSlug4k: fields[18] as String?,
      ratingKey: fields[19] as String?,
      ratingKey4k: fields[20] as String?,
      jellyfinMediaId: fields[21] as String?,
      jellyfinMediaId4k: fields[22] as String?,
      serviceUrl: fields[23] as String?,
      movie: fields[24] as OverseerrMovie?,
      series: fields[25] as OverseerrSeries?,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrMedia obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.downloadStatus)
      ..writeByte(1)
      ..write(obj.downloadStatus4k)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.mediaType)
      ..writeByte(4)
      ..write(obj.tmdbId)
      ..writeByte(5)
      ..write(obj.tvdbId)
      ..writeByte(6)
      ..write(obj.imdbId)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.status4k)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.lastSeasonChange)
      ..writeByte(12)
      ..write(obj.mediaAddedAt)
      ..writeByte(13)
      ..write(obj.serviceId)
      ..writeByte(14)
      ..write(obj.serviceId4k)
      ..writeByte(15)
      ..write(obj.externalServiceId)
      ..writeByte(16)
      ..write(obj.externalServiceId4k)
      ..writeByte(17)
      ..write(obj.externalServiceSlug)
      ..writeByte(18)
      ..write(obj.externalServiceSlug4k)
      ..writeByte(19)
      ..write(obj.ratingKey)
      ..writeByte(20)
      ..write(obj.ratingKey4k)
      ..writeByte(21)
      ..write(obj.jellyfinMediaId)
      ..writeByte(22)
      ..write(obj.jellyfinMediaId4k)
      ..writeByte(23)
      ..write(obj.serviceUrl)
      ..writeByte(24)
      ..write(obj.movie)
      ..writeByte(25)
      ..write(obj.series);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrMediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrMovieAdapter extends TypeAdapter<OverseerrMovie> {
  @override
  final int typeId = 91;

  @override
  OverseerrMovie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrMovie(
      id: fields[0] as int,
      title: fields[1] as String,
      posterPath: fields[2] as String?,
      backdropPath: fields[3] as String?,
      releaseDate: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrMovie obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.backdropPath)
      ..writeByte(4)
      ..write(obj.releaseDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrMovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrSeriesAdapter extends TypeAdapter<OverseerrSeries> {
  @override
  final int typeId = 92;

  @override
  OverseerrSeries read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrSeries(
      id: fields[0] as int,
      name: fields[1] as String,
      posterPath: fields[2] as String?,
      backdropPath: fields[3] as String?,
      firstAirDate: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrSeries obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.posterPath)
      ..writeByte(3)
      ..write(obj.backdropPath)
      ..writeByte(4)
      ..write(obj.firstAirDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrSeriesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrUserAdapter extends TypeAdapter<OverseerrUser> {
  @override
  final int typeId = 93;

  @override
  OverseerrUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrUser(
      id: fields[0] as int,
      email: fields[1] as String,
      plexUsername: fields[2] as String?,
      jellyfinUsername: fields[3] as String?,
      username: fields[4] as String?,
      displayName: fields[5] as String,
      avatar: fields[6] as String,
      requestCount: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrUser obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.plexUsername)
      ..writeByte(3)
      ..write(obj.jellyfinUsername)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.displayName)
      ..writeByte(6)
      ..write(obj.avatar)
      ..writeByte(7)
      ..write(obj.requestCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrCreatedByAdapter extends TypeAdapter<OverseerrCreatedBy> {
  @override
  final int typeId = 94;

  @override
  OverseerrCreatedBy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrCreatedBy(
      id: fields[0] as int,
      displayName: fields[1] as String,
      avatar: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrCreatedBy obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.avatar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrCreatedByAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrSeasonAdapter extends TypeAdapter<OverseerrSeason> {
  @override
  final int typeId = 95;

  @override
  OverseerrSeason read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrSeason(
      id: fields[0] as int,
      seasonNumber: fields[1] as int,
      status: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrSeason obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.seasonNumber)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrSeasonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrCommentAdapter extends TypeAdapter<OverseerrComment> {
  @override
  final int typeId = 96;

  @override
  OverseerrComment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrComment(
      id: fields[0] as int,
      message: fields[1] as String,
      createdAt: fields[2] as String,
      user: fields[3] as OverseerrUser,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrComment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrCommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrDownloadStatusAdapter
    extends TypeAdapter<OverseerrDownloadStatus> {
  @override
  final int typeId = 97;

  @override
  OverseerrDownloadStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrDownloadStatus(
      title: fields[0] as String,
      size: fields[1] as int,
      status: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrDownloadStatus obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.size)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrDownloadStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrServerConfigAdapter extends TypeAdapter<OverseerrServerConfig> {
  @override
  final int typeId = 98;

  @override
  OverseerrServerConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrServerConfig(
      server: fields[0] as OverseerrServer,
      profiles: (fields[1] as List).cast<OverseerrProfile>(),
      rootFolders: (fields[2] as List).cast<OverseerrRootFolder>(),
      tags: (fields[3] as List).cast<OverseerrTag>(),
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrServerConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.server)
      ..writeByte(1)
      ..write(obj.profiles)
      ..writeByte(2)
      ..write(obj.rootFolders)
      ..writeByte(3)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrServerConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrServerAdapter extends TypeAdapter<OverseerrServer> {
  @override
  final int typeId = 99;

  @override
  OverseerrServer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrServer(
      id: fields[0] as int,
      name: fields[1] as String,
      hostname: fields[2] as String,
      port: fields[3] as int,
      isDefault: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrServer obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.hostname)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrServerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrProfileAdapter extends TypeAdapter<OverseerrProfile> {
  @override
  final int typeId = 100;

  @override
  OverseerrProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrProfile(
      id: fields[0] as int,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrProfile obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrRootFolderAdapter extends TypeAdapter<OverseerrRootFolder> {
  @override
  final int typeId = 101;

  @override
  OverseerrRootFolder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrRootFolder(
      id: fields[0] as int,
      path: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrRootFolder obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.path);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrRootFolderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrTagAdapter extends TypeAdapter<OverseerrTag> {
  @override
  final int typeId = 102;

  @override
  OverseerrTag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrTag(
      id: fields[0] as int,
      label: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrTag obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OverseerrApiStatusAdapter extends TypeAdapter<OverseerrApiStatus> {
  @override
  final int typeId = 103;

  @override
  OverseerrApiStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverseerrApiStatus(
      version: fields[0] as String,
      commitTag: fields[1] as String?,
      updateAvailable: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OverseerrApiStatus obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.version)
      ..writeByte(1)
      ..write(obj.commitTag)
      ..writeByte(2)
      ..write(obj.updateAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverseerrApiStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OverseerrResponse<T> _$OverseerrResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    OverseerrResponse<T>(
      pageInfo:
          OverseerrPageInfo.fromJson(json['pageInfo'] as Map<String, dynamic>),
      results: (json['results'] as List<dynamic>).map(fromJsonT).toList(),
    );

Map<String, dynamic> _$OverseerrResponseToJson<T>(
  OverseerrResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'pageInfo': instance.pageInfo.toJson(),
      'results': instance.results.map(toJsonT).toList(),
    };

OverseerrPageInfo _$OverseerrPageInfoFromJson(Map<String, dynamic> json) =>
    OverseerrPageInfo(
      pages: (json['pages'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      results: (json['results'] as num).toInt(),
      page: (json['page'] as num).toInt(),
    );

Map<String, dynamic> _$OverseerrPageInfoToJson(OverseerrPageInfo instance) =>
    <String, dynamic>{
      'pages': instance.pages,
      'pageSize': instance.pageSize,
      'results': instance.results,
      'page': instance.page,
    };

OverseerrRequest _$OverseerrRequestFromJson(Map<String, dynamic> json) =>
    OverseerrRequest(
      id: (json['id'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      type: json['type'] as String,
      is4k: json['is4k'] as bool,
      serverId: (json['serverId'] as num?)?.toInt(),
      profileId: (json['profileId'] as num?)?.toInt(),
      rootFolder: json['rootFolder'] as String?,
      languageProfileId: (json['languageProfileId'] as num?)?.toInt(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      isAutoRequest: json['isAutoRequest'] as bool,
      media: OverseerrMedia.fromJson(json['media'] as Map<String, dynamic>),
      seasons: (json['seasons'] as List<dynamic>)
          .map((e) => OverseerrSeason.fromJson(e as Map<String, dynamic>))
          .toList(),
      modifiedBy: json['modifiedBy'] == null
          ? null
          : OverseerrUser.fromJson(json['modifiedBy'] as Map<String, dynamic>),
      requestedBy:
          OverseerrUser.fromJson(json['requestedBy'] as Map<String, dynamic>),
      seasonCount: (json['seasonCount'] as num).toInt(),
    );

Map<String, dynamic> _$OverseerrRequestToJson(OverseerrRequest instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'status': instance.status,
    'createdAt': instance.createdAt,
    'updatedAt': instance.updatedAt,
    'type': instance.type,
    'is4k': instance.is4k,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('serverId', instance.serverId);
  writeNotNull('profileId', instance.profileId);
  writeNotNull('rootFolder', instance.rootFolder);
  writeNotNull('languageProfileId', instance.languageProfileId);
  writeNotNull('tags', instance.tags);
  val['isAutoRequest'] = instance.isAutoRequest;
  val['media'] = instance.media.toJson();
  val['seasons'] = instance.seasons.map((e) => e.toJson()).toList();
  writeNotNull('modifiedBy', instance.modifiedBy?.toJson());
  val['requestedBy'] = instance.requestedBy.toJson();
  val['seasonCount'] = instance.seasonCount;
  return val;
}

OverseerrIssue _$OverseerrIssueFromJson(Map<String, dynamic> json) =>
    OverseerrIssue(
      id: (json['id'] as num).toInt(),
      issueType: (json['issueType'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      problemSeason: (json['problemSeason'] as num).toInt(),
      problemEpisode: (json['problemEpisode'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      createdBy: OverseerrCreatedBy.fromJson(
          json['createdBy'] as Map<String, dynamic>),
      media: OverseerrMedia.fromJson(json['media'] as Map<String, dynamic>),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => OverseerrComment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OverseerrIssueToJson(OverseerrIssue instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'issueType': instance.issueType,
    'status': instance.status,
    'problemSeason': instance.problemSeason,
    'problemEpisode': instance.problemEpisode,
    'createdAt': instance.createdAt,
    'updatedAt': instance.updatedAt,
    'createdBy': instance.createdBy.toJson(),
    'media': instance.media.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('comments', instance.comments?.map((e) => e.toJson()).toList());
  return val;
}

OverseerrMedia _$OverseerrMediaFromJson(Map<String, dynamic> json) =>
    OverseerrMedia(
      downloadStatus: (json['downloadStatus'] as List<dynamic>)
          .map((e) =>
              OverseerrDownloadStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
      downloadStatus4k: (json['downloadStatus4k'] as List<dynamic>)
          .map((e) =>
              OverseerrDownloadStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: (json['id'] as num).toInt(),
      mediaType: json['mediaType'] as String,
      tmdbId: (json['tmdbId'] as num).toInt(),
      tvdbId: (json['tvdbId'] as num?)?.toInt(),
      imdbId: json['imdbId'] as String?,
      status: (json['status'] as num).toInt(),
      status4k: (json['status4k'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      lastSeasonChange: json['lastSeasonChange'] as String,
      mediaAddedAt: json['mediaAddedAt'] as String?,
      serviceId: (json['serviceId'] as num?)?.toInt(),
      serviceId4k: (json['serviceId4k'] as num?)?.toInt(),
      externalServiceId: (json['externalServiceId'] as num?)?.toInt(),
      externalServiceId4k: (json['externalServiceId4k'] as num?)?.toInt(),
      externalServiceSlug: json['externalServiceSlug'] as String?,
      externalServiceSlug4k: json['externalServiceSlug4k'] as String?,
      ratingKey: json['ratingKey'] as String?,
      ratingKey4k: json['ratingKey4k'] as String?,
      jellyfinMediaId: json['jellyfinMediaId'] as String?,
      jellyfinMediaId4k: json['jellyfinMediaId4k'] as String?,
      serviceUrl: json['serviceUrl'] as String?,
      movie: json['movie'] == null
          ? null
          : OverseerrMovie.fromJson(json['movie'] as Map<String, dynamic>),
      series: json['series'] == null
          ? null
          : OverseerrSeries.fromJson(json['series'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OverseerrMediaToJson(OverseerrMedia instance) {
  final val = <String, dynamic>{
    'downloadStatus': instance.downloadStatus.map((e) => e.toJson()).toList(),
    'downloadStatus4k':
        instance.downloadStatus4k.map((e) => e.toJson()).toList(),
    'id': instance.id,
    'mediaType': instance.mediaType,
    'tmdbId': instance.tmdbId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('tvdbId', instance.tvdbId);
  writeNotNull('imdbId', instance.imdbId);
  val['status'] = instance.status;
  val['status4k'] = instance.status4k;
  val['createdAt'] = instance.createdAt;
  val['updatedAt'] = instance.updatedAt;
  val['lastSeasonChange'] = instance.lastSeasonChange;
  writeNotNull('mediaAddedAt', instance.mediaAddedAt);
  writeNotNull('serviceId', instance.serviceId);
  writeNotNull('serviceId4k', instance.serviceId4k);
  writeNotNull('externalServiceId', instance.externalServiceId);
  writeNotNull('externalServiceId4k', instance.externalServiceId4k);
  writeNotNull('externalServiceSlug', instance.externalServiceSlug);
  writeNotNull('externalServiceSlug4k', instance.externalServiceSlug4k);
  writeNotNull('ratingKey', instance.ratingKey);
  writeNotNull('ratingKey4k', instance.ratingKey4k);
  writeNotNull('jellyfinMediaId', instance.jellyfinMediaId);
  writeNotNull('jellyfinMediaId4k', instance.jellyfinMediaId4k);
  writeNotNull('serviceUrl', instance.serviceUrl);
  writeNotNull('movie', instance.movie?.toJson());
  writeNotNull('series', instance.series?.toJson());
  return val;
}

OverseerrMovie _$OverseerrMovieFromJson(Map<String, dynamic> json) =>
    OverseerrMovie(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      releaseDate: json['releaseDate'] as String?,
    );

Map<String, dynamic> _$OverseerrMovieToJson(OverseerrMovie instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'title': instance.title,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('posterPath', instance.posterPath);
  writeNotNull('backdropPath', instance.backdropPath);
  writeNotNull('releaseDate', instance.releaseDate);
  return val;
}

OverseerrSeries _$OverseerrSeriesFromJson(Map<String, dynamic> json) =>
    OverseerrSeries(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      firstAirDate: json['firstAirDate'] as String?,
    );

Map<String, dynamic> _$OverseerrSeriesToJson(OverseerrSeries instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('posterPath', instance.posterPath);
  writeNotNull('backdropPath', instance.backdropPath);
  writeNotNull('firstAirDate', instance.firstAirDate);
  return val;
}

OverseerrUser _$OverseerrUserFromJson(Map<String, dynamic> json) =>
    OverseerrUser(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      plexUsername: json['plexUsername'] as String?,
      jellyfinUsername: json['jellyfinUsername'] as String?,
      username: json['username'] as String?,
      displayName: json['displayName'] as String,
      avatar: json['avatar'] as String,
      requestCount: (json['requestCount'] as num).toInt(),
    );

Map<String, dynamic> _$OverseerrUserToJson(OverseerrUser instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'email': instance.email,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('plexUsername', instance.plexUsername);
  writeNotNull('jellyfinUsername', instance.jellyfinUsername);
  writeNotNull('username', instance.username);
  val['displayName'] = instance.displayName;
  val['avatar'] = instance.avatar;
  val['requestCount'] = instance.requestCount;
  return val;
}

OverseerrCreatedBy _$OverseerrCreatedByFromJson(Map<String, dynamic> json) =>
    OverseerrCreatedBy(
      id: (json['id'] as num).toInt(),
      displayName: json['displayName'] as String,
      avatar: json['avatar'] as String,
    );

Map<String, dynamic> _$OverseerrCreatedByToJson(OverseerrCreatedBy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'avatar': instance.avatar,
    };

OverseerrSeason _$OverseerrSeasonFromJson(Map<String, dynamic> json) =>
    OverseerrSeason(
      id: (json['id'] as num).toInt(),
      seasonNumber: (json['seasonNumber'] as num).toInt(),
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$OverseerrSeasonToJson(OverseerrSeason instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seasonNumber': instance.seasonNumber,
      'status': instance.status,
    };

OverseerrComment _$OverseerrCommentFromJson(Map<String, dynamic> json) =>
    OverseerrComment(
      id: (json['id'] as num).toInt(),
      message: json['message'] as String,
      createdAt: json['createdAt'] as String,
      user: OverseerrUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OverseerrCommentToJson(OverseerrComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'createdAt': instance.createdAt,
      'user': instance.user.toJson(),
    };

OverseerrDownloadStatus _$OverseerrDownloadStatusFromJson(
        Map<String, dynamic> json) =>
    OverseerrDownloadStatus(
      title: json['title'] as String,
      size: (json['size'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$OverseerrDownloadStatusToJson(
        OverseerrDownloadStatus instance) =>
    <String, dynamic>{
      'title': instance.title,
      'size': instance.size,
      'status': instance.status,
    };

OverseerrServerConfig _$OverseerrServerConfigFromJson(
        Map<String, dynamic> json) =>
    OverseerrServerConfig(
      server: OverseerrServer.fromJson(json['server'] as Map<String, dynamic>),
      profiles: (json['profiles'] as List<dynamic>)
          .map((e) => OverseerrProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      rootFolders: (json['rootFolders'] as List<dynamic>)
          .map((e) => OverseerrRootFolder.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => OverseerrTag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OverseerrServerConfigToJson(
        OverseerrServerConfig instance) =>
    <String, dynamic>{
      'server': instance.server.toJson(),
      'profiles': instance.profiles.map((e) => e.toJson()).toList(),
      'rootFolders': instance.rootFolders.map((e) => e.toJson()).toList(),
      'tags': instance.tags.map((e) => e.toJson()).toList(),
    };

OverseerrServer _$OverseerrServerFromJson(Map<String, dynamic> json) =>
    OverseerrServer(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      hostname: json['hostname'] as String,
      port: (json['port'] as num).toInt(),
      isDefault: json['isDefault'] as bool,
    );

Map<String, dynamic> _$OverseerrServerToJson(OverseerrServer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hostname': instance.hostname,
      'port': instance.port,
      'isDefault': instance.isDefault,
    };

OverseerrProfile _$OverseerrProfileFromJson(Map<String, dynamic> json) =>
    OverseerrProfile(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$OverseerrProfileToJson(OverseerrProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

OverseerrRootFolder _$OverseerrRootFolderFromJson(Map<String, dynamic> json) =>
    OverseerrRootFolder(
      id: (json['id'] as num).toInt(),
      path: json['path'] as String,
    );

Map<String, dynamic> _$OverseerrRootFolderToJson(
        OverseerrRootFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
    };

OverseerrTag _$OverseerrTagFromJson(Map<String, dynamic> json) => OverseerrTag(
      id: (json['id'] as num).toInt(),
      label: json['label'] as String,
    );

Map<String, dynamic> _$OverseerrTagToJson(OverseerrTag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
    };

OverseerrApiStatus _$OverseerrApiStatusFromJson(Map<String, dynamic> json) =>
    OverseerrApiStatus(
      version: json['version'] as String,
      commitTag: json['commitTag'] as String?,
      updateAvailable: json['updateAvailable'] as bool,
    );

Map<String, dynamic> _$OverseerrApiStatusToJson(OverseerrApiStatus instance) {
  final val = <String, dynamic>{
    'version': instance.version,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('commitTag', instance.commitTag);
  val['updateAvailable'] = instance.updateAvailable;
  return val;
}

OverseerrMediaRequest _$OverseerrMediaRequestFromJson(
        Map<String, dynamic> json) =>
    OverseerrMediaRequest(
      serverId: (json['serverId'] as num?)?.toInt(),
      profileId: (json['profileId'] as num?)?.toInt(),
      rootFolder: json['rootFolder'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$OverseerrMediaRequestToJson(
    OverseerrMediaRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('serverId', instance.serverId);
  writeNotNull('profileId', instance.profileId);
  writeNotNull('rootFolder', instance.rootFolder);
  writeNotNull('tags', instance.tags);
  return val;
}

OverseerrMessage _$OverseerrMessageFromJson(Map<String, dynamic> json) =>
    OverseerrMessage(
      message: json['message'] as String,
    );

Map<String, dynamic> _$OverseerrMessageToJson(OverseerrMessage instance) =>
    <String, dynamic>{
      'message': instance.message,
    };
