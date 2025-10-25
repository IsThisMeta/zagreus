import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';

/// Service for managing the upcoming movies/shows home screen widget
/// Uses Radarr and Sonarr upcoming data instead of TMDB
class UpcomingWidgetService {
  static const String _appGroupId = 'group.app.zagreus';

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

      // Combine and sort by date
      final allContent = [...movies, ...shows];
      allContent.sort((a, b) {
        final aDate = DateTime.tryParse(a['releaseDate'] ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b['releaseDate'] ?? '') ?? DateTime.now();
        return aDate.compareTo(bDate);
      });

      // Return top 10 most relevant items
      return allContent.take(10).toList();
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

      return movies.take(5).map((movie) {
        // Determine the release date (prefer cinema date, fall back to physical/digital)
        String? releaseDate;
        if (movie.inCinemas != null) {
          releaseDate = movie.inCinemas!.toIso8601String();
        } else if (movie.physicalRelease != null) {
          releaseDate = movie.physicalRelease!.toIso8601String();
        } else if (movie.digitalRelease != null) {
          releaseDate = movie.digitalRelease!.toIso8601String();
        }

        return {
          'id': movie.id ?? 0,
          'title': movie.title ?? 'Unknown',
          'releaseDate': releaseDate ?? DateTime.now().toIso8601String(),
          'poster': null, // Widget doesn't display posters yet
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
        return {
          'id': episode.id ?? 0,
          'title': '${episode.series?.title ?? "Unknown"} - ${episode.title ?? "Episode"}',
          'releaseDate': episode.airDateUtc?.toIso8601String() ??
                        DateTime.now().toIso8601String(),
          'poster': null, // Widget doesn't display posters yet
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
  }) async {
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
      print('💾 Flutter: JSON length: ${jsonData.length} chars');
      print('💾 Flutter: First 200 chars: ${jsonData.substring(0, jsonData.length < 200 ? jsonData.length : 200)}');

      await HomeWidget.saveWidgetData<String>('upcoming_content', jsonData);
      await HomeWidget.saveWidgetData<String>(
        'last_updated',
        DateTime.now().toIso8601String(),
      );

      print('🔄 Flutter: Calling widget update...');
      // Update the widget UI
      await HomeWidget.updateWidget(
        iOSName: 'UpcomingWidget',
        androidName: 'UpcomingWidgetProvider',
      );

      print('✅ Flutter: Widget updated with ${widgetData.length} items');
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
