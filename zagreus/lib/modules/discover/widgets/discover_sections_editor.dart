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
    'popular_people',
    'deep_cuts',
  ];

  static const List<String> _defaultTVSections = [
    'recently_downloaded_shows',
    'airing_next',
    'popular_tv_shows',
    'trending_new_tv_shows',
    'most_anticipated',
  ];

  static const Map<String, String> _sectionNames = {
    'recently_downloaded': 'Recently Downloaded',
    'recommended': 'Recommended',
    'missing': 'Missing',
    'downloading_soon': 'Downloading Soon',
    'popular_movies': 'Popular Movies',
    'popular_people': 'Popular People',
    'deep_cuts': 'Deep Cuts',
    'recently_downloaded_shows': 'Recently Downloaded',
    'airing_next': 'Airing Next',
    'popular_tv_shows': 'Popular TV Shows',
    'trending_new_tv_shows': 'Trending New',
    'most_anticipated': 'Most Anticipated',
  };

  late List<String> _movieSections;
  late List<String> _tvSections;
  bool _hasChanges = false;

  bool get hasChanges => _hasChanges;

  @override
  void initState() {
    super.initState();
    _loadSectionOrder();
  }

  void _loadSectionOrder() {
    final savedMovieOrder =
        ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.read() as List;
    final savedTVOrder = ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.read() as List;

    _movieSections = savedMovieOrder.isNotEmpty
        ? List<String>.from(savedMovieOrder)
        : List<String>.from(_defaultMovieSections);

    _tvSections = savedTVOrder.isNotEmpty
        ? List<String>.from(savedTVOrder)
        : List<String>.from(_defaultTVSections);
  }

  Future<void> saveChanges() async {
    if (!_hasChanges) {
      return;
    }
    ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.update(_movieSections);
    ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.update(_tvSections);
    setState(() => _hasChanges = false);
    widget.onHasChangesChanged?.call(_hasChanges);
    showZagInfoSnackBar(
      title: 'Section Order Saved',
      message: 'Discover sections have been reordered',
    );
  }

  void resetToDefaults() {
    setState(() {
      _movieSections = List<String>.from(_defaultMovieSections);
      _tvSections = List<String>.from(_defaultTVSections);
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
      length: 2,
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
                Tab(text: 'TV Shows'),
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
              ],
            ),
          ),
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
      default:
        return Icons.view_list_rounded;
    }
  }
}

Future<bool?> showDiscoverSectionsEditorSheet(BuildContext context) {
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

          void handleReset() {
            if (isSaving) return;
            editorKey.currentState?.resetToDefaults();
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
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                      child: Row(
                        children: [
                          Text(
                            'Discover Sections',
                            style: Theme.of(sheetContext)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.restart_alt_rounded),
                            tooltip: 'Reset to Defaults',
                            onPressed:
                                hasChanges && !isSaving ? handleReset : null,
                          ),
                          if (isSaving)
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.blueAccent,
                                  ),
                                ),
                              ),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.save_rounded),
                              tooltip: 'Save Order',
                              color: hasChanges
                                  ? ZagColours.currentAccent
                                  : Colors.grey,
                              onPressed: hasChanges ? handleSave : null,
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
