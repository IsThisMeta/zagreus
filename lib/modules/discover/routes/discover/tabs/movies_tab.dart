import 'package:flutter/material.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class DiscoverMoviesTabData {
  final bool isLoading;
  final String? error;
  final RefreshCallback onRefresh;
  final VoidCallback onRetry;
  final ScrollController scrollController;
  final Widget? heroCarousel;
  final Widget? quickButtons;
  final List<Widget> sections;
  final Widget? aiSignInGate;
  final Widget customSectionsArea;
  final Widget discoverSectionsButton;
  final Widget zAutoRefreshNote;
  final Widget metadataCredits;

  const DiscoverMoviesTabData({
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onRetry,
    required this.scrollController,
    required this.sections,
    required this.customSectionsArea,
    required this.discoverSectionsButton,
    required this.zAutoRefreshNote,
    required this.metadataCredits,
    this.heroCarousel,
    this.quickButtons,
    this.aiSignInGate,
  });
}

class DiscoverMoviesSectionData {
  final bool showTitles;
  final bool hasAiAccess;
  final bool hasRecentlyDownloaded;
  final Widget Function() recentlyDownloadedSection;
  final Widget Function() recommendedMoviesSection;
  final Widget Function() missingMoviesSection;
  final Widget Function() downloadingSoonSection;
  final Widget Function() studiosSection;
  final Widget Function() movieGenresSection;
  final Widget Function() popularMoviesSection;
  final Widget Function() recentlyReleasedMoviesSection;
  final Widget Function() mostAnticipatedMoviesSection;
  final Widget Function() popularPeopleSection;
  final Widget Function() deepCutsSection;
  final Widget Function() magicMoviesSection;
  final Widget Function() magicMoviesCastCrewSection;
  final Widget Function() magicPeopleSection;

  const DiscoverMoviesSectionData({
    required this.showTitles,
    required this.hasAiAccess,
    required this.hasRecentlyDownloaded,
    required this.recentlyDownloadedSection,
    required this.recommendedMoviesSection,
    required this.missingMoviesSection,
    required this.downloadingSoonSection,
    required this.studiosSection,
    required this.movieGenresSection,
    required this.popularMoviesSection,
    required this.recentlyReleasedMoviesSection,
    required this.mostAnticipatedMoviesSection,
    required this.popularPeopleSection,
    required this.deepCutsSection,
    required this.magicMoviesSection,
    required this.magicMoviesCastCrewSection,
    required this.magicPeopleSection,
  });
}

List<Widget> buildMovieSections(DiscoverMoviesSectionData data) {
  // Default section order - keep in sync with _defaultMovieSections in discover_sections_editor.dart
  const defaultOrder = [
    'recently_downloaded',
    'recommended',
    'missing',
    'downloading_soon',
    'studios',
    'movie_genres',
    'popular_movies',
    'recently_released_movies',
    'most_anticipated_movies',
    'popular_people',
    'deep_cuts',
    'magic_movies',
    'magic_movies_cast_crew',
    'magic_people',
  ];

  List<String> ensureContainsDefaultSections({
    required List<String> currentOrder,
    required List<String> defaultOrder,
  }) {
    final updated = List<String>.from(currentOrder);
    for (final sectionKey in defaultOrder) {
      if (updated.contains(sectionKey)) continue;

      var insertAt = updated.length;
      final defaultIndex = defaultOrder.indexOf(sectionKey);
      for (var i = defaultIndex - 1; i >= 0; i--) {
        final previousKey = defaultOrder[i];
        final previousIndex = updated.indexOf(previousKey);
        if (previousIndex != -1) {
          insertAt = previousIndex + 1;
          break;
        }
      }
      updated.insert(insertAt, sectionKey);
    }
    return updated;
  }

  // Get saved order or use default
  final savedOrder =
      ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.read() as List;
  var sectionOrder =
      savedOrder.isNotEmpty ? List<String>.from(savedOrder) : defaultOrder;

  // One-time migration: ensure older saved orders include newer default sections.
  // Guarded so user-deleted sections are not re-added on every rebuild.
  final migrated = ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER_MIGRATED.read();
  if (savedOrder.isNotEmpty && migrated != true) {
    sectionOrder = ensureContainsDefaultSections(
      currentOrder: sectionOrder,
      defaultOrder: defaultOrder,
    );
    ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.update(sectionOrder);
    ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER_MIGRATED.update(true);
  }

  // Map of section builders - no extra spacing between sections
  // Each section handles its own internal spacing (title -> content)
  final sectionBuilders = <String, Widget Function()>{
    'recently_downloaded': () => data.hasRecentlyDownloaded
        ? data.recentlyDownloadedSection()
        : const SizedBox.shrink(),
    'recommended': () => data.recommendedMoviesSection(),
    'missing': () => data.missingMoviesSection(),
    'downloading_soon': () => data.downloadingSoonSection(),
    'studios': () => Column(children: [
          data.studiosSection(),
          const SizedBox(height: 8),
        ]),
    'movie_genres': () => Column(children: [
          data.movieGenresSection(),
          const SizedBox(height: 8),
        ]),
    'popular_movies': () => data.popularMoviesSection(),
    'recently_released_movies': () => data.recentlyReleasedMoviesSection(),
    'most_anticipated_movies': () => data.mostAnticipatedMoviesSection(),
    'popular_people': () => data.popularPeopleSection(),
    'deep_cuts': () => data.hasAiAccess
        ? data.deepCutsSection()
        : const SizedBox.shrink(),
    'magic_movies': () => data.hasAiAccess
        ? data.magicMoviesSection()
        : const SizedBox.shrink(),
    'magic_movies_cast_crew': () => data.hasAiAccess
        ? data.magicMoviesCastCrewSection()
        : const SizedBox.shrink(),
    'magic_people': () => data.hasAiAccess
        ? data.magicPeopleSection()
        : const SizedBox.shrink(),
  };

  // Build sections in saved order
  final sections = <Widget>[];
  for (final sectionKey in sectionOrder) {
    final builder = sectionBuilders[sectionKey];
    if (builder != null) {
      sections.add(builder());
    }
  }
  return sections;
}

class DiscoverMoviesTab extends StatelessWidget {
  final DiscoverMoviesTabData data;

  const DiscoverMoviesTab({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF6688FF)),
        ),
      );
    }

    if (data.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load recently downloaded',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.error!,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey
                    : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: data.onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6688FF),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: data.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics()),
        controller: data.scrollController,
        padding: EdgeInsets.zero,
        children: [
          // Hero carousel
          if (data.heroCarousel != null) data.heroCarousel!,
          // Quick buttons for service navigation
          if (data.quickButtons != null) data.quickButtons!,
          // Content sections in custom order
          ...data.sections,
          // Single grouped sign-in gate for all AI sections (Deep Cuts / Magic / Custom Sections)
          if (data.aiSignInGate != null) data.aiSignInGate!,
          // Custom user-defined sections (Mega/Ultra only)
          data.customSectionsArea,
          data.discoverSectionsButton,
          data.zAutoRefreshNote,
          data.metadataCredits,
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
