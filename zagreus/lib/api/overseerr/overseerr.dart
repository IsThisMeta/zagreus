import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:zagreus/api/overseerr/models.dart';
import 'package:zagreus/vendor.dart';

part 'overseerr.g.dart';

@RestApi(baseUrl: '')
abstract class OverseerrAPI {
  factory OverseerrAPI(Dio dio, {String baseUrl}) = _OverseerrAPI;

  // Requests
  @GET('/api/v1/request')
  Future<OverseerrResponse<OverseerrRequest>> getRequests({
    @Query('take') int take = 1000,
    @Query('filter') String filter = 'pending',
    @Query('sort') String sort = 'added',
  });

  @POST('/api/v1/request/{requestId}/{status}')
  Future<dynamic> updateRequest(
    @Path('requestId') int requestId,
    @Path('status') String status,
  );

  @PUT('/api/v1/request/{requestId}')
  Future<dynamic> updateRequestWithEdits(
    @Path('requestId') int requestId,
    @Body() OverseerrMediaRequest mediaRequest,
  );

  @DELETE('/api/v1/request/{requestId}')
  Future<dynamic> deleteRequest(
    @Path('requestId') int requestId,
  );

  // Issues
  @GET('/api/v1/issue')
  Future<OverseerrResponse<OverseerrIssue>> getIssues({
    @Query('take') int take = 1000,
    @Query('filter') String filter = 'open',
    @Query('sort') String sort = 'added',
  });

  @GET('/api/v1/issue/{issueId}')
  Future<OverseerrIssue> getIssueById(
    @Path('issueId') int issueId,
  );

  @POST('/api/v1/issue/{issueId}/{status}')
  Future<dynamic> updateIssue(
    @Path('issueId') int issueId,
    @Path('status') String status,
  );

  @POST('/api/v1/issue/{issueId}/comment')
  Future<OverseerrIssue> postComment(
    @Path('issueId') int issueId,
    @Body() OverseerrMessage message,
  );

  // Media
  @GET('/api/v1/movie/{movieId}')
  Future<OverseerrMovie> getMovie(
    @Path('movieId') int movieId,
  );

  @GET('/api/v1/tv/{seriesId}')
  Future<OverseerrSeries> getSeries(
    @Path('seriesId') int seriesId,
  );

  // Server Configuration
  @GET('/api/v1/service/radarr/{serverId}')
  Future<OverseerrServerConfig> getRadarrServerConfig(
    @Path('serverId') int serverId,
  );

  @GET('/api/v1/service/sonarr/{serverId}')
  Future<OverseerrServerConfig> getSonarrServerConfig(
    @Path('serverId') int serverId,
  );

  // Users
  @GET('/api/v1/user')
  Future<OverseerrResponse<OverseerrUser>> getUsers({
    @Query('take') int take = 1000,
    @Query('sort') String sort = 'displayname',
  });

  // Status
  @GET('/api/v1/status')
  Future<OverseerrApiStatus> getStatus();
}
