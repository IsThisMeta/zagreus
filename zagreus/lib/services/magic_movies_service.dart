import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/hmac_encryption_service.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum MagicMoviesError {
  noMegaOrUltra,
  alreadyGenerating,
  fetchFailed,
  notSynced,
  unknown,
}

class MagicMoviesResult {
  final bool success;
  final MagicMoviesError? error;
  final String? errorMessage;
  final String? sectionTitle;
  final String? sectionTheme;
  final List<MagicMovie>? recommendations;
  final DateTime? generatedAt;
  final DateTime? nextGenerationAt;

  MagicMoviesResult.success({
    required this.sectionTitle,
    required this.sectionTheme,
    required this.recommendations,
    this.generatedAt,
    this.nextGenerationAt,
  })  : success = true,
        error = null,
        errorMessage = null;

  MagicMoviesResult.failure(this.error, [this.errorMessage])
      : success = false,
        sectionTitle = null,
        sectionTheme = null,
        recommendations = null,
        generatedAt = null,
        nextGenerationAt = null;
}

class MagicMovie {
  final String title;
  final int year;
  final String? director;
  final List<String> genres;
  final String reason;
  final int matchScore;
  final int? tmdbId;
  final String? posterPath;

  MagicMovie({
    required this.title,
    required this.year,
    this.director,
    required this.genres,
    required this.reason,
    required this.matchScore,
    this.tmdbId,
    this.posterPath,
  });

  String? get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  factory MagicMovie.fromJson(Map<String, dynamic> json) {
    return MagicMovie(
      title: json['title'] as String,
      year: json['year'] as int,
      director: json['director'] as String?,
      genres: (json['genres'] as List<dynamic>).cast<String>(),
      reason: json['reason'] as String,
      matchScore: json['match_score'] as int,
      tmdbId: json['tmdb_id'] as int?,
      posterPath: json['poster_path'] as String?,
    );
  }
}

/// Service for managing Magic Movies AI-powered recommendations
/// Magic Movies are dynamically themed film recommendations generated weekly by AI
/// Available to Mega (GPT-5-mini) and Ultra (GPT-5.1) subscribers
class MagicMoviesService {
  static final MagicMoviesService _instance = MagicMoviesService._internal();
  factory MagicMoviesService() => _instance;
  MagicMoviesService._internal();

  static const String _baseUrl = 'https://z-assistant.fly.dev';

  DateTime? _lastFetchTime;
  String? _cachedSectionTitle;
  String? _cachedSectionTheme;
  List<MagicMovie>? _cachedRecommendations;
  bool _isGenerating = false;

  String? get sectionTitle => _cachedSectionTitle;
  String? get sectionTheme => _cachedSectionTheme;
  List<MagicMovie>? get recommendations => _cachedRecommendations;
  bool get hasRecommendations =>
      _cachedRecommendations != null && _cachedRecommendations!.isNotEmpty;
  bool get isGenerating => _isGenerating;

  /// Get the current subscription tier for Magic Movies ("mega" or "ultra")
  String get _subscriptionTier {
    if (ZagreusUltra.isEnabled) return 'ultra';
    if (ZagreusMega.isEnabled) return 'mega';
    return 'none';
  }

  /// Check if recommendations need regeneration (> 7 days old or never generated)
  /// Pass existing result to avoid redundant API calls
  bool needsRegeneration({MagicMoviesResult? existingResult}) {
    if (!ZagreusMega.isEnabled) return false;

    if (existingResult == null) return true;
    if (!existingResult.success || existingResult.nextGenerationAt == null) {
      return true; // No data or error, should try to generate
    }

    // Check if it's time for next generation
    return DateTime.now().isAfter(existingResult.nextGenerationAt!);
  }

