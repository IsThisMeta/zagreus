import 'dart:convert';
import 'package:http/http.dart' as http;
import '.trakt_config.dart';

class TraktApi {
  static const String _baseUrl = 'https://api.trakt.tv';
  static const String _clientId = TraktConfig.clientId;
  static const String _apiVersion = '2';
  
  static Future<List<Map<String, dynamic>>> getAnticipatedShows({
    int page = 1,
    int limit = 40,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/shows/anticipated?page=$page&limit=$limit&extended=full',
      );
      
      final response = await http.get(
        url,
        headers: {
          'trakt-api-version': _apiVersion,
          'trakt-api-key': _clientId,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Transform Trakt data to match our UI format
        return data.map((item) {
          final show = item['show'] ?? {};
          final ids = show['ids'] ?? {};
          
          return {
            'id': ids['tmdb'] ?? ids['trakt'] ?? 0,
            'title': show['title'] ?? 'Unknown',
            'year': show['year'],
            'tmdbId': ids['tmdb'],
            'tvdbId': ids['tvdb'],
            'imdbId': ids['imdb'],
            'traktId': ids['trakt'],
            'slug': ids['slug'],
            'overview': show['overview'] ?? '',
            'rating': (show['rating'] as num?)?.toDouble() ?? 0.0,
            'votes': (show['votes'] as num?)?.toInt() ?? 0,
            'comment_count': show['comment_count'] ?? 0,
            'first_aired': show['first_aired'],
            'airs': show['airs'],
            'runtime': show['runtime'],
            'certification': show['certification'],
            'network': show['network'],
            'country': show['country'],
            'updated_at': show['updated_at'],
            'trailer': show['trailer'],
            'homepage': show['homepage'],
            'status': show['status'],
            'language': show['language'],
            'genres': show['genres'] ?? [],
            'aired_episodes': show['aired_episodes'],
            // Anticipation specific data
            'list_count': (item['list_count'] as num?)?.toInt() ?? 0,
            'mediaType': 'tv',
            'isAnticipated': true,
          };
        }).toList();
      }
      
      print('Trakt API error: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error fetching Trakt anticipated shows: $e');
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> getAnticipatedMovies({
    int page = 1,
    int limit = 40,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/movies/anticipated?page=$page&limit=$limit&extended=full',
      );
      
      final response = await http.get(
        url,
        headers: {
          'trakt-api-version': _apiVersion,
          'trakt-api-key': _clientId,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Transform Trakt data to match our UI format
        return data.map((item) {
          final movie = item['movie'] ?? {};
          final ids = movie['ids'] ?? {};
          
          return {
            'id': ids['tmdb'] ?? ids['trakt'] ?? 0,
            'title': movie['title'] ?? 'Unknown',
            'year': movie['year'],
            'tmdbId': ids['tmdb'],
            'imdbId': ids['imdb'],
            'traktId': ids['trakt'],
            'slug': ids['slug'],
            'overview': movie['overview'] ?? '',
            'rating': (movie['rating'] as num?)?.toDouble() ?? 0.0,
            'votes': (movie['votes'] as num?)?.toInt() ?? 0,
            'comment_count': movie['comment_count'] ?? 0,
            'released': movie['released'],
            'runtime': movie['runtime'],
            'certification': movie['certification'],
            'tagline': movie['tagline'],
            'country': movie['country'],
            'updated_at': movie['updated_at'],
            'trailer': movie['trailer'],
            'homepage': movie['homepage'],
            'language': movie['language'],
            'available_translations': movie['available_translations'] ?? [],
            'genres': movie['genres'] ?? [],
            // Anticipation specific data
            'list_count': (item['list_count'] as num?)?.toInt() ?? 0,
            'mediaType': 'movie',
            'isAnticipated': true,
          };
        }).toList();
      }
      
      print('Trakt API error: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error fetching Trakt anticipated movies: $e');
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> getTrendingShows({
    int page = 1,
    int limit = 40,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/shows/trending?page=$page&limit=$limit');
      
      final response = await http.get(
        url,
        headers: {
          'trakt-api-version': _apiVersion,
          'trakt-api-key': _clientId,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Transform Trakt data to match our UI format
        return data.map((item) {
          final show = item['show'] ?? {};
          final ids = show['ids'] ?? {};
          
          return {
            'id': ids['tmdb'] ?? ids['trakt'] ?? 0,
            'title': show['title'] ?? 'Unknown',
            'year': show['year'],
            'tmdbId': ids['tmdb'],
            'tvdbId': ids['tvdb'],
            'imdbId': ids['imdb'],
            'traktId': ids['trakt'],
            'slug': ids['slug'],
            'overview': show['overview'] ?? '',
            'rating': show['rating'] ?? 0.0,
            'votes': show['votes'] ?? 0,
            'watchers': item['watchers'] ?? 0,
            'mediaType': 'tv',
            'isTrending': true,
          };
        }).toList();
      }
      
      print('Trakt API error: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error fetching Trakt trending shows: $e');
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> getPopularShows({
    int page = 1,
    int limit = 40,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/shows/popular?page=$page&limit=$limit');
      
      final response = await http.get(
        url,
        headers: {
          'trakt-api-version': _apiVersion,
          'trakt-api-key': _clientId,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Transform Trakt data to match our UI format
        return data.map((show) {
          final ids = show['ids'] ?? {};
          
          return {
            'id': ids['tmdb'] ?? ids['trakt'] ?? 0,
            'title': show['title'] ?? 'Unknown',
            'year': show['year'],
            'tmdbId': ids['tmdb'],
            'tvdbId': ids['tvdb'],
            'imdbId': ids['imdb'],
            'traktId': ids['trakt'],
            'slug': ids['slug'],
            'overview': show['overview'] ?? '',
            'rating': show['rating'] ?? 0.0,
            'votes': show['votes'] ?? 0,
            'mediaType': 'tv',
            'isPopular': true,
          };
        }).toList();
      }
      
      print('Trakt API error: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error fetching Trakt popular shows: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getMovieRatings(String idOrSlug) async {
    final encodedId = Uri.encodeComponent(idOrSlug);
    final url = Uri.parse('$_baseUrl/movies/$encodedId/ratings');
    try {
      final response = await http.get(
        url,
        headers: {
          'trakt-api-version': _apiVersion,
          'trakt-api-key': _clientId,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      print(
          'Trakt API error (movie ratings): ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Error fetching Trakt movie ratings for $idOrSlug: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getShowRatings(String idOrSlug) async {
    final encodedId = Uri.encodeComponent(idOrSlug);
    final url = Uri.parse('$_baseUrl/shows/$encodedId/ratings');
    try {
      final response = await http.get(
        url,
        headers: {
          'trakt-api-version': _apiVersion,
          'trakt-api-key': _clientId,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      print(
          'Trakt API error (show ratings): ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Error fetching Trakt show ratings for $idOrSlug: $e');
      return null;
    }
  }
}
