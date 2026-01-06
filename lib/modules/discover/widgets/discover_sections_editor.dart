import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/services/custom_sections_service.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_supreme.dart';

class DiscoverSectionsEditor extends StatefulWidget {
  const DiscoverSectionsEditor({
    super.key,
    this.onHasChangesChanged,
    this.initialIndex = 0,
  });

  final ValueChanged<bool>? onHasChangesChanged;
  final int initialIndex;

  @override
  DiscoverSectionsEditorState createState() => DiscoverSectionsEditorState();
}

class DiscoverSectionsEditorState extends State<DiscoverSectionsEditor> {
  static const List<String> _defaultMovieSections = [
    'recently_downloaded',
    'downloading_soon',
    'recently_released_movies',
    'popular_movies',
    'recommended',
    'most_anticipated_movies',
    'popular_people',
    'deep_cuts',
    'missing',
    'studios',
    'movie_genres',
    'magic_movies',
    'magic_movies_cast_crew',
    'magic_people',
  ];

  static const List<String> _defaultTVSections = [
    'recently_downloaded_shows',
    'airing_next',
    'popular_tv_shows',
    'trending_new_tv_shows',
    'most_anticipated',
    'up_next',
    'networks',
    'tv_genres',
    'magic_shows',
    'magic_shows_cast_crew',
    'magic_people',
  ];

  /// AI sections that require Mega/Ultra/Supreme subscription
  static const List<String> _aiSections = [
    'deep_cuts',
    'up_next',
    'magic_movies',
    'magic_movies_cast_crew',
    'magic_shows',
    'magic_shows_cast_crew',
    'magic_people',
  ];

  /// Check if user has AI tier (Mega/Ultra/Supreme)
  static bool get _hasAiAccess =>
      ZagreusMega.isEnabled || ZagreusUltra.isEnabled || ZagreusSupreme.isEnabled;

  /// Check if custom sections feature is enabled (Mega/Ultra/Supreme)
  bool get _customSectionsEnabled =>
      ZagreusMega.isEnabled || ZagreusUltra.isEnabled || ZagreusSupreme.isEnabled;

  // Phone poster height
  static const double _posterHeightMinPhone = 175.0;
  static const double _posterHeightMaxPhone = 275.0;

  // iPad poster height (larger range for bigger screen)
  static const double _posterHeightMinIPad = 225.0;
  static const double _posterHeightMaxIPad = 325.0;

  // Named poster sizes for phone (175-275, 25px intervals)
  static const Map<String, double> _posterSizesPhone = {
    'Very Small': 175.0,
    'Small': 200.0,
    'Regular': 225.0,
    'Large': 250.0,
    'Very Large': 275.0,
  };

  // Named poster sizes for iPad (225-325, 25px intervals)
  static const Map<String, double> _posterSizesIPad = {
    'Very Small': 225.0,
    'Small': 250.0,
    'Regular': 275.0,
    'Large': 300.0,
    'Very Large': 325.0,
  };

  // Get poster sizes based on device type
  Map<String, double> get _posterSizes =>
      _isTablet ? _posterSizesIPad : _posterSizesPhone;

