library sonarr;

import 'package:dio/dio.dart';
import 'package:zagreus/api/sonarr/controllers.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class SonarrAPI {
  SonarrAPI._internal({
    required this.httpClient,
    required this.calendar,
    required this.command,
    required this.episode,
    required this.episodeFile,
    required this.filesystem,
    required this.healthCheck,
    required this.history,
    required this.importList,
    required this.notification,
    required this.profile,
    required this.queue,
    required this.release,
    required this.rootFolder,
    required this.series,
    required this.seriesLookup,
    required this.system,
    required this.tag,
    required this.wanted,
  });

  factory SonarrAPI({
    required String host,
    required String apiKey,
    Map<String, dynamic>? headers,
    bool followRedirects = true,
    int maxRedirects = 5,
    bool? slowServerMode,
  }) {
    final bool useSlowMode =
        slowServerMode ?? ZagreusDatabase.NETWORKING_SLOW_SERVER_MODE.read();
    Dio _dio = Dio(
      BaseOptions(
        baseUrl: host.endsWith('/') ? '${host}api/v3/' : '$host/api/v3/',
        queryParameters: {
          'apikey': apiKey,
        },
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: headers,
        followRedirects: followRedirects,
        maxRedirects: maxRedirects,
        connectTimeout: Duration(seconds: useSlowMode ? 40 : 20),
        receiveTimeout: Duration(seconds: useSlowMode ? 60 : 30),
        sendTimeout: Duration(seconds: useSlowMode ? 40 : 20),
      ),
    );
    return SonarrAPI._internal(
      httpClient: _dio,
      calendar: SonarrControllerCalendar(_dio),
      command: SonarrControllerCommand(_dio),
      episode: SonarrControllerEpisode(_dio),
      episodeFile: SonarrControllerEpisodeFile(_dio),
      filesystem: SonarrControllerFilesystem(_dio),
      healthCheck: SonarrControllerHealthCheck(_dio),
      history: SonarrControllerHistory(_dio),
      importList: SonarrControllerImportList(_dio),
      notification: SonarrControllerNotification(_dio),
      profile: SonarrControllerProfile(_dio),
      queue: SonarrControllerQueue(_dio),
      release: SonarrControllerRelease(_dio),
      rootFolder: SonarrControllerRootFolder(_dio),
      series: SonarrControllerSeries(_dio),
      seriesLookup: SonarrControllerSeriesLookup(_dio),
      system: SonarrControllerSystem(_dio),
      tag: SonarrControllerTag(_dio),
      wanted: SonarrControllerWanted(_dio),
    );
  }

  factory SonarrAPI.from({
    required Dio client,
  }) {
    return SonarrAPI._internal(
      httpClient: client,
      calendar: SonarrControllerCalendar(client),
      command: SonarrControllerCommand(client),
      episode: SonarrControllerEpisode(client),
      episodeFile: SonarrControllerEpisodeFile(client),
      filesystem: SonarrControllerFilesystem(client),
      healthCheck: SonarrControllerHealthCheck(client),
      history: SonarrControllerHistory(client),
      importList: SonarrControllerImportList(client),
      notification: SonarrControllerNotification(client),
      profile: SonarrControllerProfile(client),
      queue: SonarrControllerQueue(client),
      release: SonarrControllerRelease(client),
      rootFolder: SonarrControllerRootFolder(client),
      series: SonarrControllerSeries(client),
      seriesLookup: SonarrControllerSeriesLookup(client),
      system: SonarrControllerSystem(client),
      tag: SonarrControllerTag(client),
      wanted: SonarrControllerWanted(client),
    );
  }

  final Dio httpClient;

  final SonarrControllerCalendar calendar;
  final SonarrControllerCommand command;
  final SonarrControllerEpisode episode;
  final SonarrControllerEpisodeFile episodeFile;
  final SonarrControllerFilesystem filesystem;
  final SonarrControllerHealthCheck healthCheck;
  final SonarrControllerHistory history;
  final SonarrControllerImportList importList;
  final SonarrControllerNotification notification;
  final SonarrControllerProfile profile;
  final SonarrControllerQueue queue;
  final SonarrControllerRelease release;
  final SonarrControllerRootFolder rootFolder;
  final SonarrControllerSeries series;
  final SonarrControllerSeriesLookup seriesLookup;
  final SonarrControllerSystem system;
  final SonarrControllerTag tag;
  final SonarrControllerWanted wanted;
}
