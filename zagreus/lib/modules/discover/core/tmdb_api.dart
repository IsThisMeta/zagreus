import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zagreus/modules/discover/core/api_keys.dart';

class TMDBApi {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p';

  // Get API key from secure config file
  static String get _apiKey => ApiKeys.tmdbApiKey;

  static String getImageUrl(String? path, {String size = 'original'}) {
    if (path == null || path.isEmpty) return '';
    return '$_imageBaseUrl/$size$path';
  }

  static Future<Map<String, dynamic>?> getTVShowDetails(int tmdbId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tv/$tmdbId?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'id': data['id'],
          'name': data['name'],
          'poster_path': data['poster_path'],
          'backdrop_path': data['backdrop_path'],
          'overview': data['overview'],
          'first_air_date': data['first_air_date'],
          'vote_average': data['vote_average'],
          'vote_count': data['vote_count'],
          'popularity': data['popularity'],
        };
      }
      return null;
    } catch (e) {
      print('Error fetching TV show details: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getMovieDetails(int tmdbId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/$tmdbId?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'id': data['id'],
          'title': data['title'],
          'poster_path': data['poster_path'],
          'backdrop_path': data['backdrop_path'],
          'overview': data['overview'],
          'release_date': data['release_date'],
          'vote_average': data['vote_average'],
          'vote_count': data['vote_count'],
          'popularity': data['popularity'],
        };
      }
      return null;
    } catch (e) {
      print('Error fetching movie details: $e');
      return null;
    }
  }

  // Multi-search across movies, TV shows, and people
  Future<List<Map<String, dynamic>>> searchMulti(String query,
      {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search/multi?api_key=$_apiKey&query=${Uri.encodeComponent(query)}&page=$page&include_adult=false'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // Return raw results for the search UI to process
        return List<Map<String, dynamic>>.from(results);
      }

      throw Exception('Failed to search: ${response.statusCode}');
    } catch (e) {
      print('TMDB Search Error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTrending({
    String mediaType = 'all',
    String timeWindow = 'day',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trending/$mediaType/$timeWindow?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // Transform the data to match our UI needs
        return results.map((item) {
          final mediaType = item['media_type'] ??
              (item['first_air_date'] != null ? 'tv' : 'movie');
          return {
            'id': item['id'],
            'title': item['title'] ?? item['name'] ?? 'Unknown',
            'backdrop': getImageUrl(item['backdrop_path']),
            'poster': getImageUrl(item['poster_path'], size: 'w500'),
            'rating': (item['vote_average'] ?? 0).toDouble(),
            'overview': item['overview'] ?? '',
            'releaseDate': item['release_date'] ?? item['first_air_date'],
            'mediaType': mediaType,
            'tmdbId': item['id'],
            // Mock data for now - would need additional API calls
            'watchingNow': (item['popularity'] ?? 0).toInt(),
            'inLibrary': false,
          };
        }).toList();
      }

      throw Exception('Failed to load trending: ${response.statusCode}');
    } catch (e) {
      print('TMDB API Error: $e');
      // Return mock data as fallback
      return _getMockData();
    }
  }

  static Future<List<Map<String, dynamic>>> getPopularMovies({
    int page = 1,
    String? region,
  }) async {
    try {
      String url = '$_baseUrl/movie/popular?api_key=$_apiKey&page=$page';
      if (region != null) {
        url += '&region=$region';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // Transform the data to match our UI needs
        return results.map((item) {
          return {
            'id': item['id'],
            'title': item['title'] ?? 'Unknown',
            'backdrop': getImageUrl(item['backdrop_path']),
            'poster': getImageUrl(item['poster_path'], size: 'w500'),
            'rating': (item['vote_average'] ?? 0).toDouble(),
            'overview': item['overview'] ?? '',
            'releaseDate': item['release_date'],
            'mediaType': 'movie',
            'tmdbId': item['id'],
            'popularity': item['popularity'] ?? 0,
            'inLibrary': false,
          };
        }).toList();
      }

      throw Exception('Failed to load popular movies: ${response.statusCode}');
    } catch (e) {
      print('TMDB API Error (Popular Movies): $e');
      // Return mock data as fallback
      return _getMockPopularMovies();
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentlyReleasedMovies({
    int page = 1,
    String? region,
  }) async {
    try {
      // Calculate date range: 2 months ago to today
      final now = DateTime.now();
      final twoMonthsAgo = DateTime(now.year, now.month - 2, now.day);
      final startDate = '${twoMonthsAgo.year}-${twoMonthsAgo.month.toString().padLeft(2, '0')}-${twoMonthsAgo.day.toString().padLeft(2, '0')}';
      final endDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Use discover endpoint with filters for recently released theatrical movies
      String url = '$_baseUrl/discover/movie?api_key=$_apiKey&page=$page';
      url += '&with_release_type=4'; // Theatrical releases only
      url += '&sort_by=release_date.desc'; // Newest first
      url += '&vote_count.gte=10'; // Minimum 10 votes for quality
      url += '&primary_release_date.gte=$startDate'; // Start date (2 months ago)
      url += '&release_date.lte=$endDate'; // End date (today)

      if (region != null) {
        url += '&region=$region';
      } else {
        url += '&region=US'; // Default to US
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // Transform and sort by release date (newest first)
        final movies = results.map((item) {
          return {
            'id': item['id'],
            'title': item['title'] ?? 'Unknown',
            'backdrop': getImageUrl(item['backdrop_path']),
            'poster': getImageUrl(item['poster_path'], size: 'w500'),
            'rating': (item['vote_average'] ?? 0).toDouble(),
            'overview': item['overview'] ?? '',
            'releaseDate': item['release_date'],
            'mediaType': 'movie',
            'tmdbId': item['id'],
            'popularity': item['popularity'] ?? 0,
            'voteCount': item['vote_count'] ?? 0,
            'inLibrary': false,
          };
        }).toList();

        // Sort by release date (newest first)
        movies.sort((a, b) {
          final aDate = a['releaseDate'] as String?;
          final bDate = b['releaseDate'] as String?;
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        });

        return movies;
      }

      throw Exception('Failed to load recently released movies: ${response.statusCode}');
    } catch (e) {
      print('TMDB API Error (Recently Released Movies): $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getPopularTVShows({
    int page = 1,
    String? region,
  }) async {
    try {
      String url = '$_baseUrl/tv/popular?api_key=$_apiKey&page=$page';
      if (region != null) {
        url += '&region=$region';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print(
            'TMDB API Error (Popular TV Shows): ${response.statusCode} ${response.body}');
        return [];
      }

      final data = json.decode(response.body);
      final results = data['results'] as List? ?? [];

      return results.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'],
          'title': item['name'] ?? 'Unknown',
          'backdrop': getImageUrl(item['backdrop_path']),
          'poster': getImageUrl(item['poster_path'], size: 'w500'),
          'rating': (item['vote_average'] ?? 0).toDouble(),
          'overview': item['overview'] ?? '',
          'firstAirDate': item['first_air_date'],
          'mediaType': 'tv',
          'tmdbId': item['id'],
          'popularity': item['popularity'] ?? 0,
          'inLibrary': false,
        };
      }).toList();
    } catch (e) {
      print('TMDB API Error (Popular TV Shows): $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getTrendingNewTVShows({
    String? region,
  }) async {
    try {
      // Fetch multiple pages to create a richer list (approx 100 items)
      List<Map<String, dynamic>> allShows = [];
      const int maxPages = 5;

      for (int p = 1; p <= maxPages; p++) {
        // Using discover endpoint to get new shows (first_air_date recent)
        final now = DateTime.now();
        final threeMonthsAgo = now.subtract(const Duration(days: 90));
        final oneMonthFromNow = now.add(const Duration(days: 30));

        String url = '$_baseUrl/discover/tv?api_key=$_apiKey&page=$p';
        url += '&sort_by=popularity.desc';
        url +=
            '&first_air_date.gte=${threeMonthsAgo.toIso8601String().split('T')[0]}';
        url +=
            '&first_air_date.lte=${oneMonthFromNow.toIso8601String().split('T')[0]}';
        url += '&with_original_language=en';

        if (region != null) {
          url += '&region=$region';
        }

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;

          // Transform the data to match our UI needs
          final shows = results.map((item) {
            return {
              'id': item['id'],
              'title': item['name'] ?? 'Unknown',
              'backdrop': getImageUrl(item['backdrop_path']),
              'poster': getImageUrl(item['poster_path'], size: 'w500'),
              'rating': (item['vote_average'] ?? 0).toDouble(),
              'overview': item['overview'] ?? '',
              'firstAirDate': item['first_air_date'],
              'mediaType': 'tv',
              'tmdbId': item['id'],
              'popularity': item['popularity'] ?? 0,
              'inLibrary': false,
              'isNew': true,
            };
          }).toList();

          if (shows.isEmpty) {
            break;
          }

          allShows.addAll(shows);
        }
      }

      return allShows;
    } catch (e) {
      print('TMDB API Error (Trending New TV Shows): $e');
      return [];
    }
  }

  // Simulating Trakt Most Anticipated Shows using TMDB
  // Fetches 40 shows from Trakt's anticipated endpoint
  static Future<List<Map<String, dynamic>>> getMostAnticipatedShows({
    String? region,
  }) async {
    try {
      // Trakt's anticipated shows are typically:
      // 1. Shows that are returning for new seasons soon
      // 2. New shows that haven't premiered yet but have buzz
      // 3. Popular shows with upcoming episodes

      List<Map<String, dynamic>> allShows = [];

      // Get on-the-air shows (these are actively anticipated)
      String onAirUrl = '$_baseUrl/tv/on_the_air?api_key=$_apiKey&page=1';
      if (region != null) {
        onAirUrl += '&region=$region';
      }

      final onAirResponse = await http.get(Uri.parse(onAirUrl));
      if (onAirResponse.statusCode == 200) {
        final onAirData = json.decode(onAirResponse.body);
        final onAirShows =
            (onAirData['results'] as List).cast<Map<String, dynamic>>();

        // Add all on-air shows (these are being anticipated for next episodes)
        for (final show in onAirShows) {
          show['anticipation_source'] = 'on_air';
          allShows.add(show);
        }
      }

      // Get popular shows with recent/upcoming episodes
      final now = DateTime.now();
      final twoWeeksAgo = now.subtract(const Duration(days: 14));
      final threeMonthsFromNow = now.add(const Duration(days: 90));

      String discoverUrl = '$_baseUrl/discover/tv?api_key=$_apiKey';
      discoverUrl += '&sort_by=popularity.desc';
      discoverUrl +=
          '&air_date.gte=${twoWeeksAgo.toIso8601String().split('T')[0]}';
      discoverUrl +=
          '&air_date.lte=${threeMonthsFromNow.toIso8601String().split('T')[0]}';
      discoverUrl += '&vote_count.gte=50'; // Popular shows only
      discoverUrl += '&page=1';

      if (region != null) {
        discoverUrl += '&region=$region';
      }

      final discoverResponse = await http.get(Uri.parse(discoverUrl));
      if (discoverResponse.statusCode == 200) {
        final discoverData = json.decode(discoverResponse.body);
        final discoverShows =
            (discoverData['results'] as List).cast<Map<String, dynamic>>();

        for (final show in discoverShows) {
          show['anticipation_source'] = 'upcoming';
          allShows.add(show);
        }
      }

      // Get top rated shows that might have new seasons
      String topRatedUrl = '$_baseUrl/tv/top_rated?api_key=$_apiKey&page=1';
      if (region != null) {
        topRatedUrl += '&region=$region';
      }

      final topRatedResponse = await http.get(Uri.parse(topRatedUrl));
      if (topRatedResponse.statusCode == 200) {
        final topRatedData = json.decode(topRatedResponse.body);
        final topRatedShows = (topRatedData['results'] as List)
            .take(15)
            .cast<Map<String, dynamic>>();

        for (final show in topRatedShows) {
          show['anticipation_source'] = 'top_rated';
          allShows.add(show);
        }
      }

      // Remove duplicates by ID
      final uniqueShows = <int, Map<String, dynamic>>{};
      for (final show in allShows) {
        final id = show['id'] as int;
        // Keep the first occurrence (prioritizes on_air shows)
        if (!uniqueShows.containsKey(id)) {
          uniqueShows[id] = show;
        }
      }

      // Sort by "anticipation level" (popularity * vote_count * recency)
      final sortedShows = uniqueShows.values.toList();
      sortedShows.sort((a, b) {
        final aPopularity = (a['popularity'] as num?) ?? 0;
        final bPopularity = (b['popularity'] as num?) ?? 0;
        final aVoteCount = (a['vote_count'] as num?) ?? 0;
        final bVoteCount = (b['vote_count'] as num?) ?? 0;

        // Prioritize on_air shows
        final aOnAir = a['anticipation_source'] == 'on_air' ? 2.0 : 1.0;
        final bOnAir = b['anticipation_source'] == 'on_air' ? 2.0 : 1.0;

        // Calculate anticipation score
        final aScore = aPopularity * (1 + (aVoteCount / 1000)) * aOnAir;
        final bScore = bPopularity * (1 + (bVoteCount / 1000)) * bOnAir;

        return bScore.compareTo(aScore);
      });

      // Take top 40 shows
      final anticipatedShows = sortedShows.take(40).map((item) {
        return {
          'id': item['id'],
          'title': item['name'] ?? 'Unknown',
          'backdrop': getImageUrl(item['backdrop_path']),
          'poster': getImageUrl(item['poster_path'], size: 'w500'),
          'rating': (item['vote_average'] ?? 0).toDouble(),
          'overview': item['overview'] ?? '',
          'firstAirDate': item['first_air_date'],
          'mediaType': 'tv',
          'tmdbId': item['id'],
          'popularity': item['popularity'] ?? 0,
          'voteCount': item['vote_count'] ?? 0,
          'inLibrary': false,
          'isAnticipated': true,
        };
      }).toList();

      return anticipatedShows;
    } catch (e) {
      print('API Error (Most Anticipated Shows): $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getPopularPeople({
    int page = 1,
    String? region,
  }) async {
    try {
      String url = '$_baseUrl/person/popular?api_key=$_apiKey&page=$page';
      if (region != null) {
        url += '&language=en-$region';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // Transform the data to match our UI needs
        return results.map((person) {
          return {
            'id': person['id'],
            'name': person['name'],
            'profilePath': person['profile_path'] != null
                ? getImageUrl(person['profile_path'], size: 'w185')
                : null,
            'knownForDepartment': person['known_for_department'],
            'popularity': person['popularity'],
            'knownFor': (person['known_for'] as List?)?.map((item) {
                  return {
                    'id': item['id'],
                    'title': item['title'] ?? item['name'] ?? 'Unknown',
                    'poster': getImageUrl(item['poster_path'], size: 'w185'),
                    'mediaType': item['media_type'],
                  };
                }).toList() ??
                [],
          };
        }).toList();
      }

      throw Exception('Failed to load popular people: ${response.statusCode}');
    } catch (e) {
      print('TMDB API Error (Popular People): $e');
      // Return mock data as fallback
      return _getMockPopularPeople();
    }
  }

  static Future<Map<String, dynamic>> getPersonDetails(int personId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/person/$personId?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Calculate age
        int? age;
        if (data['birthday'] != null) {
          final birthDate = DateTime.parse(data['birthday']);
          final deathDate = data['deathday'] != null
              ? DateTime.parse(data['deathday'])
              : DateTime.now();
          age = deathDate.year - birthDate.year;
        }

        return {
          'id': data['id'],
          'name': data['name'],
          'biography': data['biography'],
          'birthday': data['birthday'],
          'deathday': data['deathday'],
          'placeOfBirth': data['place_of_birth'],
          'profilePath': data['profile_path'] != null
              ? getImageUrl(data['profile_path'], size: 'w500')
              : null,
          'age': age,
          'knownForDepartment': data['known_for_department'],
        };
      }

      throw Exception('Failed to load person details: ${response.statusCode}');
    } catch (e) {
      print('TMDB API Error (Person Details): $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getPersonCombinedCredits(
      int personId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/person/$personId/combined_credits?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cast = data['cast'] as List;
        final crew = data['crew'] as List;

        final List<Map<String, dynamic>> credits = [];

        // Process cast credits
        for (final credit in cast) {
          final year =
              _extractYear(credit['release_date'] ?? credit['first_air_date']);
          credits.add({
            'id': credit['id'],
            'title': credit['title'] ?? credit['name'] ?? 'Unknown',
            'posterPath': credit['poster_path'] != null
                ? getImageUrl(credit['poster_path'], size: 'w342')
                : null,
            'mediaType': credit['media_type'],
            'creditType': 'cast',
            'role': credit['character'] ?? 'Actor',
            'rating': (credit['vote_average'] ?? 0).toDouble(),
            'releaseDate': credit['release_date'] ?? credit['first_air_date'],
            'year': year,
          });
        }

        // Process crew credits
        for (final credit in crew) {
          final year =
              _extractYear(credit['release_date'] ?? credit['first_air_date']);
          credits.add({
            'id': credit['id'],
            'title': credit['title'] ?? credit['name'] ?? 'Unknown',
            'posterPath': credit['poster_path'] != null
                ? getImageUrl(credit['poster_path'], size: 'w342')
                : null,
            'mediaType': credit['media_type'],
            'creditType': 'crew',
            'role': credit['job'] ?? credit['department'] ?? 'Crew',
            'rating': (credit['vote_average'] ?? 0).toDouble(),
            'releaseDate': credit['release_date'] ?? credit['first_air_date'],
            'year': year,
          });
        }

        return credits;
      }

      throw Exception('Failed to load person credits: ${response.statusCode}');
    } catch (e) {
      print('TMDB API Error (Person Credits): $e');
      return [];
    }
  }

  /// Get TMDB ID from IMDb ID for TV shows
  /// Used for Sonarr series that have IMDb IDs but not TMDB IDs
  static Future<int?> getTmdbIdFromImdb(String imdbId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/find/$imdbId?external_source=imdb_id&api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tvResults = data['tv_results'] as List;

        // Only proceed if exactly 1 result to avoid ambiguity
        if (tvResults.length == 1) {
          return tvResults[0]['id'] as int;
        }

        // Multiple or zero results = can't determine correct show
        return null;
      }

      return null;
    } catch (e) {
      print('TMDB API Error (IMDb Lookup): $e');
      return null;
    }
  }

  /// Get TV show credits (cast and crew) from TMDB
  static Future<Map<String, dynamic>?> getTvCredits(int tmdbId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tv/$tmdbId/credits?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'cast': data['cast'] as List,
          'crew': data['crew'] as List,
        };
      }

      return null;
    } catch (e) {
      print('TMDB API Error (TV Credits): $e');
      return null;
    }
  }

  static String? _extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    return dateString.split('-').first;
  }

  static List<Map<String, dynamic>> _getMockPopularPeople() {
    return [
      {
        'id': 1245,
        'name': 'Scarlett Johansson',
        'profilePath':
            'https://image.tmdb.org/t/p/w185/6NsMbJXRlDZuDzatN2akFdGuTvx.jpg',
        'knownForDepartment': 'Acting',
        'popularity': 98.5,
      },
      {
        'id': 2888,
        'name': 'Will Smith',
        'profilePath':
            'https://image.tmdb.org/t/p/w185/j1VdmftAir0hdeWKadDuIpfmWFd.jpg',
        'knownForDepartment': 'Acting',
        'popularity': 87.3,
      },
    ];
  }

  static List<Map<String, dynamic>> _getMockPopularMovies() {
    return [
      {
        'id': 939243,
        'title': 'Sonic the Hedgehog 3',
        'poster':
            'https://image.tmdb.org/t/p/w500/d8Ryb8AunYAuycVKDp5HpdWPKgC.jpg',
        'rating': 7.8,
        'tmdbId': 939243,
        'mediaType': 'movie',
        'inLibrary': false,
      },
      {
        'id': 1184918,
        'title': 'The Wild Robot',
        'poster':
            'https://image.tmdb.org/t/p/w500/wTnV3PCVW5O92JMrFvvrRcV39RU.jpg',
        'rating': 8.5,
        'tmdbId': 1184918,
        'mediaType': 'movie',
        'inLibrary': false,
      },
    ];
  }

  static List<Map<String, dynamic>> _getMockData() {
    return [
      {
        'title': 'Moana 2',
        'backdrop':
            'https://image.tmdb.org/t/p/original/tElnmtQ6yz1PjN1kePNl8yMSb59.jpg',
        'rating': 7.2,
        'watchingNow': 88,
        'inLibrary': true,
        'tmdbId': 1241982,
        'mediaType': 'movie',
      },
      {
        'title': 'Kaiju No. 8',
        'backdrop':
            'https://image.tmdb.org/t/p/original/geCRueV3ElhSIqJGJRfBdbiLRAp.jpg',
        'rating': 8.6,
        'watchingNow': 107,
        'inLibrary': false,
        'tmdbId': 226411,
        'mediaType': 'tv',
      },
      {
        'title': 'Wicked',
        'backdrop':
            'https://image.tmdb.org/t/p/original/c7Oft5UtMtfzS1w9YQbKnjQXSMw.jpg',
        'rating': 8.1,
        'watchingNow': 234,
        'inLibrary': true,
        'tmdbId': 402431,
        'mediaType': 'movie',
      },
    ];
  }
}
