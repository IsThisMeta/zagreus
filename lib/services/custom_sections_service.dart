import 'package:zagreus/core.dart';
import 'package:zagreus/services/device_id_service.dart';
import 'package:zagreus/services/hmac_encryption_service.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum CustomSectionError {
  noMegaOrUltra,
  alreadyGenerating,
  fetchFailed,
  notSynced,
  unknown,
}

/// Represents a user-defined custom section configuration
class CustomSectionConfig {
  final String id;
  final String title;
  final String description;
  final String mediaType; // 'movie' or 'tv'
  final DateTime createdAt;
  final DateTime? lastGeneratedAt;

  CustomSectionConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.mediaType,
    required this.createdAt,
    this.lastGeneratedAt,
  });

  factory CustomSectionConfig.fromJson(Map<String, dynamic> json) {
    return CustomSectionConfig(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      mediaType: json['media_type'] as String? ?? 'movie',
      createdAt: DateTime.parse(json['created_at'] as String),
      lastGeneratedAt: json['last_generated_at'] != null
          ? DateTime.parse(json['last_generated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'media_type': mediaType,
        'created_at': createdAt.toIso8601String(),
        'last_generated_at': lastGeneratedAt?.toIso8601String(),
      };
}

class CustomSectionResult {
  final bool success;
  final CustomSectionError? error;
  final String? errorMessage;
  final String? sectionTitle;
  final String? sectionDescription;
  final List<CustomSectionItem>? recommendations;
  final DateTime? generatedAt;
  final DateTime? nextGenerationAt;

  CustomSectionResult.success({
    required this.sectionTitle,
    required this.sectionDescription,
    required this.recommendations,
    this.generatedAt,
    this.nextGenerationAt,
  })  : success = true,
        error = null,
        errorMessage = null;

  CustomSectionResult.failure(this.error, [this.errorMessage])
      : success = false,
        sectionTitle = null,
        sectionDescription = null,
        recommendations = null,
        generatedAt = null,
        nextGenerationAt = null;
}

class CustomSectionItem {
  final String title;
  final int year;
  final String? director;
  final List<String> genres;
  final String reason;
  final int matchScore;
  final int? tmdbId;
  final String? posterPath;
  final String mediaType;

  CustomSectionItem({
    required this.title,
    required this.year,
    this.director,
    required this.genres,
    required this.reason,
    required this.matchScore,
    this.tmdbId,
    this.posterPath,
    required this.mediaType,
  });

  String? get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) return null;
    return 'https://image.tmdb.org/t/p/w342$posterPath';
  }

  factory CustomSectionItem.fromJson(Map<String, dynamic> json) {
    return CustomSectionItem(
      title: json['title'] as String,
      year: json['year'] as int,
      director: json['director'] as String?,
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      reason: json['reason'] as String,
      matchScore: json['match_score'] as int? ?? 75,
      tmdbId: json['tmdb_id'] as int?,
      posterPath: json['poster_path'] as String?,
      mediaType: json['media_type'] as String? ?? 'movie',
    );
  }
}

/// Service for managing user-defined Custom Sections AI-powered recommendations
/// Custom Sections allow users to create their own themed recommendation categories
/// Available to Mega and Ultra subscribers
class CustomSectionsService {
  static final CustomSectionsService _instance =
      CustomSectionsService._internal();
  factory CustomSectionsService() => _instance;
  CustomSectionsService._internal();

  static const String _baseUrl = 'https://z-assistant.fly.dev';

  // Cache per section ID
  final Map<String, CustomSectionResult> _cachedResults = {};
  final Map<String, bool> _generatingFlags = {};

