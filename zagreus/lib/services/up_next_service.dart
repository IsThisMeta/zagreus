import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/hmac_encryption_service.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum UpNextError {
  noMegaOrUltra,
  alreadyGenerating,
  fetchFailed,
  notSynced,
  unknown,
}

class UpNextResult {
  final bool success;
  final UpNextError? error;
  final String? errorMessage;
  final List<UpNextShow>? recommendations;
  final DateTime? generatedAt;
  final DateTime? nextGenerationAt;

  UpNextResult.success({
    required this.recommendations,
    this.generatedAt,
    this.nextGenerationAt,
  })  : success = true,
        error = null,
        errorMessage = null;

  UpNextResult.failure(this.error, [this.errorMessage])
      : success = false,
        recommendations = null,
        generatedAt = null,
        nextGenerationAt = null;
}

class UpNextShow {
  final String title;
  final int year;
  final List<String> genres;
  final String reason;
  final int popularityScore;
  final int? tmdbId;
  final String? posterPath;
  final int? seasons;

  UpNextShow({
    required this.title,
    required this.year,
    required this.genres,
    required this.reason,
    required this.popularityScore,
    this.tmdbId,
    this.posterPath,
    this.seasons,
  });

  String? get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  factory UpNextShow.fromJson(Map<String, dynamic> json) {
    return UpNextShow(
      title: json['title'] as String,
      year: json['year'] as int,
      genres: (json['genres'] as List<dynamic>).cast<String>(),
      reason: json['reason'] as String,
      popularityScore: json['popularity_score'] as int,
      tmdbId: json['tmdb_id'] as int?,
      posterPath: json['poster_path'] as String?,
      seasons: json['seasons'] as int?,
    );
  }
}

/// Service for managing Up Next AI-powered show recommendations
/// Up Next shows are personalized series recommendations generated weekly by AI
/// Available to Mega (GPT-5-mini) and Ultra (GPT-5.1) subscribers
class UpNextService {
  static final UpNextService _instance = UpNextService._internal();
  factory UpNextService() => _instance;
  UpNextService._internal();

  static const String _baseUrl = 'https://z-assistant.fly.dev';

  final Map<String, DateTime?> _lastFetchTime = {};
  final Map<String, List<UpNextShow>?> _cachedRecommendations = {};
  final Map<String, bool> _isGenerating = {};

  List<UpNextShow>? recommendations(String instanceKey) =>
      _cachedRecommendations[instanceKey];
  bool hasRecommendations(String instanceKey) =>
      (_cachedRecommendations[instanceKey]?.isNotEmpty ?? false);
  bool isGenerating(String instanceKey) => _isGenerating[instanceKey] ?? false;

  /// Get the current subscription tier for Up Next ("mega" or "ultra")
  String get _subscriptionTier {
    if (ZagreusUltra.isEnabled) return 'ultra';
    if (ZagreusMega.isEnabled) return 'mega';
    return 'none';
  }

  /// Check if recommendations need regeneration (> 7 days old or never generated)
  /// Pass existing result to avoid redundant API calls
  bool needsRegeneration({UpNextResult? existingResult}) {
    if (!ZagreusMega.isEnabled) return false;

    if (existingResult == null) return true;
    if (!existingResult.success || existingResult.nextGenerationAt == null) {
      return true; // No data or error, should try to generate
    }

    // Check if it's time for next generation
    return DateTime.now().isAfter(existingResult.nextGenerationAt!);
  }

