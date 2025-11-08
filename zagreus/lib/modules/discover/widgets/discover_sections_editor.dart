import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class DiscoverSectionsEditor extends StatefulWidget {
  const DiscoverSectionsEditor({
    super.key,
    this.onHasChangesChanged,
    this.showInlineSaveButton = false,
    this.showResetButton = false,
    this.onSaved,
  });

  final ValueChanged<bool>? onHasChangesChanged;
  final bool showInlineSaveButton;
  final bool showResetButton;
  final VoidCallback? onSaved;

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

  void saveChanges() {
    if (!_hasChanges) {
      widget.onSaved?.call();
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
    widget.onSaved?.call();
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
                _buildSectionList(_movieSections),
                _buildSectionList(_tvSections),
              ],
            ),
          ),
          if (widget.showInlineSaveButton) _buildInlineActions(context),
        ],
      ),
    );
  }

  Widget _buildInlineActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ZagUI.DEFAULT_MARGIN_SIZE,
        12,
        ZagUI.DEFAULT_MARGIN_SIZE,
        4,
      ),
      child: Column(
        children: [
          ZagButton(
            type: ZagButtonType.TEXT,
            text: 'Save Order',
            icon: Icons.save_rounded,
            color: _hasChanges ? ZagColours.currentAccent : Colors.grey,
            onTap: _hasChanges ? saveChanges : null,
          ),
          if (widget.showResetButton)
            TextButton.icon(
              onPressed: resetToDefaults,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Reset to Defaults'),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionList(List<String> sections) {
    return ReorderableListView.builder(
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
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? ZagColours.secondary
                : ZagColours.secondaryLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
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
            trailing: ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle_rounded,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white30
                    : Colors.black26,
              ),
            ),
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
                    color: Theme.of(sheetContext).brightness == Brightness.dark
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
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DiscoverSectionsEditor(
                    key: editorKey,
                    showInlineSaveButton: true,
                    showResetButton: true,
                    onSaved: () => Navigator.of(sheetContext).pop(true),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
