import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/hmac_encryption_service.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum DeepCutsError {
  noMegaOrUltra,
  alreadyGenerating,
  fetchFailed,
  notSynced,
  unknown,
}

class DeepCutsResult {
  final bool success;
  final DeepCutsError? error;
  final String? errorMessage;
  final List<DeepCutMovie>? recommendations;
  final DateTime? generatedAt;
  final DateTime? nextGenerationAt;

  DeepCutsResult.success({
    required this.recommendations,
    this.generatedAt,
    this.nextGenerationAt,
  })  : success = true,
        error = null,
        errorMessage = null;

  DeepCutsResult.failure(this.error, [this.errorMessage])
      : success = false,
        recommendations = null,
        generatedAt = null,
        nextGenerationAt = null;
}

class DeepCutMovie {
  final String title;
  final int year;
  final String? director;
  final List<String> genres;
  final String reason;
  final int obscurityScore;
  final int? tmdbId;
  final String? posterPath;

  DeepCutMovie({
    required this.title,
    required this.year,
    this.director,
    required this.genres,
    required this.reason,
    required this.obscurityScore,
    this.tmdbId,
    this.posterPath,
  });

  String? get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  factory DeepCutMovie.fromJson(Map<String, dynamic> json) {
    return DeepCutMovie(
      title: json['title'] as String,
      year: json['year'] as int,
      director: json['director'] as String?,
      genres: (json['genres'] as List<dynamic>).cast<String>(),
      reason: json['reason'] as String,
      obscurityScore: json['obscurity_score'] as int,
      tmdbId: json['tmdb_id'] as int?,
      posterPath: json['poster_path'] as String?,
    );
  }
}

/// Service for managing Deep Cuts AI-powered recommendations
/// Deep Cuts are hidden gem films recommended weekly by AI
/// Available to Mega (GPT-5-mini) and Ultra (GPT-5) subscribers
class DeepCutsService {
  static final DeepCutsService _instance = DeepCutsService._internal();
  factory DeepCutsService() => _instance;
  DeepCutsService._internal();

  static const String _baseUrl = 'https://z-assistant.fly.dev';

  DateTime? _lastFetchTime;
  List<DeepCutMovie>? _cachedRecommendations;
  bool _isGenerating = false;

  List<DeepCutMovie>? get recommendations => _cachedRecommendations;
  bool get hasRecommendations =>
      _cachedRecommendations != null && _cachedRecommendations!.isNotEmpty;
  bool get isGenerating => _isGenerating;

  /// Get the current subscription tier for Deep Cuts ("mega" or "ultra")
  String get _subscriptionTier {
    if (ZagreusUltra.isEnabled) return 'ultra';
    if (ZagreusMega.isEnabled) return 'mega';
    return 'none';
  }

  /// Check if recommendations need regeneration (> 7 days old or never generated)
  Future<bool> needsRegeneration() async {
    if (!ZagreusMega.isEnabled) return false;

    try {
      final result = await fetchRecommendations();
      if (!result.success || result.nextGenerationAt == null) {
        return true; // No data or error, should try to generate
      }

      // Check if it's time for next generation
      return DateTime.now().isAfter(result.nextGenerationAt!);
    } catch (e, stack) {
      ZagLogger().error('Error checking regeneration status', e, stack);
      return false;
    }
  }

