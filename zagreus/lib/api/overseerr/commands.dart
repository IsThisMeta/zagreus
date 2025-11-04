/// Library containing all logic and accessors to make calls to Overseerr's API.
library overseerr_commands;

import 'package:dio/dio.dart';
import 'package:zagreus/api/overseerr/models.dart';
import 'package:zagreus/api/overseerr/overseerr.dart';

/// Base command handler for Overseerr API calls
abstract class OverseerrCommand {
  final OverseerrAPI api;
  final Dio client;

  OverseerrCommand({
    required this.api,
    required this.client,
  });
}

/// Get all requests from Overseerr
class GetOverseerrRequests extends OverseerrCommand {
  GetOverseerrRequests(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<OverseerrResponse<OverseerrRequest>> call({
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
class UpdateOverseerrRequest extends OverseerrCommand {
  UpdateOverseerrRequest(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<dynamic> call({
    required int requestId,
    required String status, // 'approve' or 'decline'
  }) async {
    return await api.updateRequest(requestId, status);
  }
}

/// Update request with configuration edits
class UpdateOverseerrRequestWithEdits extends OverseerrCommand {
  UpdateOverseerrRequestWithEdits(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<dynamic> call({
    required int requestId,
    required OverseerrMediaRequest mediaRequest,
  }) async {
    return await api.updateRequestWithEdits(requestId, mediaRequest);
  }
}

/// Delete a request
class DeleteOverseerrRequest extends OverseerrCommand {
  DeleteOverseerrRequest(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<dynamic> call({
    required int requestId,
  }) async {
    return await api.deleteRequest(requestId);
  }
}

/// Get all issues from Overseerr
class GetOverseerrIssues extends OverseerrCommand {
  GetOverseerrIssues(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<OverseerrResponse<OverseerrIssue>> call({
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
class GetOverseerrIssueById extends OverseerrCommand {
  GetOverseerrIssueById(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<OverseerrIssue> call({
    required int issueId,
  }) async {
    return await api.getIssueById(issueId);
  }
}

/// Update issue status (open/resolved)
class UpdateOverseerrIssue extends OverseerrCommand {
  UpdateOverseerrIssue(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<dynamic> call({
    required int issueId,
    required String status, // 'open' or 'resolved'
  }) async {
    return await api.updateIssue(issueId, status);
  }
}

/// Post comment to issue
class PostOverseerrComment extends OverseerrCommand {
  PostOverseerrComment(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<OverseerrIssue> call({
    required int issueId,
    required String comment,
  }) async {
    return await api.postComment(
      issueId,
      OverseerrMessage(message: comment),
    );
  }
}

/// Get movie details from Overseerr
class GetOverseerrMovie extends OverseerrCommand {
  GetOverseerrMovie(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<OverseerrMovie> call({
    required int movieId,
  }) async {
    return await api.getMovie(movieId);
  }
}

/// Get series details from Overseerr
class GetOverseerrSeries extends OverseerrCommand {
  GetOverseerrSeries(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<OverseerrSeries> call({
    required int seriesId,
  }) async {
    return await api.getSeries(seriesId);
  }
}

/// Get Radarr server configuration
class GetRadarrServerConfig extends OverseerrCommand {
  GetRadarrServerConfig(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<OverseerrServerConfig> call({
    required int serverId,
  }) async {
    return await api.getRadarrServerConfig(serverId);
  }
}

/// Get Sonarr server configuration
class GetSonarrServerConfig extends OverseerrCommand {
  GetSonarrServerConfig(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<OverseerrServerConfig> call({
    required int serverId,
  }) async {
    return await api.getSonarrServerConfig(serverId);
  }
}

/// Get all users
class GetOverseerrUsers extends OverseerrCommand {
  GetOverseerrUsers(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<OverseerrResponse<OverseerrUser>> call({
    int take = 1000,
    String sort = 'displayname',
  }) async {
    return await api.getUsers(
      take: take,
      sort: sort,
    );
  }
}

/// Get Overseerr status
class GetOverseerrStatus extends OverseerrCommand {
  GetOverseerrStatus(OverseerrAPI api, Dio client)
      : super(api: api, client: client);

  Future<OverseerrApiStatus> call() async {
    return await api.getStatus();
  }
}
