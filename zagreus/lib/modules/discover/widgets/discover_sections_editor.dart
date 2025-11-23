import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class DiscoverSectionsEditor extends StatefulWidget {
  const DiscoverSectionsEditor({
    super.key,
    this.onHasChangesChanged,
  });

  final ValueChanged<bool>? onHasChangesChanged;

  @override
  DiscoverSectionsEditorState createState() => DiscoverSectionsEditorState();
}

class DiscoverSectionsEditorState extends State<DiscoverSectionsEditor> {
  static const List<String> _defaultMovieSections = [
    'recently_downloaded',
    'recommended',
    'missing',
    'downloading_soon',
    'popular_movies',
    'recently_released_movies',
    'most_anticipated_movies',
    'popular_people',
    'deep_cuts',
  ];

  static const List<String> _defaultTVSections = [
    'recently_downloaded_shows',
    'airing_next',
    'popular_tv_shows',
    'trending_new_tv_shows',
    'most_anticipated',
    'up_next',
  ];

  static const double _posterHeightMin = 150.0;
  static const double _posterHeightMax = 250.0;
  static const double _heroHeightMin = 300.0;
  static const double _heroHeightMax = 500.0;
  static const int _columnsPerRowMin = 2;
  static const int _columnsPerRowMax = 4;

  static const Map<String, String> _sectionNames = {
    'recently_downloaded': 'Recently Downloaded',
    'recommended': 'Recommended',
    'missing': 'Missing',
    'downloading_soon': 'Downloading Soon',
    'popular_movies': 'Popular Movies',
    'recently_released_movies': 'Recently Released',
    'most_anticipated_movies': 'Most Anticipated Movies',
    'popular_people': 'Popular People',
    'deep_cuts': 'Deep Cuts',
    'recently_downloaded_shows': 'Recently Downloaded',
    'airing_next': 'Airing Next',
    'popular_tv_shows': 'Popular TV Shows',
    'trending_new_tv_shows': 'Trending New',
    'most_anticipated': 'Most Anticipated',
    'up_next': 'Up Next',
  };

  late List<String> _movieSections;
  late List<String> _tvSections;
  bool _hasChanges = false;
  double _posterHeight = 200.0;
  double _heroHeight = 400.0;
  int _columnsPerRow = 3;
  bool _showTitles = true;
  bool _monochromeRatings = false;
  bool _showHeroCarousel = true;
  String _trendingTimeWindow = 'day';

  bool get hasChanges => _hasChanges;

  @override
  void initState() {
    super.initState();
    _loadSectionOrder();
  }

  void _loadSectionOrder() {
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

    // Load poster height
    final savedHeight = ZagreusDatabase.DISCOVER_POSTER_HEIGHT.read();
    if (savedHeight != null &&
        savedHeight >= _posterHeightMin &&
        savedHeight <= _posterHeightMax) {
      _posterHeight = savedHeight;
    }

    final savedHeroHeight = ZagreusDatabase.DISCOVER_HERO_HEIGHT.read();
    if (savedHeroHeight != null &&
        savedHeroHeight >= _heroHeightMin &&
        savedHeroHeight <= _heroHeightMax) {
      _heroHeight = savedHeroHeight;
    }

    // Load columns per row
    final savedColumns = ZagreusDatabase.DISCOVER_COLUMNS_PER_ROW.read();
    if (savedColumns != null &&
        savedColumns >= _columnsPerRowMin &&
        savedColumns <= _columnsPerRowMax) {
      _columnsPerRow = savedColumns;
    }
    
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

    final savedTimeWindow =
        ZagreusDatabase.DISCOVER_TRENDING_TIME_WINDOW.read();
    if (savedTimeWindow == 'day' || savedTimeWindow == 'week') {
      _trendingTimeWindow = savedTimeWindow;
    }
  }

  Future<void> saveChanges() async {
    if (!_hasChanges) {
      return;
    }
    ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.update(_movieSections);
    ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.update(_tvSections);
    ZagreusDatabase.DISCOVER_POSTER_HEIGHT.update(_posterHeight);
    ZagreusDatabase.DISCOVER_HERO_HEIGHT.update(_heroHeight);
    ZagreusDatabase.DISCOVER_COLUMNS_PER_ROW.update(_columnsPerRow);
    ZagreusDatabase.DISCOVER_SHOW_TITLES.update(_showTitles);
    ZagreusDatabase.DISCOVER_MONOCHROME_RATINGS.update(_monochromeRatings);
    ZagreusDatabase.DISCOVER_SHOW_HERO_CAROUSEL.update(_showHeroCarousel);
    ZagreusDatabase.DISCOVER_TRENDING_TIME_WINDOW
        .update(_trendingTimeWindow);
    setState(() => _hasChanges = false);
    widget.onHasChangesChanged?.call(_hasChanges);
    showZagInfoSnackBar(
      title: 'Section Order Saved',
      message: 'Dashboard sections have been reordered',
    );
  }

