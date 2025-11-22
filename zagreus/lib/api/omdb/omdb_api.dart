import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model for Rotten Tomatoes ratings from OMDb API
class RottenTomatoesRatings {
  final String? tomatometer;
  final String? audienceScore;
  final int? tomatoMeterValue;
  final int? audienceScoreValue;

  RottenTomatoesRatings({
    this.tomatometer,
    this.audienceScore,
    this.tomatoMeterValue,
    this.audienceScoreValue,
  });

  factory RottenTomatoesRatings.fromJson(Map<String, dynamic> json) {
    // Parse tomatometer from Ratings array
    String? tomatometer;
    int? tomatoMeterValue;
    String? audienceScore;
    int? audienceScoreValue;

    final ratings = json['Ratings'] as List?;
    if (ratings != null) {
      for (final rating in ratings) {
        if (rating['Source'] == 'Rotten Tomatoes') {
          tomatometer = rating['Value'] as String?;
          // Extract numeric value (e.g., "85%" -> 85)
          if (tomatometer != null && tomatometer.isNotEmpty) {
            tomatoMeterValue = int.tryParse(tomatometer.replaceAll('%', ''));
          }
        }
      }
    }

    // Try to get audience score from the old tomato fields if available
    // Note: OMDb may not always return these fields
    final tomatoUserRating = json['tomatoUserRating'] as String?;
    if (tomatoUserRating != null && tomatoUserRating != 'N/A') {
      // tomatoUserRating is usually out of 5, convert to percentage
      final rating = double.tryParse(tomatoUserRating);
      if (rating != null) {
        audienceScoreValue = ((rating / 5) * 100).round();
        audienceScore = '$audienceScoreValue%';
      }
    }

    return RottenTomatoesRatings(
      tomatometer: tomatometer,
      audienceScore: audienceScore,
      tomatoMeterValue: tomatoMeterValue,
      audienceScoreValue: audienceScoreValue,
    );
  }

  bool get hasRatings =>
      tomatoMeterValue != null || audienceScoreValue != null;
}

/// OMDb API client for fetching Rotten Tomatoes ratings
class OMDbApi {
  static const String _baseUrl = 'http://www.omdbapi.com';
  static const String _apiKey = '84a211de';

  /// Fetch Rotten Tomatoes ratings for a movie by IMDb ID
  static Future<RottenTomatoesRatings?> getRottenTomatoesRatings(
      String? imdbId) async {
    if (imdbId == null || imdbId.isEmpty) {
      return null;
    }

    try {
      // Use tomatoes=true to get RT ratings
      final response = await http.get(
        Uri.parse('$_baseUrl/?i=$imdbId&apikey=$_apiKey&tomatoes=true'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if the API returned an error
        if (data['Response'] == 'False') {
          print('OMDb API Error: ${data['Error']}');
          return null;
        }

        return RottenTomatoesRatings.fromJson(data);
      }

      print('OMDb API HTTP Error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error fetching Rotten Tomatoes ratings: $e');
      return null;
    }
  }
}
