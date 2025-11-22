import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model for movie ratings from OMDb API
class MovieRatings {
  final String? imdbRating;
  final String? imdbVotes;
  final String? rottenTomatoes;
  final String? metacritic;

  MovieRatings({
    this.imdbRating,
    this.imdbVotes,
    this.rottenTomatoes,
    this.metacritic,
  });

  factory MovieRatings.fromJson(Map<String, dynamic> json) {
    // Parse ratings from Ratings array
    String? rottenTomatoes;
    String? metacritic;

    final ratings = json['Ratings'] as List?;
    if (ratings != null) {
      for (final rating in ratings) {
        final source = rating['Source'] as String?;
        final value = rating['Value'] as String?;

        if (source == 'Rotten Tomatoes') {
          rottenTomatoes = value;
        } else if (source == 'Metacritic') {
          // Metacritic comes as "96/100", extract just the number
          if (value != null && value.contains('/')) {
            metacritic = value.split('/').first;
          }
        }
      }
    }

    // Get IMDb rating
    final imdbRating = json['imdbRating'] as String?;
    final imdbVotes = json['imdbVotes'] as String?;

    return MovieRatings(
      imdbRating: (imdbRating != null && imdbRating != 'N/A') ? imdbRating : null,
      imdbVotes: (imdbVotes != null && imdbVotes != 'N/A') ? imdbVotes : null,
      rottenTomatoes: (rottenTomatoes != null && rottenTomatoes != 'N/A') ? rottenTomatoes : null,
      metacritic: (metacritic != null && metacritic != 'N/A') ? metacritic : null,
    );
  }

  bool get hasRatings =>
      imdbRating != null || rottenTomatoes != null || metacritic != null;
}

/// OMDb API client for fetching Rotten Tomatoes ratings
class OMDbApi {
  static const String _baseUrl = 'http://www.omdbapi.com';
  static const String _apiKey = '84a211de';

  /// Fetch movie ratings (IMDb, Rotten Tomatoes, Metacritic) by IMDb ID
  static Future<MovieRatings?> getMovieRatings(String? imdbId) async {
    if (imdbId == null || imdbId.isEmpty) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/?i=$imdbId&apikey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the API returned an error
        if (data['Response'] == 'False') {
          print('OMDb API Error: ${data['Error']}');
          return null;
        }

        return MovieRatings.fromJson(data);
      }

      print('OMDb API HTTP Error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error fetching movie ratings: $e');
      return null;
    }
  }
}
