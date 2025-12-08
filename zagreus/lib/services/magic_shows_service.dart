import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/hmac_encryption_service.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum MagicShowsError {
  noMegaOrUltra,
  alreadyGenerating,
  fetchFailed,
  notSynced,
  unknown,
}

class MagicShowsResult {
  final bool success;
  final MagicShowsError? error;
  final String? errorMessage;
  final String? sectionTitle;
  final String? sectionTheme;
  final List<MagicShow>? recommendations;
  final DateTime? generatedAt;
  final DateTime? nextGenerationAt;

  MagicShowsResult.success({
    required this.sectionTitle,
    required this.sectionTheme,
    required this.recommendations,
    this.generatedAt,
    this.nextGenerationAt,
  })  : success = true,
        error = null,
        errorMessage = null;

  MagicShowsResult.failure(this.error, [this.errorMessage])
      : success = false,
        sectionTitle = null,
        sectionTheme = null,
        recommendations = null,
        generatedAt = null,
        nextGenerationAt = null;
}

class MagicShow {
  final String title;
  final int year;
  final List<String> genres;
  final String reason;
  final int matchScore;
  final int? tmdbId;
  final String? posterPath;
  final int? seasons;

  MagicShow({
    required this.title,
    required this.year,
    required this.genres,
    required this.reason,
    required this.matchScore,
    this.tmdbId,
    this.posterPath,
    this.seasons,
  });

  String? get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  factory MagicShow.fromJson(Map<String, dynamic> json) {
    return MagicShow(
      title: json['title'] as String,
      year: json['year'] as int,
      genres: (json['genres'] as List<dynamic>).cast<String>(),
      reason: json['reason'] as String,
      matchScore: json['match_score'] as int,
      tmdbId: json['tmdb_id'] as int?,
      posterPath: json['poster_path'] as String?,
      seasons: json['seasons'] as int?,
    );
  }
}

/// Service for managing Magic Shows AI-powered recommendations
/// Magic Shows are dynamically themed TV recommendations generated weekly by AI
/// Available to Mega (GPT-5-mini) and Ultra (GPT-5.1) subscribers
class MagicShowsService {
  static final MagicShowsService _instance = MagicShowsService._internal();
  factory MagicShowsService() => _instance;
  MagicShowsService._internal();

  static const String _baseUrl = 'https://z-assistant.fly.dev';

  final Map<String, DateTime?> _lastFetchTime = {};
  final Map<String, String?> _cachedSectionTitle = {};
  final Map<String, String?> _cachedSectionTheme = {};
  final Map<String, List<MagicShow>?> _cachedRecommendations = {};
  final Map<String, bool> _isGenerating = {};

  String? sectionTitle(String instanceKey) => _cachedSectionTitle[instanceKey];
  String? sectionTheme(String instanceKey) => _cachedSectionTheme[instanceKey];
  List<MagicShow>? recommendations(String instanceKey) =>
      _cachedRecommendations[instanceKey];
  bool hasRecommendations(String instanceKey) =>
      (_cachedRecommendations[instanceKey]?.isNotEmpty ?? false);
  bool isGenerating(String instanceKey) => _isGenerating[instanceKey] ?? false;

  /// Get the current subscription tier for Magic Shows ("mega" or "ultra")
  String get _subscriptionTier {
    if (ZagreusUltra.isEnabled) return 'ultra';
    if (ZagreusMega.isEnabled) return 'mega';
    return 'none';
  }

  /// Check if recommendations need regeneration
  bool needsRegeneration({MagicShowsResult? existingResult}) {
    if (!ZagreusMega.isEnabled) return false;

    if (existingResult == null) return true;
    if (!existingResult.success || existingResult.nextGenerationAt == null) {
      return true;
    }

    return DateTime.now().isAfter(existingResult.nextGenerationAt!);
  }

