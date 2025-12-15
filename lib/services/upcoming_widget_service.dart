import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';

/// Service for managing the upcoming movies/shows home screen widget
/// Uses Radarr and Sonarr upcoming data instead of TMDB
class UpcomingWidgetService {
  static const String _appGroupId = 'group.app.zagreus';
  static bool _initialUpdateCompleted = false;

  /// Initialize the widget service (call this in main.dart bootstrap)
  static Future<void> initialize() async {
    try {
      // Configure app group for iOS
      await HomeWidget.setAppGroupId(_appGroupId);
      print('📱 Widget service initialized');

      // Note: Widget update happens later when Radarr/Sonarr states are available
    } catch (e) {
      print('⚠️ Widget initialization error: $e');
    }
  }

  /// Fetch upcoming movies and shows from Radarr and Sonarr
  static Future<List<Map<String, dynamic>>> getUpcomingContent(
    RadarrState radarrState,
    SonarrState sonarrState,
  ) async {
    try {
      final movies = await _getUpcomingMovies(radarrState);
      final shows = await _getUpcomingShows(sonarrState);

      // Combine all content
      final allContent = [...movies, ...shows];

      // Filter to only show items airing this week
      final now = DateTime.now();
      final endOfWeek = now.add(const Duration(days: 7));

      final thisWeekContent = allContent.where((item) {
        final dateStr = item['releaseDate'] as String?;
        if (dateStr == null) return false;

        final date = DateTime.tryParse(dateStr);
        if (date == null) return false;

        // Include if it's between now and 7 days from now
        return date.isAfter(now.subtract(const Duration(days: 1))) &&
               date.isBefore(endOfWeek);
      }).toList();

      // Sort by date
      thisWeekContent.sort((a, b) {
        final aDate = DateTime.tryParse(a['releaseDate'] ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b['releaseDate'] ?? '') ?? DateTime.now();
        return aDate.compareTo(bDate);
      });

      // Return top 10 most relevant items
      return thisWeekContent.take(10).toList();
    } catch (e) {
      print('Error fetching upcoming content: $e');
      return [];
    }
  }

  /// Fetch upcoming movies from Radarr
  static Future<List<Map<String, dynamic>>> _getUpcomingMovies(
    RadarrState radarrState,
  ) async {
    try {
      if (radarrState.upcoming == null) {
        return [];
      }

      final movies = await radarrState.upcoming!;

      return movies.take(10).map((movie) {
        // Use digital release date (prefer digital, fall back to physical/cinema)
        String? releaseDate;
        if (movie.digitalRelease != null) {
          releaseDate = movie.digitalRelease!.toIso8601String();
        } else if (movie.physicalRelease != null) {
          releaseDate = movie.physicalRelease!.toIso8601String();
        } else if (movie.inCinemas != null) {
          releaseDate = movie.inCinemas!.toIso8601String();
        }

        // Get poster URL
        String? posterUrl;
        if (movie.images != null && movie.images!.isNotEmpty) {
          final poster = movie.images!.firstWhere(
            (img) => img.coverType == 'poster',
            orElse: () => movie.images!.first,
          );
          posterUrl = poster.remoteUrl;
        }

        return {
          'id': movie.id ?? 0,
          'title': movie.title ?? 'Unknown',
          'releaseDate': releaseDate,
          'poster': posterUrl,
          'mediaType': 'movie',
          'rating': movie.ratings?.value?.toDouble() ?? 0.0,
          'overview': movie.overview ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching upcoming movies from Radarr: $e');
      return [];
    }
  }

  /// Fetch upcoming shows from Sonarr
  static Future<List<Map<String, dynamic>>> _getUpcomingShows(
    SonarrState sonarrState,
  ) async {
    try {
      if (sonarrState.upcoming == null) {
        return [];
      }

      final episodes = await sonarrState.upcoming!;

      return episodes.take(5).map((episode) {
        final seriesTitle = episode.series?.title ?? "Unknown";
        final episodeTitle = episode.title ?? "Episode";

        // Get poster URL from series
        String? posterUrl;
        if (episode.series?.images != null && episode.series!.images!.isNotEmpty) {
          final poster = episode.series!.images!.firstWhere(
            (img) => img.coverType == 'poster',
            orElse: () => episode.series!.images!.first,
          );
          posterUrl = poster.remoteUrl;
        }

        return {
          'id': episode.id ?? 0,
          'title': seriesTitle,
          'episodeTitle': episodeTitle,
          'releaseDate': episode.airDateUtc?.toIso8601String() ??
                        DateTime.now().toIso8601String(),
          'poster': posterUrl,
          'mediaType': 'tv',
          'rating': 0.0, // Episodes don't have ratings in calendar
          'overview': episode.overview ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching upcoming shows from Sonarr: $e');
      return [];
    }
  }

  /// Update the home screen widget with upcoming content
  static Future<bool> updateWidget({
    RadarrState? radarrState,
    SonarrState? sonarrState,
    bool skipIfAlreadyUpdated = false,
  }) async {
    if (skipIfAlreadyUpdated && _initialUpdateCompleted) {
      print('ℹ️ Flutter: Initial widget update already completed; skipping duplicate call.');
      return false;
    }
    try {
      print('📱 Flutter: Updating upcoming widget...');

      // If states aren't provided, we can't update
      if (radarrState == null || sonarrState == null) {
        print('⚠️ Flutter: Radarr/Sonarr states not available');
        return false;
      }

      print('📦 Flutter: Fetching upcoming content...');
      final upcomingContent = await getUpcomingContent(radarrState, sonarrState);

      print('📊 Flutter: Got ${upcomingContent.length} items');
      if (upcomingContent.isEmpty) {
        print('⚠️ Flutter: No upcoming content found');
        // Still update with empty data so widget shows "no content" message
      }

      // Save data to widget storage (max 5 items for widget display)
      final widgetData = upcomingContent.take(5).toList();

      // Convert to JSON for widget
      final jsonData = json.encode(widgetData);
      print('💾 Flutter: Saving to UserDefaults with key "upcoming_content"');

      await HomeWidget.saveWidgetData<String>('upcoming_content', jsonData);
      await HomeWidget.saveWidgetData<String>(
        'last_updated',
        DateTime.now().toIso8601String(),
      );

      // Update the widget UI
      await HomeWidget.updateWidget(
        iOSName: 'UpcomingWidget',
        androidName: 'UpcomingWidgetProvider',
      );

      print('✅ Flutter: Widget updated with ${widgetData.length} items');
      _initialUpdateCompleted = true;
      return true;
    } catch (e) {
      print('❌ Flutter: Error updating widget: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Manually refresh the widget (can be called from UI)
  static Future<bool> refreshWidget({
    RadarrState? radarrState,
    SonarrState? sonarrState,
  }) async {
    print('🔄 Manual widget refresh requested');
    return await updateWidget(
      radarrState: radarrState,
      sonarrState: sonarrState,
    );
  }

  /// Schedule periodic widget updates
  static Future<void> scheduleWidgetUpdates() async {
    // iOS: Register background app refresh
    await HomeWidget.registerBackgroundCallback(backgroundCallback);

    print('📅 Widget updates scheduled');
  }
}

/// Background callback for widget updates (must be top-level function)
@pragma('vm:entry-point')
void backgroundCallback(Uri? uri) async {
  // Note: Background callbacks can't easily access Provider states
  // Widget will show last cached data until app is opened again
  print('🔄 Background widget refresh triggered');
}
