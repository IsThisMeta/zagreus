import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/database/tables/dashboard.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/modules/dashboard/core/api/data/abstract.dart';
import 'package:zagreus/modules/dashboard/core/api/data/lidarr.dart';
import 'package:zagreus/modules/dashboard/core/api/data/radarr.dart';
import 'package:zagreus/modules/dashboard/core/api/data/sonarr.dart';
import 'package:zagreus/system/logger.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/core/logger.dart';
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
    
    // Get calendar instance filter (empty = show all)
    final filter = List<String>.from(
      ZagreusDatabase.CALENDAR_INSTANCE_FILTER.read() ?? []
    );
    final showAll = filter.isEmpty;
    
    // Lidarr (no multi-instance support yet, always use main)
    if (profile.lidarrEnabled &&
        DashboardDatabase.CALENDAR_ENABLE_LIDARR.read()) {
      try {
        await _getLidarrUpcoming(_upcoming, today, profile);
      } catch (error, stack) {
        ZagLogger().error(
          'Failed to fetch Lidarr calendar data',
          error,
          stack,
        );
      }
    }
    
    // Radarr - check main and instances
    if (DashboardDatabase.CALENDAR_ENABLE_RADARR.read()) {
      // Main Radarr (null instanceKey = main)
      if (profile.radarrEnabled && (showAll || filter.contains('radarr:main'))) {
        try {
          await _getRadarrUpcoming(_upcoming, today, profile);
        } catch (error, stack) {
          ZagLogger().error(
            'Failed to fetch Radarr calendar data (main)',
            error,
            stack,
          );
        }
      }
      // Radarr instances
      final currentProfileKey = ZagreusDatabase.ENABLED_PROFILE.read();
      final radarrInstances = ZagProfile.getInstancesForModule(currentProfileKey, 'radarr');
      for (final instanceKey in radarrInstances) {
        if (showAll || filter.contains('radarr:$instanceKey')) {
          final instanceProfile = ZagBox.profiles.read(instanceKey);
          if (instanceProfile != null && instanceProfile.radarrEnabled) {
            try {
              await _getRadarrUpcoming(_upcoming, today, instanceProfile, instanceKey: instanceKey);
            } catch (error, stack) {
              ZagLogger().error(
                'Failed to fetch Radarr calendar data (instance: $instanceKey)',
                error,
                stack,
              );
            }
          }
        }
      }
    }
    
    // Sonarr - check main and instances
    if (DashboardDatabase.CALENDAR_ENABLE_SONARR.read()) {
      // Main Sonarr (null instanceKey = main)
      if (profile.sonarrEnabled && (showAll || filter.contains('sonarr:main'))) {
        try {
          await _getSonarrUpcoming(_upcoming, today, profile);
        } catch (error, stack) {
          ZagLogger().error(
            'Failed to fetch Sonarr calendar data (main)',
            error,
            stack,
          );
        }
      }
      // Sonarr instances
      final currentProfileKey = ZagreusDatabase.ENABLED_PROFILE.read();
      final sonarrInstances = ZagProfile.getInstancesForModule(currentProfileKey, 'sonarr');
      for (final instanceKey in sonarrInstances) {
        if (showAll || filter.contains('sonarr:$instanceKey')) {
          final instanceProfile = ZagBox.profiles.read(instanceKey);
          if (instanceProfile != null && instanceProfile.sonarrEnabled) {
            try {
              await _getSonarrUpcoming(_upcoming, today, instanceProfile, instanceKey: instanceKey);
            } catch (error, stack) {
              ZagLogger().error(
                'Failed to fetch Sonarr calendar data (instance: $instanceKey)',
                error,
                stack,
              );
            }
          }
        }
      }
    }
    
    // Dedupe: if same title appears in multiple instances, keep only the first (main profile preferred)
    for (final date in _upcoming.keys) {
      final seen = <String>{};
      _upcoming[date] = _upcoming[date]!.where((item) {
        final key = '${item.runtimeType}:${item.title}';
        if (seen.contains(key)) return false;
        seen.add(key);
        return true;
      }).toList();
    }
    
    return _upcoming;
  }

  Future<void> _getLidarrUpcoming(
    Map<DateTime, List<CalendarData>> map,
    DateTime today,
    ZagProfile useProfile,
  ) async {
    Dio _client = Dio(
      BaseOptions(
        baseUrl: '${useProfile.effectiveLidarrHost()}/api/v1/',
        queryParameters: {
          if (useProfile.lidarrKey != '') 'apikey': useProfile.lidarrKey,
          'start': _startDate(today),
          'end': _endDate(today),
        },
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: useProfile.lidarrHeaders,
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
    ZagProfile useProfile, {
    String? instanceKey,
  }) async {
    Dio _client = Dio(
      BaseOptions(
        baseUrl: '${useProfile.effectiveRadarrHost()}/api/v3/',
        queryParameters: {
          if (useProfile.radarrKey != '') 'apikey': useProfile.radarrKey,
          'start': _startDate(today),
          'end': _endDate(today),
        },
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: useProfile.radarrHeaders,
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
              instanceKey: instanceKey,
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
    ZagProfile useProfile, {
    String? instanceKey,
  }) async {
    Dio _client = Dio(
      BaseOptions(
        baseUrl: '${useProfile.effectiveSonarrHost()}/api/v3/',
        queryParameters: {
          if (useProfile.sonarrKey != '') 'apikey': useProfile.sonarrKey,
          'start': _startDate(today),
          'end': _endDate(today),
        },
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: useProfile.sonarrHeaders,
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
            instanceKey: instanceKey,
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
