import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/hmac_encryption_service.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum MagicPeopleError {
  noMegaOrUltra,
  alreadyGenerating,
  fetchFailed,
  notSynced,
  unknown,
}

class MagicPeopleResult {
  final bool success;
  final MagicPeopleError? error;
  final String? errorMessage;
  final String? sectionTitle;
  final String? sectionTheme;
  final List<MagicPerson>? recommendations;
  final DateTime? generatedAt;
  final DateTime? nextGenerationAt;

  MagicPeopleResult.success({
    required this.sectionTitle,
    required this.sectionTheme,
    required this.recommendations,
    this.generatedAt,
    this.nextGenerationAt,
  })  : success = true,
        error = null,
        errorMessage = null;

  MagicPeopleResult.failure(this.error, [this.errorMessage])
      : success = false,
        sectionTitle = null,
        sectionTheme = null,
        recommendations = null,
        generatedAt = null,
        nextGenerationAt = null;
}

class MagicPerson {
  final String name;
  final String knownFor; // e.g., "Acting", "Directing"
  final String reason;
  final int matchScore;
  final int? tmdbId;
  final String? profilePath;

  MagicPerson({
    required this.name,
    required this.knownFor,
    required this.reason,
    required this.matchScore,
    this.tmdbId,
    this.profilePath,
  });

  String? get profileUrl {
    if (profilePath == null || profilePath!.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/w342$profilePath';
  }

  factory MagicPerson.fromJson(Map<String, dynamic> json) {
    return MagicPerson(
      name: json['name'] as String,
      knownFor: json['known_for'] as String? ?? 'Acting',
      reason: json['reason'] as String,
      matchScore: json['match_score'] as int,
      tmdbId: json['tmdb_id'] as int?,
      profilePath: json['profile_path'] as String?,
    );
  }
}

/// Service for managing Magic People AI-powered recommendations
/// Magic People are dynamically themed person recommendations generated weekly by AI
/// Available to Mega (GPT-5-mini) and Ultra (GPT-5.2) subscribers
class MagicPeopleService {
  static final MagicPeopleService _instance = MagicPeopleService._internal();
  factory MagicPeopleService() => _instance;
  MagicPeopleService._internal();

  static const String _baseUrl = 'https://z-assistant.fly.dev';

  DateTime? _lastFetchTime;
  String? _cachedSectionTitle;
  String? _cachedSectionTheme;
  List<MagicPerson>? _cachedRecommendations;
  bool _isGenerating = false;

  String? get sectionTitle => _cachedSectionTitle;
  String? get sectionTheme => _cachedSectionTheme;
  List<MagicPerson>? get recommendations => _cachedRecommendations;
  bool get hasRecommendations =>
      _cachedRecommendations != null && _cachedRecommendations!.isNotEmpty;
  bool get isGenerating => _isGenerating;

  /// Get the current subscription tier for Magic People ("mega" or "ultra")
  String get _subscriptionTier {
    if (ZagreusUltra.isEnabled) return 'ultra';
    if (ZagreusMega.isEnabled) return 'mega';
    return 'none';
  }

  Map<String, String> _buildHeaders({
    String? profileKey,
    String? instanceKey,
  }) {
    final deviceId = DeviceIdService().deviceId;
    final hmacKey = HmacEncryptionService().hmacKey;
    final resolvedProfileKey =
        profileKey ?? ZagreusDatabase.ENABLED_PROFILE.read();
    final resolvedInstanceKey = instanceKey ?? resolvedProfileKey;

    return {
      'X-Device-Id': deviceId,
      'X-HMAC-Signature': hmacKey,
      'X-Profile-Key': resolvedProfileKey,
      'X-Instance-Key': resolvedInstanceKey,
      'X-Subscription-Tier': _subscriptionTier,
    };
  }

  /// Check if recommendations need regeneration (> 7 days old or never generated)
  /// Pass existing result to avoid redundant API calls
  bool needsRegeneration({MagicPeopleResult? existingResult}) {
    if (!ZagreusMega.isEnabled) return false;

    if (existingResult == null) return true;
    if (!existingResult.success || existingResult.nextGenerationAt == null) {
      return true; // No data or error, should try to generate
    }

    // Check if it's time for next generation
    return DateTime.now().isAfter(existingResult.nextGenerationAt!);
  }