  /// Fetch cached Deep Cuts recommendations from backend
  Future<DeepCutsResult> fetchRecommendations() async {
    print('\n═══════════════════════════════════════');
    print('🎬 DEEP CUTS FETCH STARTED');
    print('═══════════════════════════════════════');

    // Mega or Ultra required
    if (!ZagreusMega.isEnabled) {
      print('❌ FETCH BLOCKED: Mega or Ultra subscription required');
      return DeepCutsResult.failure(
        DeepCutsError.noMegaOrUltra,
        'Mega or Ultra subscription required for Deep Cuts',
      );
    }

    try {
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = HmacEncryptionService().hmacKey;

      final response = await http.get(
        Uri.parse('$_baseUrl/deep-cuts'),
        headers: {
          'X-Device-Id': deviceId,
          'X-HMAC-Signature': hmacKey,
          'X-Subscription-Tier': _subscriptionTier,
        },
      );

      print('📡 Deep Cuts response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final recommendationsData = data['recommendations'] as List<dynamic>?;

        if (recommendationsData == null || recommendationsData.isEmpty) {
          print('📭 No recommendations yet');
          _cachedRecommendations = [];
          return DeepCutsResult.success(recommendations: []);
        }

        final recommendations = recommendationsData
            .map((item) => DeepCutMovie.fromJson(item as Map<String, dynamic>))
            .toList();

        _cachedRecommendations = recommendations;
        _lastFetchTime = DateTime.now();
        _isGenerating = data['is_generating'] as bool? ?? false;

        final generatedAt = data['generated_at'] != null
            ? DateTime.parse(data['generated_at'] as String)
            : null;
        final nextGenerationAt = data['next_generation_at'] != null
            ? DateTime.parse(data['next_generation_at'] as String)
            : null;

        print('✅ Fetched ${recommendations.length} deep cuts');
        print('   Generated: ${generatedAt?.toLocal()}');
        print('   Next generation: ${nextGenerationAt?.toLocal()}');
        print('═══════════════════════════════════════\n');

        return DeepCutsResult.success(
          recommendations: recommendations,
          generatedAt: generatedAt,
          nextGenerationAt: nextGenerationAt,
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        return DeepCutsResult.failure(
          DeepCutsError.fetchFailed,
          'Failed to fetch: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Deep Cuts fetch error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      return DeepCutsResult.failure(DeepCutsError.unknown, e.toString());
    }
  }

  /// Generate new Deep Cuts recommendations
  /// This triggers the backend to analyze library + watch history with AI
  /// Mega users get GPT-5-mini, Ultra users get GPT-5
  Future<DeepCutsResult> generateRecommendations({bool force = false}) async {
    print('\n═══════════════════════════════════════');
    print('🎬 DEEP CUTS GENERATION STARTED');
    print('═══════════════════════════════════════');
    print('Force: $force');
    print('Tier: $_subscriptionTier');

    // Mega or Ultra required
    if (!ZagreusMega.isEnabled) {
      print('❌ GENERATION BLOCKED: Mega or Ultra subscription required');
      return DeepCutsResult.failure(
        DeepCutsError.noMegaOrUltra,
        'Mega or Ultra subscription required for Deep Cuts',
      );
    }

    if (_isGenerating && !force) {
      print('⏳ Already generating...');
      return DeepCutsResult.failure(
        DeepCutsError.alreadyGenerating,
        'Deep Cuts are already being generated',
      );
    }

    try {
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = HmacEncryptionService().hmacKey;

      _isGenerating = true;

      final response = await http.post(
        Uri.parse('$_baseUrl/deep-cuts/generate'),
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
          print('✅ Deep Cuts are already up to date');
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
        return DeepCutsResult.failure(
          DeepCutsError.alreadyGenerating,
          'Generation already in progress',
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        _isGenerating = false;
        return DeepCutsResult.failure(
          DeepCutsError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        _isGenerating = false;
        return DeepCutsResult.failure(
          DeepCutsError.unknown,
          'Generation failed: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Deep Cuts generation error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      _isGenerating = false;
      return DeepCutsResult.failure(DeepCutsError.unknown, e.toString());
    }
  }

  /// Convenience method to fetch or generate as needed
  Future<DeepCutsResult> syncIfNeeded() async {
    // First try to fetch existing
    final fetchResult = await fetchRecommendations();

    if (fetchResult.success && fetchResult.recommendations!.isNotEmpty) {
      // Check if regeneration is needed
      final needsRegen = await needsRegeneration();
      if (!needsRegen) {
        return fetchResult; // All good
      }
    }

    // Generate new recommendations
    return await generateRecommendations();
  }
}
