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
  final bool hasMissingMovies;
  final Widget Function() recentlyDownloadedSection;
  final Widget Function() recommendedMoviesSection;
  final Widget Function() missingMoviesSection;
  final Widget Function() downloadingSoonSection;
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
    required this.hasMissingMovies,
    required this.recentlyDownloadedSection,
    required this.recommendedMoviesSection,
    required this.missingMoviesSection,
    required this.downloadingSoonSection,
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

  // Map of section builders
  final sectionBuilders = <String, Widget Function()>{
    'recently_downloaded': () => data.hasRecentlyDownloaded
        ? Column(children: [
            data.recentlyDownloadedSection(),
            if (data.showTitles) const SizedBox(height: 4)
          ])
        : const SizedBox.shrink(),
    'recommended': () => Column(children: [
          data.recommendedMoviesSection(),
          if (data.showTitles) const SizedBox(height: 4)
        ]),
    'missing': () => data.hasMissingMovies
        ? Column(children: [
            data.missingMoviesSection(),
            if (data.showTitles) const SizedBox(height: 4)
          ])
        : const SizedBox.shrink(),
    'downloading_soon': () => Column(children: [
          data.downloadingSoonSection(),
          if (data.showTitles) const SizedBox(height: 4)
        ]),
    'popular_movies': () => Column(children: [
          data.popularMoviesSection(),
          if (data.showTitles) const SizedBox(height: 4)
        ]),
    'recently_released_movies': () => Column(children: [
          data.recentlyReleasedMoviesSection(),
          if (data.showTitles) const SizedBox(height: 4)
        ]),
    'most_anticipated_movies': () =>
        data.mostAnticipatedMoviesSection(), // Works even if empty
    'popular_people': () => Column(children: [
          data.popularPeopleSection(),
          if (data.showTitles) const SizedBox(height: 4)
        ]),
    'deep_cuts': () => data.hasAiAccess
        ? Column(children: [
            data.deepCutsSection(),
            if (data.showTitles) const SizedBox(height: 4)
          ])
        : const SizedBox.shrink(),
    'magic_movies': () => data.hasAiAccess
        ? Column(children: [
            data.magicMoviesSection(),
            if (data.showTitles) const SizedBox(height: 4)
          ])
        : const SizedBox.shrink(),
    'magic_movies_cast_crew': () => data.hasAiAccess
        ? Column(children: [
            data.magicMoviesCastCrewSection(),
            if (data.showTitles) const SizedBox(height: 4)
          ])
        : const SizedBox.shrink(),
    'magic_people': () => data.hasAiAccess
        ? Column(children: [
            data.magicPeopleSection(),
            if (data.showTitles) const SizedBox(height: 4)
          ])
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
