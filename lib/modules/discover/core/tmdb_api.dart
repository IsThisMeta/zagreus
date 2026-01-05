import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zagreus/modules/discover/core/api_keys.dart';

class TMDBApi {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p';

  // Get API key from secure config file
  static String get _apiKey => ApiKeys.tmdbApiKey;

  // Genre caching - genres rarely change, cache for 24 hours
  static List<Map<String, dynamic>>? _movieGenresCache;
  static DateTime? _movieGenresCacheTime;
  static List<Map<String, dynamic>>? _tvGenresCache;
  static DateTime? _tvGenresCacheTime;
  static const Duration _genresCacheDuration = Duration(hours: 24);

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
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trending/$mediaType/$timeWindow?api_key=$_apiKey&page=$page'),
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
            'poster': getImageUrl(item['poster_path'], size: 'w342'),
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
            'poster': getImageUrl(item['poster_path'], size: 'w342'),
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
            'poster': getImageUrl(item['poster_path'], size: 'w342'),
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
      print('TMDB API Error (Recently Released): $e');
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
          'poster': getImageUrl(item['poster_path'], size: 'w342'),
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
      // Fetch 1 page (20 items) since we only display 10
      List<Map<String, dynamic>> allShows = [];
      const int maxPages = 1;

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
              'poster': getImageUrl(item['poster_path'], size: 'w342'),
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
          'poster': getImageUrl(item['poster_path'], size: 'w342'),
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
              ? getImageUrl(data['profile_path'], size: 'w342')
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