  /// Fetch cached Magic Movies recommendations from backend
  Future<MagicMoviesResult> fetchRecommendations() async {
    print('\n═══════════════════════════════════════');
    print('🎬✨ MAGIC MOVIES FETCH STARTED');
    print('═══════════════════════════════════════');

    // Mega or Ultra required
    if (!ZagreusMega.isEnabled) {
      print('❌ FETCH BLOCKED: Mega or Ultra subscription required');
      return MagicMoviesResult.failure(
        MagicMoviesError.noMegaOrUltra,
        'Mega or Ultra subscription required for Magic Movies',
      );
    }

    try {
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = HmacEncryptionService().hmacKey;

      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations/magic-movies'),
        headers: {
          'X-Device-Id': deviceId,
          'X-HMAC-Signature': hmacKey,
          'X-Subscription-Tier': _subscriptionTier,
        },
      );

      print('📡 Magic Movies response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final recommendationsData = data['recommendations'] as List<dynamic>?;
        final sectionTitle = data['section_title'] as String?;
        final sectionTheme = data['section_theme'] as String?;

        if (recommendationsData == null || recommendationsData.isEmpty) {
          print('📭 No recommendations yet');
          _cachedRecommendations = [];
          _cachedSectionTitle = null;
          _cachedSectionTheme = null;
          return MagicMoviesResult.success(
            sectionTitle: 'Magic Movies',
            sectionTheme: 'AI-curated themed collections',
            recommendations: [],
          );
        }

        final recommendations = recommendationsData
            .map((item) => MagicMovie.fromJson(item as Map<String, dynamic>))
            .toList();

        _cachedRecommendations = recommendations;
        _cachedSectionTitle = sectionTitle ?? 'Magic Movies';
        _cachedSectionTheme = sectionTheme ?? 'AI-curated themed collections';
        _lastFetchTime = DateTime.now();
        _isGenerating = data['is_generating'] as bool? ?? false;

        final generatedAt = data['generated_at'] != null
            ? DateTime.parse(data['generated_at'] as String)
            : null;
        final nextGenerationAt = data['next_generation_at'] != null
            ? DateTime.parse(data['next_generation_at'] as String)
            : null;

        print('✅ Fetched ${recommendations.length} magic movie recommendations');
        print('   Theme: $_cachedSectionTitle');
        print('   Generated: ${generatedAt?.toLocal()}');
        print('   Next generation: ${nextGenerationAt?.toLocal()}');
        print('═══════════════════════════════════════\n');

        return MagicMoviesResult.success(
          sectionTitle: _cachedSectionTitle!,
          sectionTheme: _cachedSectionTheme!,
          recommendations: recommendations,
          generatedAt: generatedAt,
          nextGenerationAt: nextGenerationAt,
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        return MagicMoviesResult.failure(
          MagicMoviesError.fetchFailed,
          'Failed to fetch: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Magic Movies fetch error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      return MagicMoviesResult.failure(MagicMoviesError.unknown, e.toString());
    }
  }

  /// Generate new Magic Movies recommendations
  /// This triggers the backend to analyze library + watch history with AI
  /// Mega users get GPT-5-mini, Ultra users get GPT-5.1
  Future<MagicMoviesResult> generateRecommendations({bool force = false}) async {
    print('\n═══════════════════════════════════════');
    print('🎬✨ MAGIC MOVIES GENERATION STARTED');
    print('═══════════════════════════════════════');
    print('Force: $force');
    print('Tier: $_subscriptionTier');

    // Mega or Ultra required
    if (!ZagreusMega.isEnabled) {
      print('❌ GENERATION BLOCKED: Mega or Ultra subscription required');
      return MagicMoviesResult.failure(
        MagicMoviesError.noMegaOrUltra,
        'Mega or Ultra subscription required for Magic Movies',
      );
    }

    if (_isGenerating && !force) {
      print('⏳ Already generating...');
      return MagicMoviesResult.failure(
        MagicMoviesError.alreadyGenerating,
        'Magic Movies are already being generated',
      );
    }

    try {
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = HmacEncryptionService().hmacKey;

      _isGenerating = true;

      final response = await http.post(
        Uri.parse('$_baseUrl/recommendations/magic-movies/generate'),
        headers: {
          'X-Device-Id': deviceId,
          'X-HMAC-Signature': hmacKey,
          'X-Subscription-Tier': _subscriptionTier,
        },
      );

      print('📡 Generation response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'up_to_date') {
          print('✅ Magic Movies are already up to date');
          print('   Age: ${data['age_days']} days');
          _isGenerating = false;
          return fetchRecommendations(); // Return existing
        }

        print('✅ Generation started successfully');
        print('   Duration: ${data['generation_duration_ms']}ms');
        print('   Count: ${data['recommendations_count']}');

        // Fetch the fresh recommendations
        _isGenerating = false;
        return await fetchRecommendations();
      } else if (response.statusCode == 409) {
        print('⏳ Generation already in progress');
        _isGenerating = false;
        return MagicMoviesResult.failure(
          MagicMoviesError.alreadyGenerating,
          'Generation already in progress',
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        _isGenerating = false;
        return MagicMoviesResult.failure(
          MagicMoviesError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        _isGenerating = false;
        return MagicMoviesResult.failure(
          MagicMoviesError.unknown,
          'Generation failed: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Magic Movies generation error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      _isGenerating = false;
      return MagicMoviesResult.failure(MagicMoviesError.unknown, e.toString());
    }
  }

  /// Convenience method to fetch or generate as needed
  Future<MagicMoviesResult> syncIfNeeded() async {
    // First try to fetch existing - do this ONCE
    final fetchResult = await fetchRecommendations();

    if (fetchResult.success && fetchResult.recommendations!.isNotEmpty) {
      // Check if regeneration is needed based on the result we just fetched
      final needsRegen = needsRegeneration(existingResult: fetchResult);
      if (!needsRegen) {
        return fetchResult; // All good, return what we already have
      }
    }

    // Generate new recommendations
    return await generateRecommendations();
  }
}