  // Supabase client
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Get the current subscription tier
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
      'Content-Type': 'application/json',
    };
  }

  /// Get all saved custom section configs from local storage
  List<CustomSectionConfig> getSavedSections({required String mediaType}) {
    final savedList =
        ZagreusDatabase.CUSTOM_SECTIONS.read() as List<dynamic>? ?? [];
    return savedList
        .map((json) => CustomSectionConfig.fromJson(
            Map<String, dynamic>.from(json as Map)))
        .where((config) => config.mediaType == mediaType)
        .toList();
  }

  /// Save a new custom section config
  Future<CustomSectionConfig> createSection({
    required String title,
    required String description,
    required String mediaType,
  }) async {
    final config = CustomSectionConfig(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      mediaType: mediaType,
      createdAt: DateTime.now(),
    );

    // Save locally
    final savedList =
        ZagreusDatabase.CUSTOM_SECTIONS.read() as List<dynamic>? ?? [];
    savedList.add(config.toJson());
    ZagreusDatabase.CUSTOM_SECTIONS.update(savedList);

    // Sync to Supabase
    await _syncToSupabase(config);

    return config;
  }

  /// Update an existing custom section config
  Future<void> updateSection(CustomSectionConfig config) async {
    // Update locally
    final savedList =
        ZagreusDatabase.CUSTOM_SECTIONS.read() as List<dynamic>? ?? [];
    final index = savedList.indexWhere((json) =>
        (json as Map<String, dynamic>)['id'] == config.id);
    if (index != -1) {
      savedList[index] = config.toJson();
      ZagreusDatabase.CUSTOM_SECTIONS.update(savedList);
    }

    // Sync to Supabase
    await _syncToSupabase(config);
  }

  /// Delete a custom section config
  Future<void> deleteSection(String sectionId) async {
    // Delete locally
    final savedList =
        ZagreusDatabase.CUSTOM_SECTIONS.read() as List<dynamic>? ?? [];
    savedList.removeWhere(
        (json) => (json as Map<String, dynamic>)['id'] == sectionId);
    ZagreusDatabase.CUSTOM_SECTIONS.update(savedList);
    _cachedResults.remove(sectionId);

    // Soft delete in Supabase
    await _deleteFromSupabase(sectionId);
  }

  /// Fetch cached recommendations for a custom section
  Future<CustomSectionResult> fetchRecommendations({
    required String sectionId,
    required String title,
    required String description,
    required String mediaType,
    String? profileKey,
    String? instanceKey,
  }) async {
    print('\n═══════════════════════════════════════');
    print('🎯 CUSTOM SECTION FETCH STARTED');
    print('   Section: $title');
    print('═══════════════════════════════════════');

    // Mega or Ultra required
    if (!(ZagreusUltra.isEnabled || ZagreusMega.isEnabled)) {
      print('❌ FETCH BLOCKED: Mega or Ultra subscription required');
      return CustomSectionResult.failure(
        CustomSectionError.noMegaOrUltra,
        'Mega or Ultra subscription required for Custom Sections',
      );
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations/custom-section/$sectionId'),
        headers: _buildHeaders(
          profileKey: profileKey,
          instanceKey: instanceKey,
        ),
      );

      print('📡 Custom Section response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final recommendationsData = data['recommendations'] as List<dynamic>?;

        if (recommendationsData == null || recommendationsData.isEmpty) {
          print('📭 No recommendations yet');
          return CustomSectionResult.success(
            sectionTitle: title,
            sectionDescription: description,
            recommendations: [],
          );
        }

        final recommendations = recommendationsData
            .map((item) =>
                CustomSectionItem.fromJson(item as Map<String, dynamic>))
            .toList();

        final generatedAt = data['generated_at'] != null
            ? DateTime.parse(data['generated_at'] as String)
            : null;
        final nextGenerationAt = data['next_generation_at'] != null
            ? DateTime.parse(data['next_generation_at'] as String)
            : null;

        print('✅ Fetched ${recommendations.length} custom recommendations');
        print('═══════════════════════════════════════\n');

        final result = CustomSectionResult.success(
          sectionTitle: title,
          sectionDescription: description,
          recommendations: recommendations,
          generatedAt: generatedAt,
          nextGenerationAt: nextGenerationAt,
        );

        _cachedResults[sectionId] = result;
        return result;
      } else if (response.statusCode == 404) {
        // Section not found on backend, needs generation
        return CustomSectionResult.success(
          sectionTitle: title,
          sectionDescription: description,
          recommendations: [],
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        return CustomSectionResult.failure(
          CustomSectionError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        return CustomSectionResult.failure(
          CustomSectionError.fetchFailed,
          'Failed to fetch: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Custom Section fetch error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      return CustomSectionResult.failure(
          CustomSectionError.unknown, e.toString());
    }
  }

  /// Generate new recommendations for a custom section
  Future<CustomSectionResult> generateRecommendations({
    required String sectionId,
    required String title,
    required String description,
    required String mediaType,
    String? profileKey,
    String? instanceKey,
    bool force = false,
  }) async {
    print('\n═══════════════════════════════════════');
    print('🎯 CUSTOM SECTION GENERATION STARTED');
    print('   Section: $title');
    print('   Description: $description');
    print('═══════════════════════════════════════');

    // Mega or Ultra required
    if (!(ZagreusUltra.isEnabled || ZagreusMega.isEnabled)) {
      print('❌ GENERATION BLOCKED: Mega or Ultra subscription required');
      return CustomSectionResult.failure(
        CustomSectionError.noMegaOrUltra,
        'Mega or Ultra subscription required for Custom Sections',
      );
    }

    if (_generatingFlags[sectionId] == true && !force) {
      print('⏳ Already generating...');
      return CustomSectionResult.failure(
        CustomSectionError.alreadyGenerating,
        'This section is already being generated',
      );
    }

    try {
      _generatingFlags[sectionId] = true;

      final response = await http.post(
        Uri.parse('$_baseUrl/recommendations/custom-section/generate'),
        headers: _buildHeaders(
          profileKey: profileKey,
          instanceKey: instanceKey,
        ),
        body: json.encode({
          'section_id': sectionId,
          'title': title,
          'description': description,
          'media_type': mediaType,
        }),
      );

      print('📡 Generation response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        print('✅ Generation started successfully');
        print('   Count: ${data['recommendations_count']}');

        // Fetch the fresh recommendations
        _generatingFlags[sectionId] = false;
        return await fetchRecommendations(
          sectionId: sectionId,
          title: title,
          description: description,
          mediaType: mediaType,
          profileKey: profileKey,
          instanceKey: instanceKey,
        );
      } else if (response.statusCode == 409) {
        print('⏳ Generation already in progress');
        _generatingFlags[sectionId] = false;
        return CustomSectionResult.failure(
          CustomSectionError.alreadyGenerating,
          'Generation already in progress',
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        print('❌ Library not synced: ${error['detail']}');
        _generatingFlags[sectionId] = false;
        return CustomSectionResult.failure(
          CustomSectionError.notSynced,
          error['detail'] as String? ?? 'Library not synced',
        );
      } else {
        print('❌ HTTP ${response.statusCode}: ${response.body}');
        _generatingFlags[sectionId] = false;
        return CustomSectionResult.failure(
          CustomSectionError.unknown,
          'Generation failed: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      ZagLogger().error('Custom Section generation error', e, stack);
      print('❌ EXCEPTION: $e');
      print('═══════════════════════════════════════\n');
      _generatingFlags[sectionId] = false;
      return CustomSectionResult.failure(
          CustomSectionError.unknown, e.toString());
    }
  }

  /// Check if a section needs regeneration (> 7 days old)
  bool needsRegeneration({
    required String sectionId,
    CustomSectionResult? existingResult,
  }) {
    if (!ZagreusMega.isEnabled) return false;

    if (existingResult == null) return true;
    if (!existingResult.success || existingResult.nextGenerationAt == null) {
      return true;
    }

    return DateTime.now().isAfter(existingResult.nextGenerationAt!);
  }

  // ============================================================================
  // SUPABASE SYNC METHODS
  // ============================================================================

  /// Sync a custom section config to Supabase (upsert)
  Future<void> _syncToSupabase(CustomSectionConfig config) async {
    try {
      final deviceId = DeviceIdService().deviceId;
      final profileKey = ZagreusDatabase.ENABLED_PROFILE.read();
      final userId = _getUserId();

      await _supabase.from('custom_sections').upsert({
        'id': config.id,
        'user_id': userId,
        'device_id': deviceId,
        'profile_key': profileKey,
        'title': config.title,
        'description': config.description,
        'media_type': config.mediaType,
        'created_at': config.createdAt.toIso8601String(),
        'last_generated_at': config.lastGeneratedAt?.toIso8601String(),
      });

      print('✅ Synced custom section to Supabase: ${config.title}');
    } catch (e, stack) {
      ZagLogger().error('Failed to sync custom section to Supabase', e, stack);
      // Don't throw - allow offline operation
    }
  }

  /// Soft delete a custom section from Supabase
  Future<void> _deleteFromSupabase(String sectionId) async {
    try {
      await _supabase.from('custom_sections').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', sectionId);

      print('✅ Soft deleted custom section from Supabase: $sectionId');
    } catch (e, stack) {
      ZagLogger().error('Failed to delete custom section from Supabase', e, stack);
      // Don't throw - allow offline operation
    }
  }

  /// Fetch custom sections from Supabase and merge with local storage
  Future<List<CustomSectionConfig>> syncFromSupabase({
    required String mediaType,
  }) async {
    try {
      final deviceId = DeviceIdService().deviceId;
      final profileKey = ZagreusDatabase.ENABLED_PROFILE.read();

      final response = await _supabase
          .from('custom_sections')
          .select()
          .eq('device_id', deviceId)
          .eq('profile_key', profileKey)
          .eq('media_type', mediaType)
          .filter('deleted_at', 'is', null)
          .order('created_at', ascending: false);

      final cloudSections = (response as List)
          .map((json) => CustomSectionConfig.fromJson(json))
          .toList();

      // Merge with local storage
      final localSections = getSavedSections(mediaType: mediaType);
      final mergedMap = <String, CustomSectionConfig>{};

      // Add local sections first
      for (final section in localSections) {
        mergedMap[section.id] = section;
      }

      // Override with cloud sections (cloud is source of truth)
      for (final section in cloudSections) {
        mergedMap[section.id] = section;
      }

      // Save merged list back to local storage
      final savedList =
          ZagreusDatabase.CUSTOM_SECTIONS.read() as List<dynamic>? ?? [];
      final otherMediaSections = savedList
          .map((json) =>
              CustomSectionConfig.fromJson(Map<String, dynamic>.from(json as Map)))
          .where((config) => config.mediaType != mediaType)
          .toList();

      final allSections = [
        ...otherMediaSections.map((c) => c.toJson()),
        ...mergedMap.values.map((c) => c.toJson()),
      ];

      ZagreusDatabase.CUSTOM_SECTIONS.update(allSections);

      return mergedMap.values.toList();
    } catch (e, stack) {
      ZagLogger().error('Failed to sync from Supabase', e, stack);
      // Fallback to local storage
      return getSavedSections(mediaType: mediaType);
    }
  }

  /// Get user ID (device ID as fallback for anonymous users)
  String _getUserId() {
    final user = _supabase.auth.currentUser;
    return user?.id ?? DeviceIdService().deviceId;
  }
}
