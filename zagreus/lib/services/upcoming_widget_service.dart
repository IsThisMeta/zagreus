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
      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];

      final url = '$_baseUrl/discover/movie?api_key=$_apiKey'
          '&sort_by=popularity.desc'
          '&release_date.gte=$startStr'
          '&release_date.lte=$endStr'
          '&with_release_type=2|3'  // Theatrical or limited release
          '&region=US';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((item) {
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
        }).toList();
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
      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];

      final url = '$_baseUrl/discover/tv?api_key=$_apiKey'
          '&sort_by=popularity.desc'
          '&air_date.gte=$startStr'
          '&air_date.lte=$endStr'
          '&with_status=0'  // Returning series
          '&region=US';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((item) {
          return {
            'id': item['id'],
            'title': item['name'] ?? 'Unknown',
            'releaseDate': item['first_air_date'],
            'poster': item['poster_path'] != null
                ? 'https://image.tmdb.org/t/p/w500${item['poster_path']}'
                : null,
            'mediaType': 'tv',
            'rating': (item['vote_average'] ?? 0).toDouble(),
            'overview': item['overview'] ?? '',
          };
        }).toList();
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