  /// Fetch cached Up Next recommendations from backend
  Future<UpNextResult> fetchRecommendations({
    required String profileKey,
    required String instanceKey,
  }) async {
    print('\n═══════════════════════════════════════');
    print('📺 UP NEXT FETCH STARTED');
    print('═══════════════════════════════════════');

    // Mega or Ultra required
    if (!ZagreusMega.isEnabled) {
      print('❌ FETCH BLOCKED: Mega or Ultra subscription required');
      return UpNextResult.failure(
        UpNextError.noMegaOrUltra,
        'Mega or Ultra subscription required for Up Next',
      );
    }

    try {
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = HmacEncryptionService().hmacKey;

      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations/up-next'),
        headers: {
          'X-Device-Id': deviceId,
          'X-HMAC-Signature': hmacKey,
          'X-Subscription-Tier': _subscriptionTier,
          'X-Profile-Key': profileKey,
          'X-Instance-Key': instanceKey,
        },
      );

      print('📡 Up Next response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final recommendationsData = data['recommendations'] as List<dynamic>?;

        if (recommendationsData == null || recommendationsData.isEmpty) {
          print('📭 No recommendations yet');
          _cachedRecommendations[instanceKey] = [];
          return UpNextResult.success(recommendations: []);
        }

        final recommendations = recommendationsData
            .map((item) => UpNextShow.fromJson(item as Map<String, dynamic>))
            .toList();

        _cachedRecommendations[instanceKey] = recommendations;
        _lastFetchTime[instanceKey] = DateTime.now();
        _isGenerating[instanceKey] = data['is_generating'] as bool? ?? false;

        final generatedAt = data['generated_at'] != null
            ? DateTime.parse(data['generated_at'] as String)
            : null;
        final nextGenerationAt = data['next_generation_at'] != null
            ? DateTime.parse(data['next_generation_at'] as String)
            : null;

        print('✅ Fetched ${recommendations.length} up next shows');
        print('   Generated: ${generatedAt?.toLocal()}');
        print('   Next generation: ${nextGenerationAt?.toLocal()}');
        print('═══════════════════════════════════════\n');

        return UpNextResult.success(
          recommendations: recommendations,
          generatedAt: generatedAt,
          nextGenerationAt: nextGenerationAt,
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        return UpNextResult.failure(
          UpNextError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        return UpNextResult.failure(
          UpNextError.fetchFailed,
          'Failed to fetch: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Up Next fetch error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      return UpNextResult.failure(UpNextError.unknown, e.toString());
    }
  }

  /// Generate new Up Next recommendations
  /// This triggers the backend to analyze library + watch history with AI
  /// Mega users get GPT-5-mini, Ultra users get GPT-5.1
  Future<UpNextResult> generateRecommendations({
    required String profileKey,
    required String instanceKey,
    bool force = false,
  }) async {
    print('\n═══════════════════════════════════════');
    print('📺 UP NEXT GENERATION STARTED');
    print('═══════════════════════════════════════');
    print('Force: $force');
    print('Tier: $_subscriptionTier');

    // Mega or Ultra required
    if (!ZagreusMega.isEnabled) {
      print('❌ GENERATION BLOCKED: Mega or Ultra subscription required');
      return UpNextResult.failure(
        UpNextError.noMegaOrUltra,
        'Mega or Ultra subscription required for Up Next',
      );
    }

    if ((_isGenerating[instanceKey] ?? false) && !force) {
      print('⏳ Already generating...');
      return UpNextResult.failure(
        UpNextError.alreadyGenerating,
        'Up Next shows are already being generated',
      );
    }

    try {
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = HmacEncryptionService().hmacKey;

      _isGenerating[instanceKey] = true;

      final response = await http.post(
        Uri.parse('$_baseUrl/recommendations/up-next/generate'),
        headers: {
          'X-Device-Id': deviceId,
          'X-HMAC-Signature': hmacKey,
          'X-Subscription-Tier': _subscriptionTier,
          'X-Profile-Key': profileKey,
          'X-Instance-Key': instanceKey,
        },
      );

      print('📡 Generation response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'up_to_date') {
          print('✅ Up Next shows are already up to date');
          print('   Age: ${data['age_days']} days');
          _isGenerating[instanceKey] = false;
          return fetchRecommendations(
            profileKey: profileKey,
            instanceKey: instanceKey,
          ); // Return existing
        }

        print('✅ Generation started successfully');
        print('   Duration: ${data['generation_duration_ms']}ms');
        print('   Count: ${data['recommendations_count']}');

        // Fetch the fresh recommendations
        _isGenerating[instanceKey] = false;
        return await fetchRecommendations(
          profileKey: profileKey,
          instanceKey: instanceKey,
        );
      } else if (response.statusCode == 409) {
        print('⏳ Generation already in progress');
        _isGenerating[instanceKey] = false;
        return UpNextResult.failure(
          UpNextError.alreadyGenerating,
          'Generation already in progress',
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        _isGenerating[instanceKey] = false;
        return UpNextResult.failure(
          UpNextError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        _isGenerating[instanceKey] = false;
        return UpNextResult.failure(
          UpNextError.unknown,
          'Generation failed: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Up Next generation error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      _isGenerating[instanceKey] = false;
      return UpNextResult.failure(UpNextError.unknown, e.toString());
    }
  }

  /// Convenience method to fetch or generate as needed
  Future<UpNextResult> syncIfNeeded({
    required String profileKey,
    required String instanceKey,
  }) async {
    // First try to fetch existing - do this ONCE
    final fetchResult = await fetchRecommendations(
      profileKey: profileKey,
      instanceKey: instanceKey,
    );

    if (fetchResult.success && fetchResult.recommendations!.isNotEmpty) {
      // Check if regeneration is needed based on the result we just fetched
      final needsRegen = needsRegeneration(existingResult: fetchResult);
      if (!needsRegen) {
        return fetchResult; // All good, return what we already have
      }
    }

    // Generate new recommendations
    return await generateRecommendations(
      profileKey: profileKey,
      instanceKey: instanceKey,
    );
  }
}