  /// Get watch providers (streaming services) for a movie
  /// Returns a map with 'streaming' and 'buyRent' lists of providers, plus a 'link' to JustWatch
  static Future<Map<String, dynamic>> getMovieWatchProviders(
    int tmdbId, {
    required String region,
  }) async {
    try {
      final url =
          Uri.parse('$_baseUrl/movie/$tmdbId/watch/providers?api_key=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        final bodyPreview =
            response.body.length > 300 ? '${response.body.substring(0, 300)}…' : response.body;
        print(
            'TMDB watch providers (movie) failed tmdbId=$tmdbId region=$region status=${response.statusCode} body=$bodyPreview');
      } else {
        print(
            'TMDB watch providers (movie) tmdbId=$tmdbId region=$region status=200');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as Map<String, dynamic>?;

        if (results == null || results.isEmpty) {
          print(
              'TMDB watch providers (movie) no results tmdbId=$tmdbId region=$region');
          return {'streaming': [], 'buyRent': [], 'link': null};
        }

        final regionKey = region.toUpperCase();
        final regionData = results[regionKey] as Map<String, dynamic>?;

        if (regionData == null) {
          print(
              'TMDB watch providers (movie) missing region block tmdbId=$tmdbId region=$regionKey');
          return {'streaming': [], 'buyRent': [], 'link': null};
        }

        // Get the JustWatch link
        final link = regionData['link'] as String?;

        // Get streaming providers (flatrate)
        final streamingProviders = (regionData['flatrate'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((item) => {
                      'provider_id': item['provider_id'],
                      'provider_name': item['provider_name'],
                      'logo_path': item['logo_path'],
                      'display_priority': item['display_priority'] ?? 999,
                    })
                .toList() ??
            [];

        // Get buy/rent providers (combine buy and rent lists)
        final buyProviders = (regionData['buy'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            [];
        final rentProviders = (regionData['rent'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            [];

        // Combine and deduplicate by provider_id
        final buyRentMap = <int, Map<String, dynamic>>{};
        for (final provider in [...buyProviders, ...rentProviders]) {
          final id = provider['provider_id'] as int;
          if (!buyRentMap.containsKey(id)) {
            buyRentMap[id] = {
              'provider_id': provider['provider_id'],
              'provider_name': provider['provider_name'],
              'logo_path': provider['logo_path'],
              'display_priority': provider['display_priority'] ?? 999,
            };
          }
        }

        // Sort by display priority
        streamingProviders.sort((a, b) =>
          (a['display_priority'] as int).compareTo(b['display_priority'] as int));
        final buyRentProviders = buyRentMap.values.toList()
          ..sort((a, b) =>
            (a['display_priority'] as int).compareTo(b['display_priority'] as int));

        return {
          'streaming': streamingProviders,
          'buyRent': buyRentProviders,
          'link': link,
        };
      }
    } catch (e) {
      print('Error fetching movie watch providers: $e');
    }

    return {'streaming': [], 'buyRent': [], 'link': null};
  }

  /// Get watch providers (streaming services) for a TV show
  /// Returns a map with 'streaming' and 'buyRent' lists of providers, plus a 'link' to JustWatch
  static Future<Map<String, dynamic>> getTVShowWatchProviders(
    int tmdbId, {
    required String region,
  }) async {
    try {
      final url =
          Uri.parse('$_baseUrl/tv/$tmdbId/watch/providers?api_key=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        final bodyPreview =
            response.body.length > 300 ? '${response.body.substring(0, 300)}…' : response.body;
        print(
            'TMDB watch providers (tv) failed tmdbId=$tmdbId region=$region status=${response.statusCode} body=$bodyPreview');
      } else {
        print('TMDB watch providers (tv) tmdbId=$tmdbId region=$region status=200');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as Map<String, dynamic>?;

        if (results == null || results.isEmpty) {
          print('TMDB watch providers (tv) no results tmdbId=$tmdbId region=$region');
          return {'streaming': [], 'buyRent': [], 'link': null};
        }

        final regionKey = region.toUpperCase();
        final regionData = results[regionKey] as Map<String, dynamic>?;

        if (regionData == null) {
          print(
              'TMDB watch providers (tv) missing region block tmdbId=$tmdbId region=$regionKey');
          return {'streaming': [], 'buyRent': [], 'link': null};
        }

        // Get the JustWatch link
        final link = regionData['link'] as String?;

        // Get streaming providers (flatrate)
        final streamingProviders = (regionData['flatrate'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((item) => {
                      'provider_id': item['provider_id'],
                      'provider_name': item['provider_name'],
                      'logo_path': item['logo_path'],
                      'display_priority': item['display_priority'] ?? 999,
                    })
                .toList() ??
            [];

        // Get buy/rent providers (combine buy and rent lists)
        final buyProviders = (regionData['buy'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            [];
        final rentProviders = (regionData['rent'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            [];

        // Combine and deduplicate by provider_id
        final buyRentMap = <int, Map<String, dynamic>>{};
        for (final provider in [...buyProviders, ...rentProviders]) {
          final id = provider['provider_id'] as int;
          if (!buyRentMap.containsKey(id)) {
            buyRentMap[id] = {
              'provider_id': provider['provider_id'],
              'provider_name': provider['provider_name'],
              'logo_path': provider['logo_path'],
              'display_priority': provider['display_priority'] ?? 999,
            };
          }
        }

        // Sort by display priority
        streamingProviders.sort((a, b) =>
          (a['display_priority'] as int).compareTo(b['display_priority'] as int));
        final buyRentProviders = buyRentMap.values.toList()
          ..sort((a, b) =>
            (a['display_priority'] as int).compareTo(b['display_priority'] as int));

        return {
          'streaming': streamingProviders,
          'buyRent': buyRentProviders,
          'link': link,
        };
      }
    } catch (e) {
      print('Error fetching TV show watch providers: $e');
    }

    return {'streaming': [], 'buyRent': [], 'link': null};
  }

  /// Build a deep link URL for a specific streaming provider
  /// Returns the provider's app deep link or web URL based on provider_id
  static String? buildProviderDeepLink({
    required int providerId,
    required String providerName,
    required int tmdbId,
    required String title,
    required String mediaType, // 'movie' or 'tv'
    String? fallbackLink,
  }) {
    // Provider IDs from TMDB (common ones):
    // Netflix: 8
    // Amazon Prime Video: 9, 119 (Prime Video, Amazon Video)
    // Disney Plus: 337
    // HBO Max: 384
    // Hulu: 15
    // Apple TV Plus: 350
    // Paramount Plus: 531

    switch (providerId) {
      case 8: // Netflix
        // Netflix deep link: nflx://www.netflix.com/title/search?q={title}
        // We use search since we don't have Netflix IDs
        final encodedTitle = Uri.encodeComponent(title);
        return 'nflx://www.netflix.com/search?q=$encodedTitle';

      case 9: // Amazon Prime Video
      case 119: // Amazon Video
        // Amazon deep link for Prime Video
        final encodedTitle = Uri.encodeComponent(title);
        return 'aiv://webapi/search?searchPhrase=$encodedTitle';

      case 337: // Disney Plus
        // Disney+ search - note: requires exact content ID for direct links
        final encodedTitle = Uri.encodeComponent(title);
        return 'disneyplus://search/$encodedTitle';

      case 15: // Hulu
        final encodedTitle = Uri.encodeComponent(title);
        return 'hulu://search?query=$encodedTitle';

      case 350: // Apple TV Plus
        // Apple TV deep link
        final encodedTitle = Uri.encodeComponent(title);
        return 'videos://search?term=$encodedTitle';

      case 384: // HBO Max
      case 1899: // Max
        final encodedTitle = Uri.encodeComponent(title);
        return 'max://search?query=$encodedTitle';

      case 531: // Paramount Plus
        final encodedTitle = Uri.encodeComponent(title);
        return 'paramount://search?q=$encodedTitle';

      default:
        // For unknown providers, use the fallback JustWatch link
        return fallbackLink;
    }
  }

  static String? _extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    return dateString.split('-').first;
  }

  // ===== Network/Studio Discovery Methods =====

  /// Hardcoded list of popular TV networks with TMDB IDs
  /// Based on Seerr's NetworkSlider implementation
  static List<Map<String, dynamic>> getNetworksList() {
    return [
      {
        'id': 213,
        'name': 'Netflix',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/wwemzKWzjKYJFfCeiB57q3r4Bcm.png',
      },
      {
        'id': 2739,
        'name': 'Disney+',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/gJ8VX6JSu3ciXHuC2dDGAo2lvwM.png',
      },
      {
        'id': 1024,
        'name': 'Prime Video',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/ifhbNuuVnlwYy5oXA5VIb2YR8AZ.png',
      },
      {
        'id': 2552,
        'name': 'Apple TV+',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/4KAy34EHvRM25Ih8wb82AuGU7zJ.png',
      },
      {
        'id': 453,
        'name': 'Hulu',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/pqUTCleNUiTLAVlelGxUgWn1ELh.png',
      },
      {
        'id': 49,
        'name': 'HBO',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/tuomPhY2UtuPTqqFnKMVHvSb724.png',
      },
      {
        'id': 4330,
        'name': 'Paramount+',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/fi83B1oztoS47xxcemFdPMhIzK.png',
      },
      {
        'id': 3353,
        'name': 'Peacock',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/gIAcGTjKKr0KOHL5s4O36roJ8p7.png',
      },
      {
        'id': 174,
        'name': 'AMC',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/pmvRmATOCaDykE6JrVoeYxlFHw3.png',
      },
      {
        'id': 67,
        'name': 'Showtime',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/Allse9kbjiP6ExaQrnSpIhkurEi.png',
      },
      {
        'id': 318,
        'name': 'Starz',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/8GJjw3HHsAJYwIWKIPBPfqMxlEa.png',
      },
      {
        'id': 71,
        'name': 'The CW',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/ge9hzeaU7nMtQ4PjkFlc68dGAJ9.png',
      },
      {
        'id': 2,
        'name': 'ABC',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/ndAvF4JLsliGreX87jAc9GdjmJY.png',
      },
      {
        'id': 19,
        'name': 'FOX',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/1DSpHrWyOORkL9N2QHX7Adt31mQ.png',
      },
      {
        'id': 6,
        'name': 'NBC',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/o3OedEP0f9mfZr33jz2BfXOUK5.png',
      },
      {
        'id': 16,
        'name': 'CBS',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/nm8d7P7MJNiBLdgIzUK0gkuEA4r.png',
      },
      {
        'id': 4,
        'name': 'BBC One',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/mVn7xESaTNmjBUyUtGNvDQd3CT1.png',
      },
      {
        'id': 56,
        'name': 'Cartoon Network',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/c5OC6oVCg6QP4eqzW6XIq17CQjI.png',
      },
    ];
  }

  /// Get TV shows from a specific network using TMDB discover endpoint
  static Future<List<Map<String, dynamic>>> getTvByNetwork(
    int networkId, {
    int page = 1,
    String? region,
  }) async {
    try {
      String url = '$_baseUrl/discover/tv?api_key=$_apiKey&page=$page';
      url += '&with_networks=$networkId';
      url += '&sort_by=popularity.desc';

      if (region != null) {
        url += '&region=$region';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print('TMDB API Error (TV by Network): ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);
      final results = data['results'] as List? ?? [];

      return results.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'],
          'title': item['name'] ?? 'Unknown',
          'backdrop': getImageUrl(item['backdrop_path']),
          'poster': getImageUrl(item['poster_path'], size: 'w342'),
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
      print('TMDB API Error (TV by Network): $e');
      return [];
    }
  }

  /// Hardcoded list of popular movie studios with TMDB company IDs
  /// Based on Seerr's StudioSlider implementation
  static List<Map<String, dynamic>> getStudiosList() {
    return [
      {
        'id': 2,
        'name': 'Disney',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/wdrCwmRnLFJhEoH8GSfymY85KHT.png',
      },
      {
        'id': 127928,
        'name': '20th Century',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/h0rjX5vjW5r8yEnUBStFarjcLT4.png',
      },
      {
        'id': 34,
        'name': 'Sony Pictures',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/GagSvqWlyPdkFHMfQ3pNq6ix9P.png',
      },
      {
        'id': 174,
        'name': 'Warner Bros.',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/ky0xOc5OrhzkZ1N6KyUxacfQsCk.png',
      },
      {
        'id': 33,
        'name': 'Universal',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/8lvHyhjr8oUKOOy2dKXoALWKdp0.png',
      },
      {
        'id': 4,
        'name': 'Paramount',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/fycMZt242LVjagMByZOLUGbCvv3.png',
      },
      {
        'id': 3,
        'name': 'Pixar',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/1TjvGVDMYsj6JBxOAkUHpPEwLf7.png',
      },
      {
        'id': 521,
        'name': 'DreamWorks',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/kP7t6RwGz2AvvTkvnI1uteEwHet.png',
      },
      {
        'id': 420,
        'name': 'Marvel Studios',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/hUzeosd33nzE5MCNsZxCGEKTXaQ.png',
      },
      {
        'id': 9993,
        'name': 'DC',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/2Tc1P3Ac8M479naPp1kYT3izLS5.png',
      },
      {
        'id': 41077,
        'name': 'A24',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/1ZXsGaFPgrgS6ZZGS37AqD5uU12.png',
      },
      {
        'id': 7505,
        'name': 'Lionsgate',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/cisLn1YAUuptXVBa0xjq7ST9cH0.png',
      },
      {
        'id': 12,
        'name': 'New Line',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/liW0mjvTyLs7UCumaHhx3PpU4VT.png',
      },
      {
        'id': 25,
        'name': 'MGM',
        'logo': 'https://image.tmdb.org/t/p/w300_filter(duotone,ffffff,bababa)/gHKzSkRjLRbHaIqNVHSIjfKUzM5.png',
      },
    ];
  }

  /// Get movies from a specific studio using TMDB discover endpoint
  static Future<List<Map<String, dynamic>>> getMoviesByStudio(
    int studioId, {
    int page = 1,
    String? region,
  }) async {
    try {
      String url = '$_baseUrl/discover/movie?api_key=$_apiKey&page=$page';
      url += '&with_companies=$studioId';
      url += '&sort_by=popularity.desc';

      if (region != null) {
        url += '&region=$region';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print('TMDB API Error (Movies by Studio): ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);
      final results = data['results'] as List? ?? [];

      return results.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'],
          'title': item['title'] ?? 'Unknown',
          'backdrop': getImageUrl(item['backdrop_path']),
          'poster': getImageUrl(item['poster_path'], size: 'w342'),
          'rating': (item['vote_average'] ?? 0).toDouble(),
          'overview': item['overview'] ?? '',
          'releaseDate': item['release_date'],
          'mediaType': 'movie',
          'tmdbId': item['id'],
          'popularity': item['popularity'] ?? 0,
          'inLibrary': false,
        };
      }).toList();
    } catch (e) {
      print('TMDB API Error (Movies by Studio): $e');
      return [];
    }
  }

  /// Get network details from TMDB
  static Future<Map<String, dynamic>?> getNetworkDetails(int networkId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/network/$networkId?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'id': data['id'],
          'name': data['name'],
          'logo': data['logo_path'] != null
              ? getImageUrl(data['logo_path'], size: 'w300')
              : null,
          'originCountry': data['origin_country'],
          'headquarters': data['headquarters'],
        };
      }
      return null;
    } catch (e) {
      print('TMDB API Error (Network Details): $e');
      return null;
    }
  }

  // ===== Genre Discovery Methods =====

  /// Color map for genre backdrop duotone filter (based on Seerr's genreColorMap)
  static const Map<int, List<String>> genreColorMap = {
    0: ['1F2937', 'D1D5DB'], // Default black
    28: ['991B1B', 'FCA5A5'], // Action - red
    12: ['480c8b', 'a96bef'], // Adventure - darkpurple
    16: ['032541', '01b4e4'], // Animation - blue
    35: ['92400E', 'FCD34D'], // Comedy - orange
    80: ['1F2937', '2864d2'], // Crime - darkblue
    99: ['065F46', '6EE7B7'], // Documentary - lightgreen
    18: ['9D174D', 'F9A8D4'], // Drama - pink
    10751: ['777e0d', 'e4ed55'], // Family - yellow
    14: ['1F2937', '60A5FA'], // Fantasy - lightblue
    36: ['92400E', 'FCD34D'], // History - orange
    27: ['1F2937', 'D1D5DB'], // Horror - black
    10402: ['032541', '01b4e4'], // Music - blue
    9648: ['5B21B6', 'C4B5FD'], // Mystery - purple
    10749: ['9D174D', 'F9A8D4'], // Romance - pink
    878: ['1F2937', '60A5FA'], // Science Fiction - lightblue
    10770: ['991B1B', 'FCA5A5'], // TV Movie - red
    53: ['1F2937', 'D1D5DB'], // Thriller - black
    10752: ['1F2937', 'F87171'], // War - darkred
    37: ['92400E', 'FCD34D'], // Western - orange
    10759: ['480c8b', 'a96bef'], // Action & Adventure - darkpurple
    10762: ['032541', '01b4e4'], // Kids - blue
    10763: ['1F2937', 'D1D5DB'], // News - black
    10764: ['552c01', 'd47c1d'], // Reality - darkorange
    10765: ['1F2937', '60A5FA'], // Sci-Fi & Fantasy - lightblue
    10766: ['9D174D', 'F9A8D4'], // Soap - pink
    10767: ['065F46', '6EE7B7'], // Talk - lightgreen
    10768: ['1F2937', 'F87171'], // War & Politics - darkred
  };

  /// Get movie genres list from TMDB (cached for 24 hours)
  static Future<List<Map<String, dynamic>>> getMovieGenres() async {
    // Return cached data if valid
    if (_movieGenresCache != null &&
        _movieGenresCacheTime != null &&
        DateTime.now().difference(_movieGenresCacheTime!) < _genresCacheDuration) {
      return _movieGenresCache!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey'),
      );

      if (response.statusCode != 200) {
        print('TMDB API Error (Movie Genres): ${response.statusCode}');
        return _movieGenresCache ?? [];
      }

      final data = json.decode(response.body);
      final genres = data['genres'] as List? ?? [];

      // Fetch backdrops for each genre in parallel for speed
      final futures = genres.map((genre) async {
        final genreId = genre['id'] as int;
        final genreName = genre['name'] as String;

        // Get movies from this genre to collect backdrops
        final moviesResponse = await http.get(
          Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=$genreId&sort_by=popularity.desc&page=1'),
        );

        final List<String> backdrops = [];
        if (moviesResponse.statusCode == 200) {
          final moviesData = json.decode(moviesResponse.body);
          final results = moviesData['results'] as List? ?? [];
          for (final movie in results) {
            if (movie['backdrop_path'] != null) {
              backdrops.add(movie['backdrop_path'] as String);
            }
          }
        }

        final backdropPath = backdrops.length > 4 ? backdrops[4] : (backdrops.isNotEmpty ? backdrops[0] : null);

        // Use plain backdrop without duotone filter
        final backdropUrl = backdropPath != null
            ? 'https://image.tmdb.org/t/p/w300$backdropPath'
            : null;

        return {
          'id': genreId,
          'name': genreName,
          'backdrop': backdropUrl,
        };
      });

      final genresWithBackdrops = await Future.wait(futures);
      final sortedGenres = genresWithBackdrops.toList()
        ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

      // Update cache
      _movieGenresCache = sortedGenres;
      _movieGenresCacheTime = DateTime.now();

      return sortedGenres;
    } catch (e) {
      print('TMDB API Error (Movie Genres): $e');
      return _movieGenresCache ?? [];
    }
  }

  /// Get TV genres list from TMDB (cached for 24 hours)
  static Future<List<Map<String, dynamic>>> getTvGenres() async {
    // Return cached data if valid
    if (_tvGenresCache != null &&
        _tvGenresCacheTime != null &&
        DateTime.now().difference(_tvGenresCacheTime!) < _genresCacheDuration) {
      return _tvGenresCache!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/genre/tv/list?api_key=$_apiKey'),
      );

      if (response.statusCode != 200) {
        print('TMDB API Error (TV Genres): ${response.statusCode}');
        return _tvGenresCache ?? [];
      }

      final data = json.decode(response.body);
      final genres = data['genres'] as List? ?? [];

      // Fetch backdrops for each genre in parallel for speed
      final futures = genres.map((genre) async {
        final genreId = genre['id'] as int;
        final genreName = genre['name'] as String;

        // Get shows from this genre to collect backdrops
        final showsResponse = await http.get(
          Uri.parse('$_baseUrl/discover/tv?api_key=$_apiKey&with_genres=$genreId&sort_by=popularity.desc&page=1'),
        );

        final List<String> backdrops = [];
        if (showsResponse.statusCode == 200) {
          final showsData = json.decode(showsResponse.body);
          final results = showsData['results'] as List? ?? [];
          for (final show in results) {
            if (show['backdrop_path'] != null) {
              backdrops.add(show['backdrop_path'] as String);
            }
          }
        }

        final backdropPath = backdrops.length > 4 ? backdrops[4] : (backdrops.isNotEmpty ? backdrops[0] : null);

        // Use plain backdrop without duotone filter
        final backdropUrl = backdropPath != null
            ? 'https://image.tmdb.org/t/p/w300$backdropPath'
            : null;

        return {
          'id': genreId,
          'name': genreName,
          'backdrop': backdropUrl,
        };
      });

      final genresWithBackdrops = await Future.wait(futures);
      final sortedGenres = genresWithBackdrops.toList()
        ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

      // Update cache
      _tvGenresCache = sortedGenres;
      _tvGenresCacheTime = DateTime.now();

      return sortedGenres;
    } catch (e) {
      print('TMDB API Error (TV Genres): $e');
      return _tvGenresCache ?? [];
    }
  }

  /// Get movies by genre using TMDB discover endpoint
  static Future<List<Map<String, dynamic>>> getMoviesByGenre(
    int genreId, {
    int page = 1,
    String? region,
  }) async {
    try {
      String url = '$_baseUrl/discover/movie?api_key=$_apiKey&page=$page';
      url += '&with_genres=$genreId';
      url += '&sort_by=popularity.desc';

      if (region != null) {
        url += '&region=$region';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print('TMDB API Error (Movies by Genre): ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);
      final results = data['results'] as List? ?? [];

      return results.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'],
          'title': item['title'] ?? 'Unknown',
          'backdrop': getImageUrl(item['backdrop_path']),
          'poster': getImageUrl(item['poster_path'], size: 'w342'),
          'rating': (item['vote_average'] ?? 0).toDouble(),
          'overview': item['overview'] ?? '',
          'releaseDate': item['release_date'],
          'mediaType': 'movie',
          'tmdbId': item['id'],
          'popularity': item['popularity'] ?? 0,
          'inLibrary': false,
        };
      }).toList();
    } catch (e) {
      print('TMDB API Error (Movies by Genre): $e');
      return [];
    }
  }

  /// Get TV shows by genre using TMDB discover endpoint
  static Future<List<Map<String, dynamic>>> getTvByGenre(
    int genreId, {
    int page = 1,
    String? region,
  }) async {
    try {
      String url = '$_baseUrl/discover/tv?api_key=$_apiKey&page=$page';
      url += '&with_genres=$genreId';
      url += '&sort_by=popularity.desc';

      if (region != null) {
        url += '&region=$region';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print('TMDB API Error (TV by Genre): ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);
      final results = data['results'] as List? ?? [];

      return results.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'],
          'title': item['name'] ?? 'Unknown',
          'backdrop': getImageUrl(item['backdrop_path']),
          'poster': getImageUrl(item['poster_path'], size: 'w342'),
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
      print('TMDB API Error (TV by Genre): $e');
      return [];
    }
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
            'https://image.tmdb.org/t/p/w342/d8Ryb8AunYAuycVKDp5HpdWPKgC.jpg',
        'rating': 7.8,
        'tmdbId': 939243,
        'mediaType': 'movie',
        'inLibrary': false,
      },
      {
        'id': 1184918,
        'title': 'The Wild Robot',
        'poster':
            'https://image.tmdb.org/t/p/w342/wTnV3PCVW5O92JMrFvvrRcV39RU.jpg',
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
