import 'package:flutter/material.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class DiscoverShowsTabData {
  final RefreshCallback onRefresh;
  final ScrollController scrollController;
  final Widget? heroCarousel;
  final Widget? quickButtons;
  final List<Widget> sections;
  final Widget? aiSignInGate;
  final Widget customSectionsArea;
  final Widget discoverSectionsButton;
  final Widget zAutoRefreshNote;
  final Widget metadataCredits;

  const DiscoverShowsTabData({
    required this.onRefresh,
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

class DiscoverShowsTab extends StatelessWidget {
  final DiscoverShowsTabData data;

  const DiscoverShowsTab({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: data.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics()),
        controller: data.scrollController,
        padding: EdgeInsets.zero,
        children: [
          // Hero carousel (could be TV shows specific)
          if (data.heroCarousel != null) data.heroCarousel!,
          // Quick buttons for service navigation
          if (data.quickButtons != null) data.quickButtons!,
          // TV shows sections in custom order
          ...data.sections,
          // Single grouped sign-in gate for all AI sections (Up Next / Magic / Custom Sections)
          if (data.aiSignInGate != null) data.aiSignInGate!,
          // Custom user-defined sections (Mega/Ultra only)
          data.customSectionsArea,
          const SizedBox(height: 16),
          data.discoverSectionsButton,
          data.zAutoRefreshNote,
          data.metadataCredits,
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class DiscoverTvSectionData {
  final bool showTitles;
  final bool hasAiAccess;
  final bool hasRecentlyDownloadedShows;
  final Widget Function() recentlyDownloadedShowsSection;
  final Widget Function() airingNextSection;
  final Widget Function() networksSection;
  final Widget Function() tvGenresSection;
  final Widget Function() popularTvShowsSection;
  final Widget Function() trendingNewTvShowsSection;
  final Widget Function() mostAnticipatedShowsSection;
  final Widget Function() upNextSection;
  final Widget Function() magicShowsSection;
  final Widget Function() magicShowsCastCrewSection;
  final Widget Function() magicPeopleShowsSection;

  const DiscoverTvSectionData({
    required this.showTitles,
    required this.hasAiAccess,
    required this.hasRecentlyDownloadedShows,
    required this.recentlyDownloadedShowsSection,
    required this.airingNextSection,
    required this.networksSection,
    required this.tvGenresSection,
    required this.popularTvShowsSection,
    required this.trendingNewTvShowsSection,
    required this.mostAnticipatedShowsSection,
    required this.upNextSection,
    required this.magicShowsSection,
    required this.magicShowsCastCrewSection,
    required this.magicPeopleShowsSection,
  });
}

List<Widget> buildTvSections(DiscoverTvSectionData data) {
  // Default section order - keep in sync with _defaultTVSections in discover_sections_editor.dart
  const defaultOrder = [
    'recently_downloaded_shows',
    'airing_next',
    'networks',
    'tv_genres',
    'popular_tv_shows',
    'trending_new_tv_shows',
    'most_anticipated',
    'up_next',
    'magic_shows',
    'magic_shows_cast_crew',
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
  final savedOrder = ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.read() as List;
  var sectionOrder =
      savedOrder.isNotEmpty ? List<String>.from(savedOrder) : defaultOrder;

  // One-time migration: ensure older saved orders include newer default sections.
  // Guarded so user-deleted sections are not re-added on every rebuild.
  final migrated = ZagreusDatabase.DISCOVER_TV_SECTION_ORDER_MIGRATED.read();
  if (savedOrder.isNotEmpty && migrated != true) {
    sectionOrder = ensureContainsDefaultSections(
      currentOrder: sectionOrder,
      defaultOrder: defaultOrder,
    );
    ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.update(sectionOrder);
    ZagreusDatabase.DISCOVER_TV_SECTION_ORDER_MIGRATED.update(true);
  }

  // Map of section builders - no extra spacing between sections
  // Each section handles its own internal spacing (title -> content)
  final sectionBuilders = <String, Widget Function()>{
    'recently_downloaded_shows': () => data.hasRecentlyDownloadedShows
        ? data.recentlyDownloadedShowsSection()
        : const SizedBox.shrink(),
    'airing_next': () => data.airingNextSection(),
    'networks': () => data.networksSection(),
    'tv_genres': () => data.tvGenresSection(),
    'popular_tv_shows': () => data.popularTvShowsSection(),
    'trending_new_tv_shows': () => data.trendingNewTvShowsSection(),
    'most_anticipated': () => data.mostAnticipatedShowsSection(),
    'up_next': () => data.hasAiAccess
        ? data.upNextSection()
        : const SizedBox.shrink(),
    'magic_shows': () => data.hasAiAccess
        ? data.magicShowsSection()
        : const SizedBox.shrink(),
    'magic_shows_cast_crew': () => data.hasAiAccess
        ? data.magicShowsCastCrewSection()
        : const SizedBox.shrink(),
    'magic_people': () => data.hasAiAccess
        ? data.magicPeopleShowsSection()
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
