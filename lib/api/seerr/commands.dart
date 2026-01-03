/// Library containing all logic and accessors to make calls to Seerr's API.
library seerr_commands;

import 'package:dio/dio.dart';
import 'package:zagreus/api/seerr/models.dart';
import 'package:zagreus/api/seerr/seerr.dart';

/// Base command handler for Seerr API calls
abstract class SeerrCommand {
  final SeerrAPI api;
  final Dio client;

  SeerrCommand({
    required this.api,
    required this.client,
  });
}

/// Get all requests from Seerr
class GetSeerrRequests extends SeerrCommand {
  GetSeerrRequests(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<SeerrResponse<SeerrRequest>> call({
    int take = 1000,
    String filter = 'pending',
    String sort = 'added',
  }) async {
    return await api.getRequests(
      take: take,
      filter: filter,
      sort: sort,
    );
  }
}

/// Update request status (approve/decline)
class UpdateSeerrRequest extends SeerrCommand {
  UpdateSeerrRequest(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<dynamic> call({
    required int requestId,
    required String status, // 'approve' or 'decline'
  }) async {
    return await api.updateRequest(requestId, status);
  }
}

/// Update request with configuration edits
class UpdateSeerrRequestWithEdits extends SeerrCommand {
  UpdateSeerrRequestWithEdits(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<dynamic> call({
    required int requestId,
    required SeerrMediaRequest mediaRequest,
  }) async {
    return await api.updateRequestWithEdits(requestId, mediaRequest);
  }
}

/// Delete a request
class DeleteSeerrRequest extends SeerrCommand {
  DeleteSeerrRequest(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<dynamic> call({
    required int requestId,
  }) async {
    return await api.deleteRequest(requestId);
  }
}

/// Get all issues from Seerr
class GetSeerrIssues extends SeerrCommand {
  GetSeerrIssues(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<SeerrResponse<SeerrIssue>> call({
    int take = 1000,
    String filter = 'open',
    String sort = 'added',
  }) async {
    return await api.getIssues(
      take: take,
      filter: filter,
      sort: sort,
    );
  }
}

/// Get issue by ID
class GetSeerrIssueById extends SeerrCommand {
  GetSeerrIssueById(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<SeerrIssue> call({
    required int issueId,
  }) async {
    return await api.getIssueById(issueId);
  }
}

/// Update issue status (open/resolved)
class UpdateSeerrIssue extends SeerrCommand {
  UpdateSeerrIssue(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<dynamic> call({
    required int issueId,
    required String status, // 'open' or 'resolved'
  }) async {
    return await api.updateIssue(issueId, status);
  }
}

/// Post comment to issue
class PostSeerrComment extends SeerrCommand {
  PostSeerrComment(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<SeerrIssue> call({
    required int issueId,
    required String comment,
  }) async {
    return await api.postComment(
      issueId,
      SeerrMessage(message: comment),
    );
  }
}

/// Get movie details from Seerr
class GetSeerrMovie extends SeerrCommand {
  GetSeerrMovie(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<SeerrMovie> call({
    required int movieId,
  }) async {
    return await api.getMovie(movieId);
  }
}

/// Get series details from Seerr
class GetSeerrSeries extends SeerrCommand {
  GetSeerrSeries(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<SeerrSeries> call({
    required int seriesId,
  }) async {
    return await api.getSeries(seriesId);
  }
}

/// Get Radarr server configuration
class GetRadarrServerConfig extends SeerrCommand {
  GetRadarrServerConfig(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<SeerrServerConfig> call({
    required int serverId,
  }) async {
    return await api.getRadarrServerConfig(serverId);
  }
}

/// Get Sonarr server configuration
class GetSonarrServerConfig extends SeerrCommand {
  GetSonarrServerConfig(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<SeerrServerConfig> call({
    required int serverId,
  }) async {
    return await api.getSonarrServerConfig(serverId);
  }
}

/// Get all users
class GetSeerrUsers extends SeerrCommand {
  GetSeerrUsers(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<SeerrResponse<SeerrUser>> call({
    int take = 1000,
    String sort = 'displayname',
  }) async {
    return await api.getUsers(
      take: take,
      sort: sort,
    );
  }
}

/// Get Seerr status
class GetSeerrStatus extends SeerrCommand {
  GetSeerrStatus(SeerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<SeerrApiStatus> call() async {
    return await api.getStatus();
  }
}