  void resetToDefaults() {
    setState(() {
      _movieSections = List<String>.from(_defaultMovieSections);
      _tvSections = List<String>.from(_defaultTVSections);
      _posterHeight = (_posterHeightMin + _posterHeightMax) / 2;
      _heroHeight = (_heroHeightMin + _heroHeightMax) / 2;
      _columnsPerRow =
          ((_columnsPerRowMin + _columnsPerRowMax) / 2).round();
      _showTitles = true;
      _monochromeRatings = false;
      _showHeroCarousel = true;
      _trendingTimeWindow = 'day';
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
              tabs: const [
                Tab(text: 'Movies'),
                Tab(text: 'Shows'),
                Tab(text: 'Config'),
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
                _buildConfigTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTab() {
    final theme = Theme.of(context);
    final infoRow = Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: theme.brightness == Brightness.dark
              ? Colors.white54
              : Colors.black54,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Changes to these layout settings take effect after restarting the app.',
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black54,
            ),
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          infoRow,
          const SizedBox(height: 16),
          Text(
            'Poster Height',
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
            '${_posterHeight.round()} pixels',
            style: TextStyle(
              fontSize: 14,
              color: theme.brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
          Slider(
            value: _posterHeight,
            min: _posterHeightMin,
            max: _posterHeightMax,
            divisions: 20,
            activeColor: ZagColours.accentColor(context),
            inactiveColor: theme.brightness == Brightness.dark
                ? Colors.white24
                : Colors.black26,
            onChanged: (value) {
              setState(() {
                _posterHeight = value;
                _hasChanges = true;
              });
              widget.onHasChangesChanged?.call(_hasChanges);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Adjust the height of poster images in the Dashboard view.',
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Hero Carousel Height',
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
            '${_heroHeight.round()} pixels',
            style: TextStyle(
              fontSize: 14,
              color: theme.brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
          Slider(
            value: _heroHeight,
            min: _heroHeightMin,
            max: _heroHeightMax,
            divisions: 20,
            activeColor: ZagColours.accentColor(context),
            inactiveColor: theme.brightness == Brightness.dark
                ? Colors.white24
                : Colors.black26,
            onChanged: (value) {
              setState(() {
                _heroHeight = value;
                _hasChanges = true;
              });
              widget.onHasChangesChanged?.call(_hasChanges);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Control the size of the large hero banner at the top of Dashboard.',
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Items Per Row',
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
            '$_columnsPerRow columns',
            style: TextStyle(
              fontSize: 14,
              color: theme.brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
          Slider(
            value: _columnsPerRow.toDouble(),
            min: _columnsPerRowMin.toDouble(),
            max: _columnsPerRowMax.toDouble(),
            divisions: _columnsPerRowMax - _columnsPerRowMin,
            activeColor: ZagColours.accentColor(context),
            inactiveColor: theme.brightness == Brightness.dark
                ? Colors.white24
                : Colors.black26,
            onChanged: (value) {
              setState(() {
                _columnsPerRow = value.round();
                _hasChanges = true;
              });
              widget.onHasChangesChanged?.call(_hasChanges);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Controls how many posters fit horizontally in the full Dashboard grids for movies and shows.',
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
                'Show Titles on Posters',
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
            'Toggle titles on or off for movie and show posters. Restart required.',
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
                'Monochrome Ratings',
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
            'Display rating badges in white instead of colored. Restart required.',
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
                'Show Hero Carousel',
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
            'Toggle the auto-scrolling hero carousel at the top of Movies and TV Shows tabs.',
            style: TextStyle(
              fontSize: 12,
              color: theme.brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Trending Timeframe',
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
                label: const Text('Today'),
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
                label: const Text('This Week'),
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
            'Select the default timeframe for trending Dashboard recommendations.',
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
            text: 'Reset to Defaults',
            icon: Icons.restart_alt_rounded,
            color: ZagColours.currentAccent,
            onTap: resetToDefaults,
          ),
          const SizedBox(height: 8),
          Text(
            'Resets movie & show sections plus all layout sliders back to their defaults.',
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
    final availableSections =
        defaults.where((section) => !sections.contains(section)).toList();

    return Column(
      children: [
        Expanded(
          child: sections.isEmpty
              ? _emptySectionsPlaceholder(isMovie: isMovie)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: sections.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = sections.removeAt(oldIndex);
                      sections.insert(newIndex, item);
                      _setHasChanges();
                    });
                  },
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    final name = _sectionNames[section] ?? section;

                    return Container(
                      key: ValueKey(section),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
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
                              tooltip: 'Remove Section',
                              onPressed: () =>
                                  _removeSection(sections, section),
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
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
          child: ZagButton.text(
            text: availableSections.isEmpty
                ? 'All Sections Added'
                : 'Add Section',
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
      ],
    );
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
                  ? 'No movie sections are currently shown.'
                  : 'No TV sections are currently shown.',
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
              'Use the button below to add sections back.',
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
    final available =
        defaults.where((section) => !sections.contains(section)).toList();

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
                'Add Section',
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
                    final name = _sectionNames[section] ?? section;
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
      case 'popular_movies':
      case 'popular_tv_shows':
        return Icons.star_rounded;
      case 'recently_released_movies':
        return Icons.new_releases_rounded;
      case 'popular_people':
        return Icons.person_rounded;
      case 'deep_cuts':
        return Icons.auto_awesome_rounded;
      case 'airing_next':
        return Icons.live_tv_rounded;
      case 'trending_new_tv_shows':
        return Icons.trending_up_rounded;
      case 'most_anticipated':
        return Icons.favorite_rounded;
      case 'most_anticipated_movies':
        return Icons.favorite_rounded;
      case 'up_next':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.view_list_rounded;
    }
  }
}

Future<bool?> showDashboardSectionsEditorSheet(BuildContext context) {
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
                            'Dashboard Sections',
                            style: Theme.of(sheetContext)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.save_rounded),
                            tooltip: 'Save Order',
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