  /// Fetch cached Magic Shows recommendations from backend
  Future<MagicShowsResult> fetchRecommendations({
    required String profileKey,
    required String instanceKey,
  }) async {
    print('\n═══════════════════════════════════════');
    print('📺✨ MAGIC SHOWS FETCH STARTED');
    print('═══════════════════════════════════════');

    if (!ZagreusMega.isEnabled) {
      print('❌ FETCH BLOCKED: Mega or Ultra subscription required');
      return MagicShowsResult.failure(
        MagicShowsError.noMegaOrUltra,
        'Mega or Ultra subscription required for Magic Shows',
      );
    }

    try {
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = HmacEncryptionService().hmacKey;

      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations/magic-shows'),
        headers: {
          'X-Device-Id': deviceId,
          'X-HMAC-Signature': hmacKey,
          'X-Subscription-Tier': _subscriptionTier,
          'X-Profile-Key': profileKey,
          'X-Instance-Key': instanceKey,
        },
      );

      print('📡 Magic Shows response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final recommendationsData = data['recommendations'] as List<dynamic>?;
        final sectionTitle = data['section_title'] as String?;
        final sectionTheme = data['section_theme'] as String?;

        if (recommendationsData == null || recommendationsData.isEmpty) {
          print('📭 No recommendations yet');
          _cachedRecommendations[instanceKey] = [];
          _cachedSectionTitle[instanceKey] = null;
          _cachedSectionTheme[instanceKey] = null;
          return MagicShowsResult.success(
            sectionTitle: 'Magic Shows',
            sectionTheme: 'AI-curated themed collections',
            recommendations: [],
          );
        }

        final recommendations = recommendationsData
            .map((item) => MagicShow.fromJson(item as Map<String, dynamic>))
            .toList();

        _cachedRecommendations[instanceKey] = recommendations;
        _cachedSectionTitle[instanceKey] =
            sectionTitle ?? 'Magic Shows';
        _cachedSectionTheme[instanceKey] =
            sectionTheme ?? 'AI-curated themed collections';
        _lastFetchTime[instanceKey] = DateTime.now();
        _isGenerating[instanceKey] = data['is_generating'] as bool? ?? false;

        final generatedAt = data['generated_at'] != null
            ? DateTime.parse(data['generated_at'] as String)
            : null;
        final nextGenerationAt = data['next_generation_at'] != null
            ? DateTime.parse(data['next_generation_at'] as String)
            : null;

        print('✅ Fetched ${recommendations.length} magic show recommendations');
        print('   Theme: $_cachedSectionTitle');
        print('   Generated: ${generatedAt?.toLocal()}');
        print('   Next generation: ${nextGenerationAt?.toLocal()}');
        print('═══════════════════════════════════════\n');

        return MagicShowsResult.success(
          sectionTitle: _cachedSectionTitle!,
          sectionTheme: _cachedSectionTheme!,
          recommendations: recommendations,
          generatedAt: generatedAt,
          nextGenerationAt: nextGenerationAt,
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        return MagicShowsResult.failure(
          MagicShowsError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        return MagicShowsResult.failure(
          MagicShowsError.fetchFailed,
          'Failed to fetch: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Magic Shows fetch error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      return MagicShowsResult.failure(MagicShowsError.unknown, e.toString());
    }
  }

  /// Generate new Magic Shows recommendations
  Future<MagicShowsResult> generateRecommendations({
    required String profileKey,
    required String instanceKey,
    bool force = false,
  }) async {
    print('\n═══════════════════════════════════════');
    print('📺✨ MAGIC SHOWS GENERATION STARTED');
    print('═══════════════════════════════════════');
    print('Force: $force');
    print('Tier: $_subscriptionTier');

    if (!ZagreusMega.isEnabled) {
      print('❌ GENERATION BLOCKED: Mega or Ultra subscription required');
      return MagicShowsResult.failure(
        MagicShowsError.noMegaOrUltra,
        'Mega or Ultra subscription required for Magic Shows',
      );
    }

    if ((_isGenerating[instanceKey] ?? false) && !force) {
      print('⏳ Already generating...');
      return MagicShowsResult.failure(
        MagicShowsError.alreadyGenerating,
        'Magic Shows are already being generated',
      );
    }

    try {
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = HmacEncryptionService().hmacKey;

      _isGenerating[instanceKey] = true;

      final response = await http.post(
        Uri.parse('$_baseUrl/recommendations/magic-shows/generate'),
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
          print('✅ Magic Shows are already up to date');
          print('   Age: ${data['age_days']} days');
          _isGenerating[instanceKey] = false;
          return fetchRecommendations(
            profileKey: profileKey,
            instanceKey: instanceKey,
          );
        }

        print('✅ Generation started successfully');
        print('   Duration: ${data['generation_duration_ms']}ms');
        print('   Count: ${data['recommendations_count']}');

        _isGenerating[instanceKey] = false;
        return await fetchRecommendations(
          profileKey: profileKey,
          instanceKey: instanceKey,
        );
      } else if (response.statusCode == 409) {
        print('⏳ Generation already in progress');
        _isGenerating[instanceKey] = false;
        return MagicShowsResult.failure(
          MagicShowsError.alreadyGenerating,
          'Generation already in progress',
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        _isGenerating[instanceKey] = false;
        return MagicShowsResult.failure(
          MagicShowsError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        _isGenerating[instanceKey] = false;
        return MagicShowsResult.failure(
          MagicShowsError.unknown,
          'Generation failed: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Magic Shows generation error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      _isGenerating[instanceKey] = false;
      return MagicShowsResult.failure(MagicShowsError.unknown, e.toString());
    }
  }

  /// Convenience method to fetch or generate as needed
  Future<MagicShowsResult> syncIfNeeded({
    required String profileKey,
    required String instanceKey,
  }) async {
    final fetchResult = await fetchRecommendations(
      profileKey: profileKey,
      instanceKey: instanceKey,
    );

    if (fetchResult.success && fetchResult.recommendations!.isNotEmpty) {
      final needsRegen = needsRegeneration(existingResult: fetchResult);
      if (!needsRegen) {
        return fetchResult;
      }
    }

    return await generateRecommendations(
      profileKey: profileKey,
      instanceKey: instanceKey,
    );
  }
}
