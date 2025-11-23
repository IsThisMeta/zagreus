import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/hmac_encryption_service.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum MagicMoviesCastCrewError {
  noMegaOrUltra,
  alreadyGenerating,
  fetchFailed,
  notSynced,
  unknown,
}

class MagicMoviesCastCrewResult {
  final bool success;
  final MagicMoviesCastCrewError? error;
  final String? errorMessage;
  final String? sectionTitle;
  final List<FeaturedPerson>? featuredPeople;
  final List<MagicMovieCastCrew>? recommendations;
  final DateTime? generatedAt;
  final DateTime? nextGenerationAt;

  MagicMoviesCastCrewResult.success({
    required this.sectionTitle,
    required this.featuredPeople,
    required this.recommendations,
    this.generatedAt,
    this.nextGenerationAt,
  })  : success = true,
        error = null,
        errorMessage = null;

  MagicMoviesCastCrewResult.failure(this.error, [this.errorMessage])
      : success = false,
        sectionTitle = null,
        featuredPeople = null,
        recommendations = null,
        generatedAt = null,
        nextGenerationAt = null;
}

class FeaturedPerson {
  final String name;
  final String role; // e.g., "Director", "Actor", "Cinematographer"

  FeaturedPerson({
    required this.name,
    required this.role,
  });

  factory FeaturedPerson.fromJson(Map<String, dynamic> json) {
    return FeaturedPerson(
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }
}

class MagicMovieCastCrew {
  final String title;
  final int year;
  final String? director;
  final List<String> genres;
  final String reason;
  final int matchScore;
  final int? tmdbId;
  final String? posterPath;