  // Convert pixel value to size name
  String _posterHeightToSizeName(double height) {
    final sizes = _posterSizes;
    for (final entry in sizes.entries) {
      if ((entry.value - height).abs() < 1.0) {
        return entry.key;
      }
    }
    // Find closest match
    String closest = 'Regular';
    double minDiff = double.infinity;
    for (final entry in sizes.entries) {
      final diff = (entry.value - height).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = entry.key;
      }
    }
    return closest;
  }

  // Phone defaults
  static const double _heroHeightMinPhone = 300.0;
  static const double _heroHeightMaxPhone = 500.0;
  static const int _columnsPerRowMinPhone = 2;
  static const int _columnsPerRowMaxPhone = 4;

  // iPad defaults (larger screen = more space for hero, more columns)
  static const double _heroHeightMinIPad = 450.0;
  static const double _heroHeightMaxIPad = 650.0;
  static const int _columnsPerRowMinIPad = 2; // Default 4, range 2-6
  static const int _columnsPerRowMaxIPad = 6;

  // Named hero sizes for phone (300-500, 50px intervals)
  static const Map<String, double> _heroSizesPhone = {
    'Very Small': 300.0,
    'Small': 350.0,
    'Regular': 400.0,
    'Large': 450.0,
    'Very Large': 500.0,
  };

  // Named hero sizes for iPad (450-650, 50px intervals)
  static const Map<String, double> _heroSizesIPad = {
    'Very Small': 450.0,
    'Small': 500.0,
    'Regular': 550.0,
    'Large': 600.0,
    'Very Large': 650.0,
  };

  // Get hero sizes based on device type
  Map<String, double> get _heroSizes =>
      _isTablet ? _heroSizesIPad : _heroSizesPhone;

  // Convert pixel value to hero size name
  String _heroHeightToSizeName(double height) {
    final sizes = _heroSizes;
    for (final entry in sizes.entries) {
      if ((entry.value - height).abs() < 1.0) {
        return entry.key;
      }
    }
    // Find closest match
    String closest = 'Regular';
    double minDiff = double.infinity;
    for (final entry in sizes.entries) {
      final diff = (entry.value - height).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = entry.key;
      }
    }
    return closest;
  }

  // Helper to check if we're on iPad
  bool get _isTablet => mounted && ZagPlatform.isTablet(context);

  // Dynamic getters based on device type
  double get _posterHeightMin =>
      _isTablet ? _posterHeightMinIPad : _posterHeightMinPhone;
  double get _posterHeightMax =>
      _isTablet ? _posterHeightMaxIPad : _posterHeightMaxPhone;
  double get _heroHeightMin =>
      _isTablet ? _heroHeightMinIPad : _heroHeightMinPhone;
  double get _heroHeightMax =>
      _isTablet ? _heroHeightMaxIPad : _heroHeightMaxPhone;
  int get _columnsPerRowMin =>
      _isTablet ? _columnsPerRowMinIPad : _columnsPerRowMinPhone;
  int get _columnsPerRowMax =>
      _isTablet ? _columnsPerRowMaxIPad : _columnsPerRowMaxPhone;

  String _sectionName(String sectionKey) {
    final key = 'discover.section.$sectionKey';
    final translated = key.tr();
    return translated == key ? sectionKey : translated;
  }

  String _getQuickButtonDisplayName(String service) {
    switch (service) {
      case 'radarr':
        return 'Radarr';
      case 'sonarr':
        return 'Sonarr';
      case 'lidarr':
        return 'Lidarr';
      case 'readarr':
        return 'Readarr';
      case 'seerr':
        return 'Seerr';
      case 'tautulli':
        return 'Tautulli';
      case 'sabnzbd':
        return 'SABnzbd';
      case 'nzbget':
        return 'NZBget';
      case 'unraid':
        return 'Unraid';
      case 'search':
        return 'Search';
      case 'ssh':
        return 'SSH';
      default:
        return service;
    }
  }

  late List<String> _movieSections;
  late List<String> _tvSections;
  bool _hasChanges = false;
  double _posterHeight = 225.0; // Regular for phone
  double _heroHeight = 400.0; // Regular for phone
  int _columnsPerRow = 3;
  bool _showTitles = true;

  bool _monochromeRatings = false;
  bool _showHeroCarousel = true;
  bool _hideInLibraryFromHero = false;
  String _trendingTimeWindow = 'week';
  List<String> _quickButtons = [];

  // All available quick button services
  static const List<String> _allQuickButtonServices = [
    'radarr',
    'sonarr',
    'lidarr',
    'readarr',
    'seerr',
    'tautulli',
    'sabnzbd',
    'nzbget',
    'unraid',
    'search',
    'ssh',
  ];

  late Future<List<CustomSectionConfig>> _customMovieSectionsFuture;
  late Future<List<CustomSectionConfig>> _customTVSectionsFuture;

  bool get hasChanges => _hasChanges;

  // Track if we've loaded device-dependent settings
  bool _deviceSettingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNonDeviceDependentSettings();
    if (_customSectionsEnabled) {
      _customMovieSectionsFuture =
          CustomSectionsService().syncFromSupabase(mediaType: 'movie');
      _customTVSectionsFuture =
          CustomSectionsService().syncFromSupabase(mediaType: 'tv');
    } else {
      _customMovieSectionsFuture = Future.value(const <CustomSectionConfig>[]);
      _customTVSectionsFuture = Future.value(const <CustomSectionConfig>[]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_deviceSettingsLoaded) {
      _deviceSettingsLoaded = true;
      _loadDeviceDependentSettings();
    }
  }

  /// Load settings that don't depend on device type (sections, booleans, etc.)
  void _loadNonDeviceDependentSettings() {
    final savedMovieOrder =
        ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.read() as List;
    final savedTVOrder =
        ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.read() as List;

    _movieSections = savedMovieOrder.isNotEmpty
        ? List<String>.from(savedMovieOrder)
        : List<String>.from(_defaultMovieSections);

    _tvSections = savedTVOrder.isNotEmpty
        ? List<String>.from(savedTVOrder)
        : List<String>.from(_defaultTVSections);

    // Load show titles setting
    final savedShowTitles = ZagreusDatabase.DISCOVER_SHOW_TITLES.read();
    if (savedShowTitles != null) {
      _showTitles = savedShowTitles;
    }



    // Load monochrome ratings setting
    final savedMonochromeRatings =
        ZagreusDatabase.DISCOVER_MONOCHROME_RATINGS.read();
    if (savedMonochromeRatings != null) {
      _monochromeRatings = savedMonochromeRatings;
    }

    // Load show hero carousel setting
    final savedShowHeroCarousel =
        ZagreusDatabase.DISCOVER_SHOW_HERO_CAROUSEL.read();
    if (savedShowHeroCarousel != null) {
      _showHeroCarousel = savedShowHeroCarousel;
    }

    // Load hide in library from hero setting
    final savedHideInLibraryFromHero =
        ZagreusDatabase.DISCOVER_HIDE_IN_LIBRARY_FROM_HERO.read();
    if (savedHideInLibraryFromHero != null) {
      _hideInLibraryFromHero = savedHideInLibraryFromHero;
    }

    final savedTimeWindow =
        ZagreusDatabase.DISCOVER_TRENDING_TIME_WINDOW.read();
    if (savedTimeWindow == 'day' || savedTimeWindow == 'week') {
      _trendingTimeWindow = savedTimeWindow;
    }

    // Load quick buttons setting (empty by default)
    final savedQuickButtons =
        ZagreusDatabase.DISCOVER_QUICK_BUTTONS.read() as List;
    _quickButtons = List<String>.from(savedQuickButtons);
  }

  /// Load settings that are device-specific (poster height, hero height, columns per row)
  void _loadDeviceDependentSettings() {
    final isTablet = _isTablet;

    // Load poster height from device-specific key
    final savedPosterHeight = isTablet
        ? ZagreusDatabase.DISCOVER_IPAD_POSTER_HEIGHT.read()
        : ZagreusDatabase.DISCOVER_POSTER_HEIGHT.read();
    if (savedPosterHeight >= _posterHeightMin &&
        savedPosterHeight <= _posterHeightMax) {
      _posterHeight = savedPosterHeight;
    } else {
      // Set to default for this device type
      _posterHeight = isTablet ? 275.0 : 225.0;
    }

    // Load hero height from device-specific key
    final savedHeroHeight = isTablet
        ? ZagreusDatabase.DISCOVER_IPAD_HERO_HEIGHT.read()
        : ZagreusDatabase.DISCOVER_HERO_HEIGHT.read();
    if (savedHeroHeight >= _heroHeightMin &&
        savedHeroHeight <= _heroHeightMax) {
      _heroHeight = savedHeroHeight;
    } else {
      // Set to default for this device type
      _heroHeight = isTablet ? 550.0 : 400.0;
    }

    // Load columns per row from device-specific key
    final savedColumns = isTablet
        ? ZagreusDatabase.DISCOVER_IPAD_COLUMNS_PER_ROW.read()
        : ZagreusDatabase.DISCOVER_COLUMNS_PER_ROW.read();
    if (savedColumns >= _columnsPerRowMin &&
        savedColumns <= _columnsPerRowMax) {
      _columnsPerRow = savedColumns;
    } else {
      // Set to default for this device type
      _columnsPerRow = isTablet ? 4 : 3;
    }

    setState(() {});
  }

  Future<void> saveChanges() async {
    if (!_hasChanges) {
      return;
    }
    ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.update(_movieSections);
    ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.update(_tvSections);
    ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER_MIGRATED.update(true);
    ZagreusDatabase.DISCOVER_TV_SECTION_ORDER_MIGRATED.update(true);

    // Save device-specific settings
    if (_isTablet) {
      ZagreusDatabase.DISCOVER_IPAD_POSTER_HEIGHT.update(_posterHeight);
      ZagreusDatabase.DISCOVER_IPAD_HERO_HEIGHT.update(_heroHeight);
      ZagreusDatabase.DISCOVER_IPAD_COLUMNS_PER_ROW.update(_columnsPerRow);
    } else {
      ZagreusDatabase.DISCOVER_POSTER_HEIGHT.update(_posterHeight);
      ZagreusDatabase.DISCOVER_HERO_HEIGHT.update(_heroHeight);
      ZagreusDatabase.DISCOVER_COLUMNS_PER_ROW.update(_columnsPerRow);
    }

    ZagreusDatabase.DISCOVER_SHOW_TITLES.update(_showTitles);
    ZagreusDatabase.DISCOVER_MONOCHROME_RATINGS.update(_monochromeRatings);
    ZagreusDatabase.DISCOVER_SHOW_HERO_CAROUSEL.update(_showHeroCarousel);
    ZagreusDatabase.DISCOVER_HIDE_IN_LIBRARY_FROM_HERO
        .update(_hideInLibraryFromHero);
    ZagreusDatabase.DISCOVER_TRENDING_TIME_WINDOW.update(_trendingTimeWindow);
    ZagreusDatabase.DISCOVER_QUICK_BUTTONS.update(_quickButtons);
    setState(() => _hasChanges = false);
    widget.onHasChangesChanged?.call(_hasChanges);
    showZagInfoSnackBar(
      title: 'settings.DashboardSettingsSavedTitle'.tr(),
      message: _isTablet
          ? 'settings.DashboardSettingsSavedMessageTablet'.tr()
          : 'settings.DashboardSettingsSavedMessage'.tr(),
    );
  }

  void resetToDefaults() {
    final isTablet = _isTablet;
    setState(() {
      _movieSections = List<String>.from(_defaultMovieSections);
      _tvSections = List<String>.from(_defaultTVSections);
      // Use device-specific defaults
      _posterHeight = isTablet ? 275.0 : 225.0;
      _heroHeight = isTablet ? 550.0 : 400.0;
      _columnsPerRow = isTablet ? 4 : 3;
      _showTitles = true;
      _monochromeRatings = false;
      _showHeroCarousel = true;
      _hideInLibraryFromHero = false;
      _trendingTimeWindow = 'week';
      _quickButtons = [];
      _hasChanges = true;
    });
    widget.onHasChangesChanged?.call(_hasChanges);
  }

  void _setHasChanges() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
      widget.onHasChangesChanged?.call(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialIndex,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? ZagColours.secondary
                : ZagColours.secondaryLight,
            child: TabBar(
              indicatorColor: ZagColours.accentColor(context),
              labelColor: ZagColours.accentColor(context),
              unselectedLabelColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
              tabs: [
                Tab(text: 'settings.DashboardSettingsMoviesTab'.tr()),
                Tab(text: 'settings.DashboardSettingsShowsTab'.tr()),
                Tab(text: 'settings.DashboardSettingsOptionsTab'.tr()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [
                _buildSectionList(
                  sections: _movieSections,
                  defaults: _defaultMovieSections,
                  isMovie: true,
                ),
                _buildSectionList(
                  sections: _tvSections,
                  defaults: _defaultTVSections,
                  isMovie: false,
                ),
                _buildOptionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsTab() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Buttons section at top
          Text(
            'settings.DashboardSettingsQuickButtonsTitle'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'settings.DashboardSettingsQuickButtonsDescription'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allQuickButtonServices.map((service) {
              final isSelected = _quickButtons.contains(service);
              final displayName = _getQuickButtonDisplayName(service);
              return FilterChip(
                label: Text(displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _quickButtons.add(service);
                    } else {
                      _quickButtons.remove(service);
                    }
                    _hasChanges = true;
                  });
                  widget.onHasChangesChanged?.call(_hasChanges);
                },
                selectedColor: ZagColours.accentColor(context).withOpacity(0.3),
                checkmarkColor: ZagColours.accentColor(context),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          // Poster Height
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'settings.DashboardSettingsPosterHeight'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.black26,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _posterHeightToSizeName(_posterHeight),
                    dropdownColor: theme.brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.white,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    items: _posterSizes.keys.map((sizeName) {
                      return DropdownMenuItem<String>(
                        value: sizeName,
                        child: Text(sizeName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _posterHeight = _posterSizes[value]!;
                          _hasChanges = true;
                        });
                        widget.onHasChangesChanged?.call(_hasChanges);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'settings.DashboardSettingsHeroHeight'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.black26,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _heroHeightToSizeName(_heroHeight),
                    dropdownColor: theme.brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.white,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    items: _heroSizes.keys.map((sizeName) {
                      return DropdownMenuItem<String>(
                        value: sizeName,
                        child: Text(sizeName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _heroHeight = _heroSizes[value]!;
                          _hasChanges = true;
                        });
                        widget.onHasChangesChanged?.call(_hasChanges);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'settings.DashboardSettingsItemsPerRow'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.black26,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _columnsPerRow,
                    dropdownColor: theme.brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.white,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    items: List.generate(
                      _columnsPerRowMax - _columnsPerRowMin + 1,
                      (index) => _columnsPerRowMin + index,
                    ).map((value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _columnsPerRow = value;
                          _hasChanges = true;
                        });
                        widget.onHasChangesChanged?.call(_hasChanges);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'settings.DashboardSettingsShowTitles'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              Switch(
                value: _showTitles,
                activeColor: ZagColours.accentColor(context),
                onChanged: (value) {
                  setState(() {
                    _showTitles = value;
                    _hasChanges = true;
                  });
                  widget.onHasChangesChanged?.call(_hasChanges);
                },
              ),
            ],
          ),
          Text(
            'settings.DashboardSettingsShowTitlesDescription'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
            ),
          ),
          const SizedBox(height: 32),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'settings.DashboardSettingsMonochromeRatings'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              Switch(
                value: _monochromeRatings,
                activeColor: ZagColours.accentColor(context),
                onChanged: (value) {
                  setState(() {
                    _monochromeRatings = value;
                    _hasChanges = true;
                  });
                  widget.onHasChangesChanged?.call(_hasChanges);
                },
              ),
            ],
          ),
          Text(
            'settings.DashboardSettingsMonochromeRatingsDescription'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'settings.DashboardSettingsShowHeroCarousel'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              Switch(
                value: _showHeroCarousel,
                activeColor: ZagColours.accentColor(context),
                onChanged: (value) {
                  setState(() {
                    _showHeroCarousel = value;
                    _hasChanges = true;
                  });
                  widget.onHasChangesChanged?.call(_hasChanges);
                },
              ),
            ],
          ),
          Text(
            'settings.DashboardSettingsShowHeroCarouselDescription'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'settings.DashboardSettingsHideInLibraryFromHero'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              Switch(
                value: _hideInLibraryFromHero,
                activeColor: ZagColours.accentColor(context),
                onChanged: (value) {
                  setState(() {
                    _hideInLibraryFromHero = value;
                    _hasChanges = true;
                  });
                  widget.onHasChangesChanged?.call(_hasChanges);
                },
              ),
            ],
          ),
          Text(
            'settings.DashboardSettingsHideInLibraryFromHeroDescription'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'settings.DashboardSettingsTrendingTimeframe'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              ChoiceChip(
                label: Text('settings.DashboardSettingsTrendingToday'.tr()),
                selected: _trendingTimeWindow == 'day',
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _trendingTimeWindow = 'day';
                    _hasChanges = true;
                  });
                  widget.onHasChangesChanged?.call(_hasChanges);
                },
              ),
              ChoiceChip(
                label: Text('settings.DashboardSettingsTrendingThisWeek'.tr()),
                selected: _trendingTimeWindow == 'week',
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _trendingTimeWindow = 'week';
                    _hasChanges = true;
                  });
                  widget.onHasChangesChanged?.call(_hasChanges);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'settings.DashboardSettingsTrendingDescription'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          ZagButton(
            type: ZagButtonType.TEXT,
            text: 'settings.DashboardSettingsResetDefaults'.tr(),
            icon: Icons.restart_alt_rounded,
            color: ZagColours.currentAccent,
            onTap: resetToDefaults,
          ),
          const SizedBox(height: 8),
          Text(
            'settings.DashboardSettingsResetDefaultsDescription'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionList({
    required List<String> sections,
    required List<String> defaults,
    required bool isMovie,
  }) {
    final theme = Theme.of(context);
    // Filter out AI sections if user doesn't have AI access
    final availableSections = defaults
        .where((section) => !sections.contains(section))
        .where((section) => _hasAiAccess || !_aiSections.contains(section))
        .toList();
    // Also filter display of AI sections from current list if no AI access
    final displaySections = _hasAiAccess
        ? sections
        : sections.where((s) => !_aiSections.contains(s)).toList();

    return CustomScrollView(
      slivers: [
        if (displaySections.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _emptySectionsPlaceholder(isMovie: isMovie),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            sliver: SliverReorderableList(
              itemCount: displaySections.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = displaySections.removeAt(oldIndex);
                  // Also update the original sections list
                  sections.remove(item);
                  // Find the right position in original list
                  if (newIndex >= displaySections.length) {
                    sections.add(item);
                  } else {
                    final targetSection = displaySections[newIndex];
                    final targetIndex = sections.indexOf(targetSection);
                    sections.insert(targetIndex, item);
                  }
                  displaySections.insert(newIndex, item);
                  _setHasChanges();
                });
              },
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final double elevation =
                        Curves.easeInOut.transform(animation.value) * 4.0;
                    return Material(
                      elevation: elevation,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                      shadowColor: Colors.black.withOpacity(0.3),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final section = displaySections[index];
                final name = _sectionName(section);

                return Container(
                  key: ValueKey(section),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? ZagColours.secondary
                        : ZagColours.secondaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white10
                          : Colors.black12,
                      width: 1,
                    ),
                    ),
                  child: ListTile(
                    leading: Icon(
                      _getSectionIcon(section),
                      color: ZagColours.accentColor(context),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          tooltip:
                              'settings.DashboardSettingsRemoveSectionTooltip'
                                  .tr(),
                          onPressed: () => _removeSection(sections, section),
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: Icon(
                            Icons.drag_handle_rounded,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white30
                                : Colors.black26,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
            child: ZagButton.text(
              text: availableSections.isEmpty
                  ? 'settings.DashboardSettingsAllSectionsAdded'.tr()
                  : 'settings.DashboardSettingsAddSection'.tr(),
              icon: availableSections.isEmpty ? null : Icons.add_rounded,
              color: ZagColours.currentAccent,
              onTap: availableSections.isEmpty
                  ? null
                  : () => _showAddSectionSheet(
                        isMovie: isMovie,
                        defaults: defaults,
                      ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _customSectionsSettingsArea(
            mediaType: isMovie ? 'movie' : 'tv',
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _customSectionsSettingsArea({required String mediaType}) {
    if (!_customSectionsEnabled) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final future = mediaType == 'movie'
        ? _customMovieSectionsFuture
        : _customTVSectionsFuture;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings.DashboardSettingsCustomSectionsTitle'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'settings.DashboardSettingsCustomSectionsDescription'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          ZagButton.text(
            text: 'settings.DashboardSettingsCreateCustomSection'.tr(),
            icon: Icons.add_rounded,
            color: ZagColours.currentAccent,
            onTap: () => _showCreateCustomSectionDialog(mediaType),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<CustomSectionConfig>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final sections = snapshot.data ?? const <CustomSectionConfig>[];
              if (sections.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'settings.DashboardSettingsNoCustomSections'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black45,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  for (final config in sections)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? ZagColours.secondary
                            : ZagColours.secondaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white10
                              : Colors.black12,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.auto_awesome_rounded,
                          color: ZagColours.accentColor(context),
                        ),
                        title: Text(
                          config.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          config.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'settings.DashboardSettingsRegenerate'
                                  .tr(),
                              icon: const Icon(Icons.refresh_rounded),
                              onPressed: () =>
                                  _regenerateCustomSectionFromSettings(config),
                            ),
                            IconButton(
                              tooltip:
                                  'settings.DashboardSettingsEdit'.tr(),
                              icon: const Icon(Icons.edit_rounded),
                              onPressed: () =>
                                  _showEditCustomSectionDialog(config),
                            ),
                            IconButton(
                              tooltip:
                                  'settings.DashboardSettingsDelete'.tr(),
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: Colors.red,
                              onPressed: () =>
                                  _deleteCustomSectionFromSettings(config),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _refreshCustomSectionsFutures(String mediaType) {
    if (!_customSectionsEnabled) return;
    setState(() {
      if (mediaType == 'movie') {
        _customMovieSectionsFuture =
            CustomSectionsService().syncFromSupabase(mediaType: 'movie');
      } else {
        _customTVSectionsFuture =
            CustomSectionsService().syncFromSupabase(mediaType: 'tv');
      }
    });
  }

  Future<void> _showCreateCustomSectionDialog(String mediaType) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'settings.DashboardSettingsCreateCustomSectionDialogTitle'.tr(),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'settings.DashboardSettingsSectionTitleLabel'.tr(),
                  border: const OutlineInputBorder(),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'settings.DashboardSettingsDescriptionLabel'.tr(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: 300,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('zagreus.Cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty) {
                showZagErrorSnackBar(
                  title: 'settings.DashboardSettingsMissingFieldsTitle'.tr(),
                  error: 'settings.DashboardSettingsMissingFieldsMessage'.tr(),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text('settings.DashboardSettingsCreateAction'.tr()),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final config = await CustomSectionsService().createSection(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        mediaType: mediaType,
      );

      try {
        await CustomSectionsService().generateRecommendations(
          sectionId: config.id,
          title: config.title,
          description: config.description,
          mediaType: config.mediaType,
          force: true,
        );
        showZagInfoSnackBar(
          title: 'settings.DashboardSettingsCustomSectionCreatedTitle'.tr(),
          message:
              'settings.DashboardSettingsGeneratingRecommendationsMessage'.tr(),
        );
      } catch (e) {
        // Best-effort; recommendations can still be fetched from the Dashboard.
      }

      _refreshCustomSectionsFutures(mediaType);
    }
  }

  Future<void> _showEditCustomSectionDialog(CustomSectionConfig config) async {
    final titleController = TextEditingController(text: config.title);
    final descriptionController =
        TextEditingController(text: config.description);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('settings.DashboardSettingsEditCustomSectionDialogTitle'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'settings.DashboardSettingsSectionTitleLabel'.tr(),
                  border: const OutlineInputBorder(),
                ),
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'settings.DashboardSettingsDescriptionLabel'.tr(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: 300,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('zagreus.Cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty) {
                showZagErrorSnackBar(
                  title: 'settings.DashboardSettingsMissingFieldsTitle'.tr(),
                  error: 'settings.DashboardSettingsMissingFieldsMessage'.tr(),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text('settings.DashboardSettingsSaveAction'.tr()),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final updatedConfig = CustomSectionConfig(
        id: config.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        mediaType: config.mediaType,
        createdAt: config.createdAt,
        lastGeneratedAt: config.lastGeneratedAt,
      );

      await CustomSectionsService().updateSection(updatedConfig);
      _refreshCustomSectionsFutures(config.mediaType);
    }
  }

  Future<void> _deleteCustomSectionFromSettings(CustomSectionConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('settings.DashboardSettingsDeleteCustomSectionDialogTitle'.tr()),
        content: Text(
          'settings.DashboardSettingsDeleteCustomSectionDialogMessage'
              .tr(args: [config.title]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('zagreus.Cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('zagreus.Delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await CustomSectionsService().deleteSection(config.id);
      _refreshCustomSectionsFutures(config.mediaType);
    }
  }

  Future<void> _regenerateCustomSectionFromSettings(
    CustomSectionConfig config,
  ) async {
    showZagInfoSnackBar(
      title: 'settings.DashboardSettingsRegeneratingTitle'.tr(),
      message: 'settings.DashboardSettingsGeneratingRecommendationsMessage'
          .tr(),
    );

    final result = await CustomSectionsService().generateRecommendations(
      sectionId: config.id,
      title: config.title,
      description: config.description,
      mediaType: config.mediaType,
      force: true,
    );

    if (!mounted) return;

    if (!result.success) {
      showZagErrorSnackBar(
        title: 'settings.DashboardSettingsFailedToRegenerateTitle'.tr(),
        error: result.errorMessage ??
            'settings.DashboardSettingsUnknownError'.tr(),
      );
      return;
    }

    showZagInfoSnackBar(
      title: 'settings.DashboardSettingsUpdatedTitle'.tr(),
      message: 'settings.DashboardSettingsRecommendationsRefreshed'.tr(),
    );
    _refreshCustomSectionsFutures(config.mediaType);
  }

  Widget _emptySectionsPlaceholder({required bool isMovie}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 48,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white24
                  : Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              isMovie
                  ? 'settings.DashboardSettingsEmptyMovieSections'.tr()
                  : 'settings.DashboardSettingsEmptyTVSections'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'settings.DashboardSettingsEmptySectionsHelp'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeSection(List<String> sections, String section) {
    setState(() {
      sections.remove(section);
      _setHasChanges();
    });
  }

  void _showAddSectionSheet({
    required bool isMovie,
    required List<String> defaults,
  }) {
    final sections = isMovie ? _movieSections : _tvSections;
    // Filter out AI sections if user doesn't have AI access
    final available = defaults
        .where((section) => !sections.contains(section))
        .where((section) => _hasAiAccess || !_aiSections.contains(section))
        .toList();

    if (available.isEmpty) {
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                'settings.DashboardSettingsAddSection'.tr(),
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  itemBuilder: (context, index) {
                    final section = available[index];
                    final name = _sectionName(section);
                    return ListTile(
                      leading: Icon(
                        _getSectionIcon(section),
                        color: ZagColours.accentColor(context),
                      ),
                      title: Text(name),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        setState(() {
                          sections.add(section);
                          _setHasChanges();
                        });
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemCount: available.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getSectionIcon(String section) {
    switch (section) {
      case 'recently_downloaded':
      case 'recently_downloaded_shows':
        return Icons.download_done_rounded;
      case 'recommended':
        return Icons.recommend_rounded;
      case 'missing':
        return Icons.error_outline_rounded;
      case 'downloading_soon':
        return Icons.schedule_rounded;
      case 'studios':
        return Icons.movie_filter_rounded;
      case 'movie_genres':
        return Icons.category_rounded;
      case 'popular_movies':
      case 'popular_tv_shows':
        return Icons.star_rounded;
      case 'recently_released_movies':
        return Icons.new_releases_rounded;
      case 'popular_people':
        return Icons.person_rounded;
      case 'deep_cuts':
        return Icons.auto_awesome_rounded;
      case 'magic_movies':
        return Icons.auto_fix_high_rounded;
      case 'magic_movies_cast_crew':
        return Icons.groups_rounded;
      case 'magic_people':
        return Icons.person_search_rounded;
      case 'airing_next':
        return Icons.live_tv_rounded;
      case 'networks':
        return Icons.tv_rounded;
      case 'tv_genres':
        return Icons.category_rounded;
      case 'trending_new_tv_shows':
        return Icons.trending_up_rounded;
      case 'most_anticipated':
        return Icons.favorite_rounded;
      case 'most_anticipated_movies':
        return Icons.favorite_rounded;
      case 'up_next':
        return Icons.auto_awesome_rounded;
      case 'magic_shows':
        return Icons.auto_fix_high_rounded;
      case 'magic_shows_cast_crew':
        return Icons.groups_rounded;
      default:
        return Icons.view_list_rounded;
    }
  }
}

Future<bool?> showDashboardSectionsEditorSheet(
  BuildContext context, {
  int initialIndex = 0,
}) {
  final editorKey = GlobalKey<DiscoverSectionsEditorState>();
  bool hasChanges = false;
  bool isSaving = false;

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).canvasColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final mediaQuery = MediaQuery.of(sheetContext);
      final height = mediaQuery.size.height * 0.75;

      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> handleSave() async {
            if (!hasChanges || isSaving) return;
            final state = editorKey.currentState;
            if (state == null) return;
            setModalState(() => isSaving = true);
            await state.saveChanges();
            setModalState(() => isSaving = false);
            Navigator.of(sheetContext).pop(true);
          }

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: mediaQuery.viewInsets.bottom,
              ),
              child: SizedBox(
                height: height,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            Theme.of(sheetContext).brightness == Brightness.dark
                                ? Colors.white24
                                : Colors.black26,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Row(
                        children: [
                          Text(
                            'settings.DashboardSettingsTitle'.tr(),
                            style: Theme.of(sheetContext)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.save_rounded),
                            tooltip:
                                'settings.DashboardSettingsSaveOrderTooltip'
                                    .tr(),
                            color: hasChanges
                                ? ZagColours.currentAccent
                                : Colors.grey,
                            onPressed:
                                (!hasChanges || isSaving) ? null : handleSave,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () =>
                                Navigator.of(sheetContext).pop(false),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: DiscoverSectionsEditor(
                        key: editorKey,
                        onHasChangesChanged: (value) =>
                            setModalState(() => hasChanges = value),
                        initialIndex: initialIndex,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
