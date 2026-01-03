import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:zagreus/api/seerr/models.dart';
import 'package:zagreus/vendor.dart';

part 'seerr.g.dart';

@RestApi(baseUrl: '')
abstract class SeerrAPI {
  factory SeerrAPI(Dio dio, {String baseUrl}) = _SeerrAPI;

  // Requests
  @GET('v1/request')
  Future<SeerrResponse<SeerrRequest>> getRequests({
    @Query('take') int take = 1000,
    @Query('filter') String filter = 'pending',
    @Query('sort') String sort = 'added',
  });

  @POST('v1/request/{requestId}/{status}')
  Future<dynamic> updateRequest(
    @Path('requestId') int requestId,
    @Path('status') String status,
  );

  @PUT('v1/request/{requestId}')
  Future<dynamic> updateRequestWithEdits(
    @Path('requestId') int requestId,
    @Body() SeerrMediaRequest mediaRequest,
  );

  @DELETE('v1/request/{requestId}')
  Future<dynamic> deleteRequest(
    @Path('requestId') int requestId,
  );

  // Issues
  @GET('v1/issue')
  Future<SeerrResponse<SeerrIssue>> getIssues({
    @Query('take') int take = 1000,
    @Query('filter') String filter = 'open',
    @Query('sort') String sort = 'added',
  });

  @GET('v1/issue/{issueId}')
  Future<SeerrIssue> getIssueById(
    @Path('issueId') int issueId,
  );

  @POST('v1/issue/{issueId}/{status}')
  Future<dynamic> updateIssue(
    @Path('issueId') int issueId,
    @Path('status') String status,
  );

  @POST('v1/issue/{issueId}/comment')
  Future<SeerrIssue> postComment(
    @Path('issueId') int issueId,
    @Body() SeerrMessage message,
  );

  // Media
  @GET('v1/movie/{movieId}')
  Future<SeerrMovie> getMovie(
    @Path('movieId') int movieId,
  );

  @GET('v1/tv/{seriesId}')
  Future<SeerrSeries> getSeries(
    @Path('seriesId') int seriesId,
  );

  // Server Configuration
  @GET('v1/service/radarr/{serverId}')
  Future<SeerrServerConfig> getRadarrServerConfig(
    @Path('serverId') int serverId,
  );

  @GET('v1/service/sonarr/{serverId}')
  Future<SeerrServerConfig> getSonarrServerConfig(
    @Path('serverId') int serverId,
  );

  // Users
  @GET('v1/user')
  Future<SeerrResponse<SeerrUser>> getUsers({
    @Query('take') int take = 1000,
    @Query('sort') String sort = 'displayname',
  });

  // Status
  @GET('v1/status')
  Future<SeerrApiStatus> getStatus();
}