  /// Fetch cached Magic People recommendations from backend
  Future<MagicPeopleResult> fetchRecommendations({
    String? profileKey,
    String? instanceKey,
  }) async {
    print('\n═══════════════════════════════════════');
    print('👥✨ MAGIC PEOPLE FETCH STARTED');
    print('═══════════════════════════════════════');

    // Mega or Ultra required
    if (!ZagreusMega.isEnabled) {
      print('❌ FETCH BLOCKED: Mega or Ultra subscription required');
      return MagicPeopleResult.failure(
        MagicPeopleError.noMegaOrUltra,
        'Mega or Ultra subscription required for Magic People',
      );
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations/magic-people'),
        headers: _buildHeaders(
          profileKey: profileKey,
          instanceKey: instanceKey,
        ),
      );

      print('📡 Magic People response: ${response.statusCode}');

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
          return MagicPeopleResult.success(
            sectionTitle: 'Magic People',
            sectionTheme: 'AI-curated person recommendations',
            recommendations: [],
          );
        }

        final recommendations = recommendationsData
            .map((item) => MagicPerson.fromJson(item as Map<String, dynamic>))
            .toList();

        _cachedRecommendations = recommendations;
        _cachedSectionTitle = sectionTitle ?? 'Magic People';
        _cachedSectionTheme = sectionTheme ?? 'AI-curated person recommendations';
        _lastFetchTime = DateTime.now();
        _isGenerating = data['is_generating'] as bool? ?? false;

        final generatedAt = data['generated_at'] != null
            ? DateTime.parse(data['generated_at'] as String)
            : null;
        final nextGenerationAt = data['next_generation_at'] != null
            ? DateTime.parse(data['next_generation_at'] as String)
            : null;

        print('✅ Fetched ${recommendations.length} magic people recommendations');
        print('   Theme: $_cachedSectionTitle');
        print('   Generated: ${generatedAt?.toLocal()}');
        print('   Next generation: ${nextGenerationAt?.toLocal()}');
        print('═══════════════════════════════════════\n');

        return MagicPeopleResult.success(
          sectionTitle: _cachedSectionTitle!,
          sectionTheme: _cachedSectionTheme!,
          recommendations: recommendations,
          generatedAt: generatedAt,
          nextGenerationAt: nextGenerationAt,
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        return MagicPeopleResult.failure(
          MagicPeopleError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        return MagicPeopleResult.failure(
          MagicPeopleError.fetchFailed,
          'Failed to fetch: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Magic People fetch error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      return MagicPeopleResult.failure(MagicPeopleError.unknown, e.toString());
    }
  }

  /// Generate new Magic People recommendations
  /// This triggers the backend to analyze library + watch history with AI
  /// Mega users get GPT-5-mini, Ultra users get GPT-5.2
  Future<MagicPeopleResult> generateRecommendations({
    String? profileKey,
    String? instanceKey,
    bool force = false,
  }) async {
    print('\n═══════════════════════════════════════');
    print('👥✨ MAGIC PEOPLE GENERATION STARTED');
    print('═══════════════════════════════════════');
    print('Force: $force');
    print('Tier: $_subscriptionTier');

    // Mega or Ultra required
    if (!ZagreusMega.isEnabled) {
      print('❌ GENERATION BLOCKED: Mega or Ultra subscription required');
      return MagicPeopleResult.failure(
        MagicPeopleError.noMegaOrUltra,
        'Mega or Ultra subscription required for Magic People',
      );
    }

    if (_isGenerating && !force) {
      print('⏳ Already generating...');
      return MagicPeopleResult.failure(
        MagicPeopleError.alreadyGenerating,
        'Magic People are already being generated',
      );
    }

    try {
      _isGenerating = true;

      final response = await http.post(
        Uri.parse('$_baseUrl/recommendations/magic-people/generate'),
        headers: _buildHeaders(
          profileKey: profileKey,
          instanceKey: instanceKey,
        ),
      );

      print('📡 Generation response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 'up_to_date') {
          print('✅ Magic People are already up to date');
          print('   Age: ${data['age_days']} days');
          _isGenerating = false;
          return fetchRecommendations(
            profileKey: profileKey,
            instanceKey: instanceKey,
          ); // Return existing
        }

        print('✅ Generation started successfully');
        print('   Duration: ${data['generation_duration_ms']}ms');
        print('   Count: ${data['recommendations_count']}');

        // Fetch the fresh recommendations
        _isGenerating = false;
        return await fetchRecommendations(
          profileKey: profileKey,
          instanceKey: instanceKey,
        );
      } else if (response.statusCode == 409) {
        print('⏳ Generation already in progress');
        _isGenerating = false;
        return MagicPeopleResult.failure(
          MagicPeopleError.alreadyGenerating,
          'Generation already in progress',
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        _isGenerating = false;
        return MagicPeopleResult.failure(
          MagicPeopleError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        _isGenerating = false;
        return MagicPeopleResult.failure(
          MagicPeopleError.unknown,
          'Generation failed: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Magic People generation error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      _isGenerating = false;
      return MagicPeopleResult.failure(MagicPeopleError.unknown, e.toString());
    }
  }

  /// Convenience method to fetch or generate as needed
  Future<MagicPeopleResult> syncIfNeeded({
    String? profileKey,
    String? instanceKey,
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
