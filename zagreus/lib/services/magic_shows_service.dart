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

  DateTime? _lastFetchTime;
  String? _cachedSectionTitle;
  String? _cachedSectionTheme;
  List<MagicShow>? _cachedRecommendations;
  bool _isGenerating = false;

  String? get sectionTitle => _cachedSectionTitle;
  String? get sectionTheme => _cachedSectionTheme;
  List<MagicShow>? get recommendations => _cachedRecommendations;
  bool get hasRecommendations =>
      _cachedRecommendations != null && _cachedRecommendations!.isNotEmpty;
  bool get isGenerating => _isGenerating;

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
  Future<MagicShowsResult> fetchRecommendations() async {
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
          _cachedRecommendations = [];
          _cachedSectionTitle = null;
          _cachedSectionTheme = null;
          return MagicShowsResult.success(
            sectionTitle: 'Magic Shows',
            sectionTheme: 'AI-curated themed collections',
            recommendations: [],
          );
        }

        final recommendations = recommendationsData
            .map((item) => MagicShow.fromJson(item as Map<String, dynamic>))
            .toList();

        _cachedRecommendations = recommendations;
        _cachedSectionTitle = sectionTitle ?? 'Magic Shows';
        _cachedSectionTheme = sectionTheme ?? 'AI-curated themed collections';
        _lastFetchTime = DateTime.now();
        _isGenerating = data['is_generating'] as bool? ?? false;

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
  Future<MagicShowsResult> generateRecommendations({bool force = false}) async {
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

    if (_isGenerating && !force) {
      print('⏳ Already generating...');
      return MagicShowsResult.failure(
        MagicShowsError.alreadyGenerating,
        'Magic Shows are already being generated',
      );
    }

    try {
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = HmacEncryptionService().hmacKey;

      _isGenerating = true;

      final response = await http.post(
        Uri.parse('$_baseUrl/recommendations/magic-shows/generate'),
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
          print('✅ Magic Shows are already up to date');
          print('   Age: ${data['age_days']} days');
          _isGenerating = false;
          return fetchRecommendations();
        }

        print('✅ Generation started successfully');
        print('   Duration: ${data['generation_duration_ms']}ms');
        print('   Count: ${data['recommendations_count']}');

        _isGenerating = false;
        return await fetchRecommendations();
      } else if (response.statusCode == 409) {
        print('⏳ Generation already in progress');
        _isGenerating = false;
        return MagicShowsResult.failure(
          MagicShowsError.alreadyGenerating,
          'Generation already in progress',
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        _isGenerating = false;
        return MagicShowsResult.failure(
          MagicShowsError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        _isGenerating = false;
        return MagicShowsResult.failure(
          MagicShowsError.unknown,
          'Generation failed: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Magic Shows generation error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      _isGenerating = false;
      return MagicShowsResult.failure(MagicShowsError.unknown, e.toString());
    }
  }

  /// Convenience method to fetch or generate as needed
  Future<MagicShowsResult> syncIfNeeded() async {
    final fetchResult = await fetchRecommendations();

    if (fetchResult.success && fetchResult.recommendations!.isNotEmpty) {
      final needsRegen = needsRegeneration(existingResult: fetchResult);
      if (!needsRegen) {
        return fetchResult;
      }
    }

    return await generateRecommendations();
  }
}
