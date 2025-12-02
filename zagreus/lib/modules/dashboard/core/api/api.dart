import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/database/tables/dashboard.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/modules/dashboard/core/api/data/abstract.dart';
import 'package:zagreus/modules/dashboard/core/api/data/lidarr.dart';
import 'package:zagreus/modules/dashboard/core/api/data/radarr.dart';
import 'package:zagreus/modules/dashboard/core/api/data/sonarr.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/vendor.dart';

class API {
  final ZagProfile profile;

  API._internal({
    required this.profile,
  });

  factory API() {
    return API._internal(profile: ZagProfile.current);
  }

  Future<Map<DateTime, List<CalendarData>>> getUpcoming(DateTime today) async {
    Map<DateTime, List<CalendarData>> _upcoming = {};
    if (profile.lidarrEnabled &&
        DashboardDatabase.CALENDAR_ENABLE_LIDARR.read()) {
      await _getLidarrUpcoming(_upcoming, today);
    }
    if (profile.radarrEnabled &&
        DashboardDatabase.CALENDAR_ENABLE_RADARR.read()) {
      await _getRadarrUpcoming(_upcoming, today);
    }
    if (profile.sonarrEnabled &&
        DashboardDatabase.CALENDAR_ENABLE_SONARR.read()) {
      await _getSonarrUpcoming(_upcoming, today);
    }
    return _upcoming;
  }

  Future<void> _getLidarrUpcoming(
    Map<DateTime, List<CalendarData>> map,
    DateTime today,
  ) async {
    Dio _client = Dio(
      BaseOptions(
        baseUrl: '${profile.effectiveLidarrHost()}/api/v1/',
        queryParameters: {
          if (profile.lidarrKey != '') 'apikey': profile.lidarrKey,
          'start': _startDate(today),
          'end': _endDate(today),
        },
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: profile.lidarrHeaders,
        followRedirects: true,
        maxRedirects: 5,
      ),
    );
    Response response = await _client.get('calendar');
    if (response.data.length > 0) {
      for (var entry in response.data) {
        DateTime? date =
            DateTime.tryParse(entry['releaseDate'] ?? '')?.toLocal().floor();
        if (date != null && _isDateWithinBounds(date, today)) {
          List<CalendarData> day = map[date] ?? [];
          day.add(CalendarLidarrData(
            id: entry['id'] ?? 0,
            title: entry['artist']['artistName'] ?? 'Unknown Artist',
            albumTitle: entry['title'] ?? 'Unknown Album Title',
            artistId: entry['artist']['id'] ?? 0,
            totalTrackCount: entry['statistics'] != null
                ? entry['statistics']['totalTrackCount'] ?? 0
                : 0,
            hasAllFiles: (entry['statistics'] != null
                    ? entry['statistics']['percentOfTracks'] ?? 0
                    : 0) ==
                100,
          ));
          map[date] = day;
        }
      }
    }
  }

  Future<void> _getRadarrUpcoming(
    Map<DateTime, List<CalendarData>> map,
    DateTime today,
  ) async {
    Dio _client = Dio(
      BaseOptions(
        baseUrl: '${profile.effectiveRadarrHost()}/api/v3/',
        queryParameters: {
          if (profile.radarrKey != '') 'apikey': profile.radarrKey,
          'start': _startDate(today),
          'end': _endDate(today),
        },
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: profile.radarrHeaders,
        followRedirects: true,
        maxRedirects: 5,
      ),
    );
    Response response = await _client.get('calendar');
    if (response.data.length > 0) {
      for (var entry in response.data) {
        DateTime? physicalRelease =
            DateTime.tryParse(entry['physicalRelease'] ?? '')
                ?.toLocal()
                .floor();
        DateTime? digitalRelease =
            DateTime.tryParse(entry['digitalRelease'] ?? '')?.toLocal().floor();
        if (physicalRelease != null || digitalRelease != null) {
          // Prefer digital release date when available; fallback to physical
          final release = digitalRelease ?? physicalRelease;
          if (release != null && _isDateWithinBounds(release, today)) {
            List<CalendarData> day = map[release] ?? [];
            day.add(CalendarRadarrData(
              id: entry['id'] ?? 0,
              title: entry['title'] ?? 'Unknown Title',
              hasFile: entry['hasFile'] ?? false,
              fileQualityProfile: entry['hasFile']
                  ? entry['movieFile']['quality']['quality']['name']
                  : '',
              year: entry['year'] ?? 0,
              runtime: entry['runtime'] ?? 0,
              studio: entry['studio'] ?? ZagUI.TEXT_EMDASH,
              releaseDate: release,
              monitored: entry['monitored'] ?? true,
            ));
            map[release] = day;
          }
        }
      }
    }
  }

  Future<void> _getSonarrUpcoming(
    Map<DateTime, List<CalendarData>> map,
    DateTime today,
  ) async {
    Dio _client = Dio(
      BaseOptions(
        baseUrl: '${profile.effectiveSonarrHost()}/api/v3/',
        queryParameters: {
          if (profile.sonarrKey != '') 'apikey': profile.sonarrKey,
          'start': _startDate(today),
          'end': _endDate(today),
        },
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: profile.sonarrHeaders,
        followRedirects: true,
        maxRedirects: 5,
      ),
    );
    Response response = await _client.get('calendar', queryParameters: {
      'includeSeries': true,
      'includeEpisodeFile': true,
      'unmonitored':
          DashboardDatabase.CALENDAR_INCLUDE_UNMONITORED_SONARR.read(),
    });
    if (response.data.length > 0) {
      for (var entry in response.data) {
        DateTime? date =
            DateTime.tryParse(entry['airDateUtc'] ?? '')?.toLocal().floor();
        if (date != null && _isDateWithinBounds(date, today)) {
          List<CalendarData> day = map[date] ?? [];
          day.add(CalendarSonarrData(
            id: entry['id'] ?? 0,
            seriesID: entry['seriesId'] ?? 0,
            title: entry['series']['title'] ?? 'Unknown Series',
            episodeTitle: entry['title'] ?? 'Unknown Episode Title',
            seasonNumber: entry['seasonNumber'] ?? -1,
            episodeNumber: entry['episodeNumber'] ?? -1,
            airTime: entry['airDateUtc'] ?? '',
            hasFile: entry['hasFile'] ?? false,
            fileQualityProfile: entry['hasFile']
                ? entry['episodeFile']['quality']['quality']['name']
                : '',
            monitored:
                entry['monitored'] ?? entry['series']?['monitored'] ?? true,
            runtime: entry['series']?['runtime'] ?? 0,
          ));
          map[date] = day;
        }
      }
    }
  }

  String _startDate(DateTime today) {
    return DateFormat('y-MM-dd').format(_startBoundDate(today));
  }

  String _endDate(DateTime today) {
    return DateFormat('y-MM-dd').format(_endBoundDate(today));
  }

  DateTime _startBoundDate(DateTime today) {
    return today.subtract(
      Duration(days: DashboardDatabase.CALENDAR_DAYS_PAST.read() + 1),
    );
  }

  DateTime _endBoundDate(DateTime today) {
    return today.add(
      Duration(days: DashboardDatabase.CALENDAR_DAYS_FUTURE.read() + 1),
    );
  }

  bool _isDateWithinBounds(DateTime date, DateTime today) {
    return date.isBetween(_startBoundDate(today), _endBoundDate(today));
  }
}