  MagicMovieCastCrew({
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

  factory MagicMovieCastCrew.fromJson(Map<String, dynamic> json) {
    return MagicMovieCastCrew(
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

/// Service for managing Magic Movies Cast & Crew AI-powered recommendations
/// Features people-based film recommendations generated weekly by AI
/// Available to Mega (GPT-5-mini) and Ultra (GPT-5.1) subscribers
class MagicMoviesCastCrewService {
  static final MagicMoviesCastCrewService _instance = MagicMoviesCastCrewService._internal();
  factory MagicMoviesCastCrewService() => _instance;
  MagicMoviesCastCrewService._internal();

  static const String _baseUrl = 'https://z-assistant.fly.dev';

  DateTime? _lastFetchTime;
  String? _cachedSectionTitle;
  List<FeaturedPerson>? _cachedFeaturedPeople;
  List<MagicMovieCastCrew>? _cachedRecommendations;
  bool _isGenerating = false;

  String? get sectionTitle => _cachedSectionTitle;
  List<FeaturedPerson>? get featuredPeople => _cachedFeaturedPeople;
  List<MagicMovieCastCrew>? get recommendations => _cachedRecommendations;
  bool get hasRecommendations =>
      _cachedRecommendations != null && _cachedRecommendations!.isNotEmpty;
  bool get isGenerating => _isGenerating;

  /// Get the current subscription tier ("mega" or "ultra")
  String get _subscriptionTier {
    if (ZagreusUltra.isEnabled) return 'ultra';
    if (ZagreusMega.isEnabled) return 'mega';
    return 'none';
  }

  /// Check if recommendations need regeneration
  bool needsRegeneration({MagicMoviesCastCrewResult? existingResult}) {
    if (!ZagreusMega.isEnabled) return false;

    if (existingResult == null) return true;
    if (!existingResult.success || existingResult.nextGenerationAt == null) {
      return true;
    }

    return DateTime.now().isAfter(existingResult.nextGenerationAt!);
  }

  /// Fetch cached Magic Movies Cast & Crew recommendations from backend
  Future<MagicMoviesCastCrewResult> fetchRecommendations() async {
    print('\n═══════════════════════════════════════');
    print('🎬👥 MAGIC MOVIES CAST & CREW FETCH STARTED');
    print('═══════════════════════════════════════');

    if (!ZagreusMega.isEnabled) {
      print('❌ FETCH BLOCKED: Mega or Ultra subscription required');
      return MagicMoviesCastCrewResult.failure(
        MagicMoviesCastCrewError.noMegaOrUltra,
        'Mega or Ultra subscription required for Magic Movies Cast & Crew',
      );
    }

    try {
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = HmacEncryptionService().hmacKey;

      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations/magic-movies-cast-crew'),
        headers: {
          'X-Device-Id': deviceId,
          'X-HMAC-Signature': hmacKey,
          'X-Subscription-Tier': _subscriptionTier,
        },
      );

      print('📡 Magic Movies Cast & Crew response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final recommendationsData = data['recommendations'] as List<dynamic>?;
        final sectionTitle = data['section_title'] as String?;
        final featuredPeopleData = data['featured_people'] as List<dynamic>?;

        if (recommendationsData == null || recommendationsData.isEmpty) {
          print('📭 No recommendations yet');
          _cachedRecommendations = [];
          _cachedSectionTitle = null;
          _cachedFeaturedPeople = [];
          return MagicMoviesCastCrewResult.success(
            sectionTitle: 'Magic Movies: Cast & Crew',
            featuredPeople: [],
            recommendations: [],
          );
        }

        final recommendations = recommendationsData
            .map((item) => MagicMovieCastCrew.fromJson(item as Map<String, dynamic>))
            .toList();

        final featuredPeople = featuredPeopleData != null
            ? featuredPeopleData
                .map((item) => FeaturedPerson.fromJson(item as Map<String, dynamic>))
                .toList()
            : <FeaturedPerson>[];

        _cachedRecommendations = recommendations;
        _cachedSectionTitle = sectionTitle ?? 'Magic Movies: Cast & Crew';
        _cachedFeaturedPeople = featuredPeople;
        _lastFetchTime = DateTime.now();
        _isGenerating = data['is_generating'] as bool? ?? false;

        final generatedAt = data['generated_at'] != null
            ? DateTime.parse(data['generated_at'] as String)
            : null;
        final nextGenerationAt = data['next_generation_at'] != null
            ? DateTime.parse(data['next_generation_at'] as String)
            : null;

        print('✅ Fetched ${recommendations.length} cast & crew recommendations');
        print('   Theme: $_cachedSectionTitle');
        print('   Featured: ${featuredPeople.map((p) => p.name).join(", ")}');
        print('   Generated: ${generatedAt?.toLocal()}');
        print('   Next generation: ${nextGenerationAt?.toLocal()}');
        print('═══════════════════════════════════════\n');

        return MagicMoviesCastCrewResult.success(
          sectionTitle: _cachedSectionTitle!,
          featuredPeople: featuredPeople,
          recommendations: recommendations,
          generatedAt: generatedAt,
          nextGenerationAt: nextGenerationAt,
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        return MagicMoviesCastCrewResult.failure(
          MagicMoviesCastCrewError.fetchFailed,
          'Failed to fetch: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Magic Movies Cast & Crew fetch error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      return MagicMoviesCastCrewResult.failure(MagicMoviesCastCrewError.unknown, e.toString());
    }
  }

  /// Generate new Magic Movies Cast & Crew recommendations
  Future<MagicMoviesCastCrewResult> generateRecommendations({bool force = false}) async {
    print('\n═══════════════════════════════════════');
    print('🎬👥 MAGIC MOVIES CAST & CREW GENERATION STARTED');
    print('═══════════════════════════════════════');
    print('Force: $force');
    print('Tier: $_subscriptionTier');

    if (!ZagreusMega.isEnabled) {
      print('❌ GENERATION BLOCKED: Mega or Ultra subscription required');
      return MagicMoviesCastCrewResult.failure(
        MagicMoviesCastCrewError.noMegaOrUltra,
        'Mega or Ultra subscription required',
      );
    }

    if (_isGenerating && !force) {
      print('⏳ Already generating...');
      return MagicMoviesCastCrewResult.failure(
        MagicMoviesCastCrewError.alreadyGenerating,
        'Already being generated',
      );
    }

    try {
      final deviceId = DeviceIdService().deviceId;
      final hmacKey = HmacEncryptionService().hmacKey;

      _isGenerating = true;

      final response = await http.post(
        Uri.parse('$_baseUrl/recommendations/magic-movies-cast-crew/generate'),
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
          print('✅ Already up to date');
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
        return MagicMoviesCastCrewResult.failure(
          MagicMoviesCastCrewError.alreadyGenerating,
          'Generation already in progress',
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        _isGenerating = false;
        return MagicMoviesCastCrewResult.failure(
          MagicMoviesCastCrewError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        _isGenerating = false;
        return MagicMoviesCastCrewResult.failure(
          MagicMoviesCastCrewError.unknown,
          'Generation failed: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Magic Movies Cast & Crew generation error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      _isGenerating = false;
      return MagicMoviesCastCrewResult.failure(MagicMoviesCastCrewError.unknown, e.toString());
    }
  }

  /// Convenience method to fetch or generate as needed
  Future<MagicMoviesCastCrewResult> syncIfNeeded() async {
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
