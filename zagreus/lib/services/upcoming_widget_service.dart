import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:home_widget/home_widget.dart';
import 'package:zagreus/modules/discover/core/api_keys.dart';

/// Service for managing the upcoming movies/shows home screen widget
class UpcomingWidgetService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static String get _apiKey => ApiKeys.tmdbApiKey;
  static const String _appGroupId = 'group.app.zagreus';

  /// Initialize the widget service (call this in main.dart bootstrap)
  static Future<void> initialize() async {
    try {
      // Configure app group for iOS
      await HomeWidget.setAppGroupId(_appGroupId);
      print('📱 Widget service initialized');

      // Update widget on app launch
      await updateWidget();
    } catch (e) {
      print('⚠️ Widget initialization error: $e');
    }
  }

  /// Fetch upcoming movies and shows for the next 7 days
  static Future<List<Map<String, dynamic>>> getUpcomingContent() async {
    final now = DateTime.now();
    final oneWeekFromNow = now.add(const Duration(days: 7));

    try {
      final movies = await _getUpcomingMovies(now, oneWeekFromNow);
      final shows = await _getUpcomingTVShows(now, oneWeekFromNow);

      // Combine and sort by date
      final allContent = [...movies, ...shows];
      allContent.sort((a, b) {
        final aDate = DateTime.tryParse(a['releaseDate'] ?? '') ?? now;
        final bDate = DateTime.tryParse(b['releaseDate'] ?? '') ?? now;
        return aDate.compareTo(bDate);
      });

      // Return top 10 most relevant items
      return allContent.take(10).toList();
    } catch (e) {
      print('Error fetching upcoming content: $e');
      return [];
    }
  }

  /// Fetch upcoming movies releasing in the next week
  static Future<List<Map<String, dynamic>>> _getUpcomingMovies(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Use TMDB's upcoming endpoint for theatrical releases
      final url = '$_baseUrl/movie/upcoming?api_key=$_apiKey&region=US&page=1';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // Filter to only include movies in our date range
        final now = DateTime.now();
        final oneWeekFromNow = now.add(const Duration(days: 7));

        return results
            .where((item) {
              if (item['release_date'] == null || item['release_date'] == '') {
                return false;
              }
              try {
                final releaseDate = DateTime.parse(item['release_date']);
                return releaseDate.isAfter(now.subtract(const Duration(days: 1))) &&
                       releaseDate.isBefore(oneWeekFromNow);
              } catch (e) {
                return false;
              }
            })
            .map((item) {
              return {
                'id': item['id'],
                'title': item['title'] ?? 'Unknown',
                'releaseDate': item['release_date'],
                'poster': item['poster_path'] != null
                    ? 'https://image.tmdb.org/t/p/w500${item['poster_path']}'
                    : null,
                'mediaType': 'movie',
                'rating': (item['vote_average'] ?? 0).toDouble(),
                'overview': item['overview'] ?? '',
              };
            })
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching upcoming movies: $e');
      return [];
    }
  }

  /// Fetch TV shows with episodes airing in the next week
  static Future<List<Map<String, dynamic>>> _getUpcomingTVShows(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Use TMDB's on_the_air endpoint for shows with episodes airing soon
      final url = '$_baseUrl/tv/on_the_air?api_key=$_apiKey&region=US&page=1';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // Use today's date as a proxy for "new episode"
        final today = DateTime.now().toIso8601String().split('T')[0];

        return results
            .where((item) => item['first_air_date'] != null && item['first_air_date'] != '')
            .map((item) {
              return {
                'id': item['id'],
                'title': item['name'] ?? 'Unknown',
                // Use today as the air date for on_the_air shows
                'releaseDate': today,
                'poster': item['poster_path'] != null
                    ? 'https://image.tmdb.org/t/p/w500${item['poster_path']}'
                    : null,
                'mediaType': 'tv',
                'rating': (item['vote_average'] ?? 0).toDouble(),
                'overview': item['overview'] ?? '',
              };
            })
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching upcoming TV shows: $e');
      return [];
    }
  }

  /// Update the home screen widget with upcoming content
  static Future<bool> updateWidget() async {
    try {
      print('📱 Updating upcoming widget...');

      final upcomingContent = await getUpcomingContent();

      if (upcomingContent.isEmpty) {
        print('⚠️ No upcoming content found');
        return false;
      }

      // Save data to widget storage (max 5 items for widget display)
      final widgetData = upcomingContent.take(5).toList();

      // Convert to JSON for widget
      final jsonData = json.encode(widgetData);
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

      print('✅ Widget updated with ${widgetData.length} items');
      return true;
    } catch (e) {
      print('❌ Error updating widget: $e');
      return false;
    }
  }

  /// Manually refresh the widget (can be called from UI)
  static Future<bool> refreshWidget() async {
    print('🔄 Manual widget refresh requested');
    return await updateWidget();
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
  await UpcomingWidgetService.updateWidget();
}
