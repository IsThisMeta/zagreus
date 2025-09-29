import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class DiscoverSectionsRoute extends StatefulWidget {
  const DiscoverSectionsRoute({Key? key}) : super(key: key);

  @override
  State<DiscoverSectionsRoute> createState() => _State();
}

class _State extends State<DiscoverSectionsRoute> {
  // Default section order for movies
  static const List<String> _defaultMovieSections = [
    'recently_downloaded',
    'recommended',
    'missing',
    'downloading_soon',
    'popular_movies',
    'popular_people',
  ];

  // Default section order for TV shows
  static const List<String> _defaultTVSections = [
    'recently_downloaded_shows',
    'airing_next',
    'popular_tv_shows',
    'trending_new_tv_shows',
    'most_anticipated',
  ];

  // Section display names
  static const Map<String, String> _sectionNames = {
    'recently_downloaded': 'Recently Downloaded',
    'recommended': 'Recommended',
    'missing': 'Missing',
    'downloading_soon': 'Downloading Soon',
    'popular_movies': 'Popular Movies',
    'popular_people': 'Popular People',
    'recently_downloaded_shows': 'Recently Downloaded',
    'airing_next': 'Airing Next',
    'popular_tv_shows': 'Popular TV Shows',
    'trending_new_tv_shows': 'Trending New',
    'most_anticipated': 'Most Anticipated',
  };

  late List<String> _movieSections;
  late List<String> _tvSections;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSectionOrder();
  }

  void _loadSectionOrder() {
    // Load saved order or use defaults
    final savedMovieOrder = ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.read() as List;
    final savedTVOrder = ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.read() as List;

    _movieSections = savedMovieOrder.isNotEmpty
        ? List<String>.from(savedMovieOrder)
        : List<String>.from(_defaultMovieSections);

    _tvSections = savedTVOrder.isNotEmpty
        ? List<String>.from(savedTVOrder)
        : List<String>.from(_defaultTVSections);
  }

  void _saveChanges() {
    ZagreusDatabase.DISCOVER_MOVIES_SECTION_ORDER.update(_movieSections);
    ZagreusDatabase.DISCOVER_TV_SECTION_ORDER.update(_tvSections);
    setState(() {
      _hasChanges = false;
    });
    showZagInfoSnackBar(
      title: 'Section Order Saved',
      message: 'Discover sections have been reordered',
    );
  }

  void _resetToDefaults() {
    setState(() {
      _movieSections = List<String>.from(_defaultMovieSections);
      _tvSections = List<String>.from(_defaultTVSections);
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: GlobalKey<ScaffoldState>(),
      appBar: ZagAppBar(
        title: 'Discover Sections',
        actions: [
          if (_hasChanges)
            IconButton(
              icon: Icon(Icons.save_rounded),
              onPressed: _saveChanges,
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'reset') {
                _resetToDefaults();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset',
                child: Text('Reset to Defaults'),
              ),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
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
                unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                tabs: [
                  Tab(text: 'Movies'),
                  Tab(text: 'TV Shows'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSectionList(_movieSections, true),
                  _buildSectionList(_tvSections, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionList(List<String> sections, bool isMovies) {
    return ReorderableListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: sections.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = sections.removeAt(oldIndex);
          sections.insert(newIndex, item);
          _hasChanges = true;
        });
      },
      itemBuilder: (context, index) {
        final section = sections[index];
        final name = _sectionNames[section] ?? section;

        return Container(
          key: ValueKey(section),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              style: TextStyle(
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