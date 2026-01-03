// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeerrPageInfoAdapter extends TypeAdapter<SeerrPageInfo> {
  @override
  final int typeId = 87;

  @override
  SeerrPageInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrPageInfo(
      pages: fields[0] as int,
      pageSize: fields[1] as int,
      results: fields[2] as int,
      page: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrPageInfo obj) {
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
      other is SeerrPageInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrRequestAdapter extends TypeAdapter<SeerrRequest> {
  @override
  final int typeId = 88;

  @override
  SeerrRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrRequest(
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
      media: fields[12] as SeerrMedia,
      seasons: (fields[13] as List).cast<SeerrSeason>(),
      modifiedBy: fields[14] as SeerrUser?,
      requestedBy: fields[15] as SeerrUser,
      seasonCount: fields[16] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrRequest obj) {
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
      other is SeerrRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrIssueAdapter extends TypeAdapter<SeerrIssue> {
  @override
  final int typeId = 89;

  @override
  SeerrIssue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrIssue(
      id: fields[0] as int,
      issueType: fields[1] as int,
      status: fields[2] as int,
      problemSeason: fields[3] as int,
      problemEpisode: fields[4] as int,
      createdAt: fields[5] as String,
      updatedAt: fields[6] as String,
      createdBy: fields[7] as SeerrCreatedBy,
      media: fields[8] as SeerrMedia,
      comments: (fields[9] as List?)?.cast<SeerrComment>(),
    );
  }

  @override
  void write(BinaryWriter writer, SeerrIssue obj) {
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
      other is SeerrIssueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrMediaAdapter extends TypeAdapter<SeerrMedia> {
  @override
  final int typeId = 90;

  @override
  SeerrMedia read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrMedia(
      downloadStatus: (fields[0] as List).cast<SeerrDownloadStatus>(),
      downloadStatus4k: (fields[1] as List).cast<SeerrDownloadStatus>(),
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
      movie: fields[24] as SeerrMovie?,
      series: fields[25] as SeerrSeries?,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrMedia obj) {
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
      other is SeerrMediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrMovieAdapter extends TypeAdapter<SeerrMovie> {
  @override
  final int typeId = 91;

  @override
  SeerrMovie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrMovie(
      id: fields[0] as int,
      title: fields[1] as String,
      posterPath: fields[2] as String?,
      backdropPath: fields[3] as String?,
      releaseDate: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrMovie obj) {
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
      other is SeerrMovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrSeriesAdapter extends TypeAdapter<SeerrSeries> {
  @override
  final int typeId = 92;

  @override
  SeerrSeries read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrSeries(
      id: fields[0] as int,
      name: fields[1] as String,
      posterPath: fields[2] as String?,
      backdropPath: fields[3] as String?,
      firstAirDate: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrSeries obj) {
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
      other is SeerrSeriesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrUserAdapter extends TypeAdapter<SeerrUser> {
  @override
  final int typeId = 93;

  @override
  SeerrUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrUser(
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
  void write(BinaryWriter writer, SeerrUser obj) {
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
      other is SeerrUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrCreatedByAdapter extends TypeAdapter<SeerrCreatedBy> {
  @override
  final int typeId = 94;

  @override
  SeerrCreatedBy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrCreatedBy(
      id: fields[0] as int,
      displayName: fields[1] as String,
      avatar: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrCreatedBy obj) {
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
      other is SeerrCreatedByAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrSeasonAdapter extends TypeAdapter<SeerrSeason> {
  @override
  final int typeId = 95;

  @override
  SeerrSeason read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrSeason(
      id: fields[0] as int,
      seasonNumber: fields[1] as int,
      status: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrSeason obj) {
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
      other is SeerrSeasonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrCommentAdapter extends TypeAdapter<SeerrComment> {
  @override
  final int typeId = 96;

  @override
  SeerrComment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrComment(
      id: fields[0] as int,
      message: fields[1] as String,
      createdAt: fields[2] as String,
      user: fields[3] as SeerrUser,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrComment obj) {
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
      other is SeerrCommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrDownloadStatusAdapter
    extends TypeAdapter<SeerrDownloadStatus> {
  @override
  final int typeId = 97;

  @override
  SeerrDownloadStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrDownloadStatus(
      title: fields[0] as String,
      size: fields[1] as int,
      status: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrDownloadStatus obj) {
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
      other is SeerrDownloadStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrServerConfigAdapter extends TypeAdapter<SeerrServerConfig> {
  @override
  final int typeId = 98;

  @override
  SeerrServerConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrServerConfig(
      server: fields[0] as SeerrServer,
      profiles: (fields[1] as List).cast<SeerrProfile>(),
      rootFolders: (fields[2] as List).cast<SeerrRootFolder>(),
      tags: (fields[3] as List).cast<SeerrTag>(),
    );
  }

  @override
  void write(BinaryWriter writer, SeerrServerConfig obj) {
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
      other is SeerrServerConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrServerAdapter extends TypeAdapter<SeerrServer> {
  @override
  final int typeId = 99;

  @override
  SeerrServer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrServer(
      id: fields[0] as int,
      name: fields[1] as String,
      hostname: fields[2] as String,
      port: fields[3] as int,
      isDefault: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrServer obj) {
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
      other is SeerrServerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrProfileAdapter extends TypeAdapter<SeerrProfile> {
  @override
  final int typeId = 100;

  @override
  SeerrProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrProfile(
      id: fields[0] as int,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrProfile obj) {
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
      other is SeerrProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrRootFolderAdapter extends TypeAdapter<SeerrRootFolder> {
  @override
  final int typeId = 101;

  @override
  SeerrRootFolder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrRootFolder(
      id: fields[0] as int,
      path: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrRootFolder obj) {
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
      other is SeerrRootFolderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrTagAdapter extends TypeAdapter<SeerrTag> {
  @override
  final int typeId = 102;

  @override
  SeerrTag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrTag(
      id: fields[0] as int,
      label: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrTag obj) {
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
      other is SeerrTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SeerrApiStatusAdapter extends TypeAdapter<SeerrApiStatus> {
  @override
  final int typeId = 103;

  @override
  SeerrApiStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeerrApiStatus(
      version: fields[0] as String,
      commitTag: fields[1] as String?,
      updateAvailable: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SeerrApiStatus obj) {
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
      other is SeerrApiStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeerrResponse<T> _$SeerrResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    SeerrResponse<T>(
      pageInfo:
          SeerrPageInfo.fromJson(json['pageInfo'] as Map<String, dynamic>),
      results: (json['results'] as List<dynamic>).map(fromJsonT).toList(),
    );

Map<String, dynamic> _$SeerrResponseToJson<T>(
  SeerrResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'pageInfo': instance.pageInfo.toJson(),
      'results': instance.results.map(toJsonT).toList(),
    };

SeerrPageInfo _$SeerrPageInfoFromJson(Map<String, dynamic> json) =>
    SeerrPageInfo(
      pages: (json['pages'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      results: (json['results'] as num).toInt(),
      page: (json['page'] as num).toInt(),
    );

Map<String, dynamic> _$SeerrPageInfoToJson(SeerrPageInfo instance) =>
    <String, dynamic>{
      'pages': instance.pages,
      'pageSize': instance.pageSize,
      'results': instance.results,
      'page': instance.page,
    };

SeerrRequest _$SeerrRequestFromJson(Map<String, dynamic> json) =>
    SeerrRequest(
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
      media: SeerrMedia.fromJson(json['media'] as Map<String, dynamic>),
      seasons: (json['seasons'] as List<dynamic>)
          .map((e) => SeerrSeason.fromJson(e as Map<String, dynamic>))
          .toList(),
      modifiedBy: json['modifiedBy'] == null
          ? null
          : SeerrUser.fromJson(json['modifiedBy'] as Map<String, dynamic>),
      requestedBy:
          SeerrUser.fromJson(json['requestedBy'] as Map<String, dynamic>),
      seasonCount: (json['seasonCount'] as num).toInt(),
    );

Map<String, dynamic> _$SeerrRequestToJson(SeerrRequest instance) {
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

SeerrIssue _$SeerrIssueFromJson(Map<String, dynamic> json) =>
    SeerrIssue(
      id: (json['id'] as num).toInt(),
      issueType: (json['issueType'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      problemSeason: (json['problemSeason'] as num).toInt(),
      problemEpisode: (json['problemEpisode'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      createdBy: SeerrCreatedBy.fromJson(
          json['createdBy'] as Map<String, dynamic>),
      media: SeerrMedia.fromJson(json['media'] as Map<String, dynamic>),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => SeerrComment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SeerrIssueToJson(SeerrIssue instance) {
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

SeerrMedia _$SeerrMediaFromJson(Map<String, dynamic> json) =>
    SeerrMedia(
      downloadStatus: (json['downloadStatus'] as List<dynamic>)
          .map((e) =>
              SeerrDownloadStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
      downloadStatus4k: (json['downloadStatus4k'] as List<dynamic>)
          .map((e) =>
              SeerrDownloadStatus.fromJson(e as Map<String, dynamic>))
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
          : SeerrMovie.fromJson(json['movie'] as Map<String, dynamic>),
      series: json['series'] == null
          ? null
          : SeerrSeries.fromJson(json['series'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SeerrMediaToJson(SeerrMedia instance) {
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

SeerrMovie _$SeerrMovieFromJson(Map<String, dynamic> json) =>
    SeerrMovie(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      releaseDate: json['releaseDate'] as String?,
    );

Map<String, dynamic> _$SeerrMovieToJson(SeerrMovie instance) {
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

SeerrSeries _$SeerrSeriesFromJson(Map<String, dynamic> json) =>
    SeerrSeries(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      firstAirDate: json['firstAirDate'] as String?,
    );

Map<String, dynamic> _$SeerrSeriesToJson(SeerrSeries instance) {
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

SeerrUser _$SeerrUserFromJson(Map<String, dynamic> json) =>
    SeerrUser(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      plexUsername: json['plexUsername'] as String?,
      jellyfinUsername: json['jellyfinUsername'] as String?,
      username: json['username'] as String?,
      displayName: json['displayName'] as String,
      avatar: json['avatar'] as String,
      requestCount: (json['requestCount'] as num).toInt(),
    );

Map<String, dynamic> _$SeerrUserToJson(SeerrUser instance) {
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

SeerrCreatedBy _$SeerrCreatedByFromJson(Map<String, dynamic> json) =>
    SeerrCreatedBy(
      id: (json['id'] as num).toInt(),
      displayName: json['displayName'] as String,
      avatar: json['avatar'] as String,
    );

Map<String, dynamic> _$SeerrCreatedByToJson(SeerrCreatedBy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'avatar': instance.avatar,
    };

SeerrSeason _$SeerrSeasonFromJson(Map<String, dynamic> json) =>
    SeerrSeason(
      id: (json['id'] as num).toInt(),
      seasonNumber: (json['seasonNumber'] as num).toInt(),
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$SeerrSeasonToJson(SeerrSeason instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seasonNumber': instance.seasonNumber,
      'status': instance.status,
    };

SeerrComment _$SeerrCommentFromJson(Map<String, dynamic> json) =>
    SeerrComment(
      id: (json['id'] as num).toInt(),
      message: json['message'] as String,
      createdAt: json['createdAt'] as String,
      user: SeerrUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SeerrCommentToJson(SeerrComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'createdAt': instance.createdAt,
      'user': instance.user.toJson(),
    };

SeerrDownloadStatus _$SeerrDownloadStatusFromJson(
        Map<String, dynamic> json) =>
    SeerrDownloadStatus(
      title: json['title'] as String,
      size: (json['size'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$SeerrDownloadStatusToJson(
        SeerrDownloadStatus instance) =>
    <String, dynamic>{
      'title': instance.title,
      'size': instance.size,
      'status': instance.status,
    };

SeerrServerConfig _$SeerrServerConfigFromJson(
        Map<String, dynamic> json) =>
    SeerrServerConfig(
      server: SeerrServer.fromJson(json['server'] as Map<String, dynamic>),
      profiles: (json['profiles'] as List<dynamic>)
          .map((e) => SeerrProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      rootFolders: (json['rootFolders'] as List<dynamic>)
          .map((e) => SeerrRootFolder.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => SeerrTag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SeerrServerConfigToJson(
        SeerrServerConfig instance) =>
    <String, dynamic>{
      'server': instance.server.toJson(),
      'profiles': instance.profiles.map((e) => e.toJson()).toList(),
      'rootFolders': instance.rootFolders.map((e) => e.toJson()).toList(),
      'tags': instance.tags.map((e) => e.toJson()).toList(),
    };

SeerrServer _$SeerrServerFromJson(Map<String, dynamic> json) =>
    SeerrServer(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      hostname: json['hostname'] as String,
      port: (json['port'] as num).toInt(),
      isDefault: json['isDefault'] as bool,
    );

Map<String, dynamic> _$SeerrServerToJson(SeerrServer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hostname': instance.hostname,
      'port': instance.port,
      'isDefault': instance.isDefault,
    };

SeerrProfile _$SeerrProfileFromJson(Map<String, dynamic> json) =>
    SeerrProfile(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$SeerrProfileToJson(SeerrProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

SeerrRootFolder _$SeerrRootFolderFromJson(Map<String, dynamic> json) =>
    SeerrRootFolder(
      id: (json['id'] as num).toInt(),
      path: json['path'] as String,
    );

Map<String, dynamic> _$SeerrRootFolderToJson(
        SeerrRootFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
    };

SeerrTag _$SeerrTagFromJson(Map<String, dynamic> json) => SeerrTag(
      id: (json['id'] as num).toInt(),
      label: json['label'] as String,
    );

Map<String, dynamic> _$SeerrTagToJson(SeerrTag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
    };

SeerrApiStatus _$SeerrApiStatusFromJson(Map<String, dynamic> json) =>
    SeerrApiStatus(
      version: json['version'] as String,
      commitTag: json['commitTag'] as String?,
      updateAvailable: json['updateAvailable'] as bool,
    );

Map<String, dynamic> _$SeerrApiStatusToJson(SeerrApiStatus instance) {
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

SeerrMediaRequest _$SeerrMediaRequestFromJson(
        Map<String, dynamic> json) =>
    SeerrMediaRequest(
      serverId: (json['serverId'] as num?)?.toInt(),
      profileId: (json['profileId'] as num?)?.toInt(),
      rootFolder: json['rootFolder'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$SeerrMediaRequestToJson(
    SeerrMediaRequest instance) {
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

SeerrMessage _$SeerrMessageFromJson(Map<String, dynamic> json) =>
    SeerrMessage(
      message: json['message'] as String,
    );

Map<String, dynamic> _$SeerrMessageToJson(SeerrMessage instance) =>
    <String, dynamic>{
      'message': instance.message,
    };
