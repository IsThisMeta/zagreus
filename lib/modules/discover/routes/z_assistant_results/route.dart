import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/services/staged_operations_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/discover/routes/person_details/route.dart';

class ZAssistantResultsRoute extends StatefulWidget {
  final String stageId;
  final Function(int tmdbId, String title)? onMovieTap;
  final Function(int tmdbId, String title, int? tvdbId)? onShowTap;

  const ZAssistantResultsRoute({
    super.key,
    required this.stageId,
    this.onMovieTap,
    this.onShowTap,
  });

  @override
  State<ZAssistantResultsRoute> createState() => _ZAssistantResultsRouteState();
}

class _ZAssistantResultsRouteState extends State<ZAssistantResultsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _service = StagedOperationsService();

  StagedOperation? _operation;
  bool _loading = true;
  String? _error;

  // Multi-select state
  final Set<int> _selectedIndices = {};
  bool _isSelectionMode = false;

  // Radarr/Sonarr config state
  int? _selectedRadarrQualityProfileId;
  String? _selectedRadarrQualityProfileName;
  String? _selectedRadarrRootFolder;
  bool _radarrSearchForMissing = true;

  int? _selectedSonarrQualityProfileId;
  String? _selectedSonarrQualityProfileName;
  String? _selectedSonarrRootFolder;
  SonarrSeriesMonitorType _sonarrMonitorType = SonarrSeriesMonitorType.ALL;
  SonarrSeriesType _sonarrSeriesType = SonarrSeriesType.STANDARD;
  bool _sonarrSearchForMissing = true;
  bool _sonarrSearchForCutoffUnmet = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _loadData();
  }

  void _loadSavedSettings() {
    _selectedRadarrQualityProfileId = ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.read();
    _selectedRadarrQualityProfileName = ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.read();
    _selectedRadarrRootFolder = ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.read();
    _radarrSearchForMissing = ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.read() ?? true;

    _selectedSonarrQualityProfileId = ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID.read();
    _selectedSonarrQualityProfileName = ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_NAME.read();
    _selectedSonarrRootFolder = ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.read();
    final savedMonitorType = ZagreusDatabase.Z_ASSISTANT_SONARR_MONITOR_TYPE.read();
    _sonarrMonitorType = SonarrSeriesMonitorType.values.firstWhere(
      (type) => type.value == savedMonitorType,
      orElse: () => SonarrSeriesMonitorType.ALL,
    );
    final savedSeriesType = ZagreusDatabase.Z_ASSISTANT_SONARR_SERIES_TYPE.read();
    _sonarrSeriesType = SonarrSeriesType.values.firstWhere(
      (type) => type.value == savedSeriesType,
      orElse: () => SonarrSeriesType.STANDARD,
    );
    _sonarrSearchForMissing = ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.read() ?? true;
    _sonarrSearchForCutoffUnmet = ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_CUTOFF_UNMET.read() ?? false;
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedIndices.clear();
      _isSelectionMode = false;
    });

    try {
      final operation = await _service.fetchStagedOperation(widget.stageId);

      if (operation == null) {
        setState(() {
          _error = 'Failed to load Z Assistant results';
          _loading = false;
        });
        return;
      }

      setState(() {
        _operation = operation;
        _loading = false;
      });
    } catch (e, stack) {
      ZagLogger().error('Error loading Z Assistant results', e, stack);
      setState(() {
        _error = 'Error loading results: $e';
        _loading = false;
      });
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIndices.clear();
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIndices.length == _operation!.items.length) {
        _selectedIndices.clear();
      } else {
        _selectedIndices.clear();
        for (int i = 0; i < _operation!.items.length; i++) {
          _selectedIndices.add(i);
        }
      }
    });
  }

  void _toggleItemSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(context),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    if (_isSelectionMode) {
      // Use standard AppBar for selection mode to show custom leading
      return AppBar(
        title: Text('${_selectedIndices.length} selected'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _toggleSelectionMode,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showMergedSettings,
            tooltip: 'Settings',
          ),
          IconButton(
            icon: Icon(
              _selectedIndices.length == _operation?.items.length
                  ? Icons.deselect
                  : Icons.select_all,
            ),
            onPressed: _toggleSelectAll,
            tooltip: _selectedIndices.length == _operation?.items.length
                ? 'Deselect All'
                : 'Select All',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _selectedIndices.isEmpty ? null : _addSelectedToLibrary,
            tooltip: 'Add to Library',
          ),
        ],
      );
    }

    return ZagAppBar(
      title: 'Results',
      actions: [
        IconButton(
          icon: const Icon(Icons.checklist),
          onPressed: _toggleSelectionMode,
          tooltip: 'Select Items',
        ),
      ],
    );
  }

  Widget _body() {
    if (_loading) {
      return Center(
        child: ZagLoader(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Error Loading Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_operation == null || _operation!.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Z Assistant couldn\'t find any matches',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    // Z Assistant always uses 2 columns, ignoring dashboard setting
    const fixedColumns = 2;
    const horizontalPadding = 16.0;
    const gridSpacing = 12.0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        controller: scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 20,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: fixedColumns,
          // Slightly taller cards to give title/description breathing room
          childAspectRatio: 0.52,
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridSpacing,
        ),
        itemCount: _operation!.items.length,
        itemBuilder: (context, index) {
          final item = _operation!.items[index];
          return _buildMediaItem(item, index);
        },
      ),
    );
  }

  Widget _buildMediaItem(StagedMediaItem item, int index) {
    final isSelected = _selectedIndices.contains(index);

    // Build person card differently
    if (item.isPerson) {
      return _buildPersonCard(item, index, isSelected);
    }

    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleItemSelection(index);
        } else {
          _onItemTapped(item);
        }
      },
      onLongPress: () => _showItemPreview(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.posterPath != null
                      ? CachedNetworkImage(
                          imageUrl: item.posterUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[900],
                            child: const Icon(Icons.broken_image, size: 48),
                          ),
                        )
                      : Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.movie, size: 48),
                        ),
                ),
                if (_isSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                ),
                if (item.year != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.year.toString(),
                        style: TextStyle(
                          color: ZagColours.accentColor(context),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.reason != null) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _showReasonPreview(item),
              child: Text(
                item.reason!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onItemTapped(StagedMediaItem item) {
    if (item.isMovie && widget.onMovieTap != null) {
      widget.onMovieTap!(item.tmdbId, item.title);
    } else if (item.isShow && widget.onShowTap != null) {
      widget.onShowTap!(item.tmdbId, item.title, item.tvdbId);
    } else if (item.isPerson) {
      // Navigate to person details
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PersonDetailsRoute(
            personId: item.personId,
            personName: item.title,
          ),
        ),
      );
    }
  }

  Future<void> _showReasonPreview(StagedMediaItem item) async {
    if (!mounted) return;
    final reason = item.reason;
    if (reason == null || reason.isEmpty) {
      return;
    }

    await ZagDialogs().textPreview(
      context,
      item.title,
      reason,
    );
  }

  Future<void> _showItemPreview(StagedMediaItem item) async {
    final overview = item.overview?.isNotEmpty == true
        ? item.overview!
        : 'No overview available.';

    // For both movies and TV shows, show Add button
    if (item.isMovie) {
      await ZagDialogs().textPreviewWithAdd(
        context,
        item.title,
        overview,
        onAdd: () => _addMovieToRadarr(item),
        alignLeft: true,
      );
    } else if (item.isShow) {
      await ZagDialogs().textPreviewWithAdd(
        context,
        item.title,
        overview,
        onAdd: () => _addShowToSonarr(item),
        alignLeft: true,
      );
    }
  }

  void _showMergedSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DefaultTabController(
          length: 2,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
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
                      _buildRadarrSettings(setModalState),
                      _buildSonarrSettings(setModalState),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadarrSettings(StateSetter setModalState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Quality Profile'),
            subtitle: _selectedRadarrQualityProfileName != null ? Text(_selectedRadarrQualityProfileName!) : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              _selectRadarrQualityProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Root Folder'),
            subtitle: _selectedRadarrRootFolder != null ? Text(_selectedRadarrRootFolder!) : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              _selectRadarrRootFolder();
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.search),
            title: const Text('Start search for missing'),
            value: _radarrSearchForMissing,
            onChanged: (value) {
              setModalState(() {
                setState(() {
                  _radarrSearchForMissing = value;
                  ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.update(value);
                });
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSonarrSettings(StateSetter setModalState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Quality Profile'),
            subtitle: _selectedSonarrQualityProfileName != null ? Text(_selectedSonarrQualityProfileName!) : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              _selectSonarrQualityProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Root Folder'),
            subtitle: _selectedSonarrRootFolder != null ? Text(_selectedSonarrRootFolder!) : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              _selectSonarrRootFolder();
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_list_rounded),
            title: const Text('Monitoring Options'),
            subtitle: Text(_sonarrMonitorType.zagName),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              _selectSonarrMonitorType();
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open_rounded),
            title: const Text('Series Type'),
            subtitle: Text(_sonarrSeriesType.value!.toTitleCase()),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context);
              _selectSonarrSeriesType();
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.search),
            title: const Text('Start search for missing'),
            value: _sonarrSearchForMissing,
            onChanged: (value) {
              setModalState(() {
                setState(() {
                  _sonarrSearchForMissing = value;
                  ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.update(value);
                });
              });
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.cut),
            title: const Text('Search for cutoff unmet'),
            value: _sonarrSearchForCutoffUnmet,
            onChanged: (value) {
              setModalState(() {
                setState(() {
                  _sonarrSearchForCutoffUnmet = value;
                  ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_CUTOFF_UNMET.update(value);
                });
              });
            },
          ),
        ],
      ),
    );
  }

  void _showRadarrConfig() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Radarr Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.high_quality),
                title: const Text('Quality Profile'),
                subtitle: _selectedRadarrQualityProfileName != null ? Text(_selectedRadarrQualityProfileName!) : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _selectRadarrQualityProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Root Folder'),
                subtitle: _selectedRadarrRootFolder != null ? Text(_selectedRadarrRootFolder!) : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _selectRadarrRootFolder();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.search),
                title: const Text('Start search for missing'),
                value: _radarrSearchForMissing,
                onChanged: (value) {
                  setModalState(() {
                    setState(() {
                      _radarrSearchForMissing = value;
                      ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.update(value);
                    });
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSonarrConfig() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sonarr Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.high_quality),
                title: const Text('Quality Profile'),
                subtitle: _selectedSonarrQualityProfileName != null ? Text(_selectedSonarrQualityProfileName!) : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _selectSonarrQualityProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Root Folder'),
                subtitle: _selectedSonarrRootFolder != null ? Text(_selectedSonarrRootFolder!) : null,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _selectSonarrRootFolder();
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_list_rounded),
                title: const Text('Monitoring Options'),
                subtitle: Text(_sonarrMonitorType.zagName),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _selectSonarrMonitorType();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open_rounded),
                title: const Text('Series Type'),
                subtitle: Text(_sonarrSeriesType.value!.toTitleCase()),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _selectSonarrSeriesType();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.search),
                title: const Text('Start search for missing'),
                value: _sonarrSearchForMissing,
                onChanged: (value) {
                  setModalState(() {
                    setState(() {
                      _sonarrSearchForMissing = value;
                      ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.update(value);
                    });
                  });
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.cut),
                title: const Text('Search for cutoff unmet'),
                value: _sonarrSearchForCutoffUnmet,
                onChanged: (value) {
                  setModalState(() {
                    setState(() {
                      _sonarrSearchForCutoffUnmet = value;
                      ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_CUTOFF_UNMET.update(value);
                    });
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectRadarrQualityProfile() async {
    try {
      final profiles = await context.read<RadarrState>().qualityProfiles;

      if (profiles == null || profiles.isEmpty) {
        showZagSnackBar(
          title: 'No Quality Profiles',
          message: 'No Radarr quality profiles found',
          type: ZagSnackbarType.INFO,
        );
        return;
      }

      final Tuple2<bool, RadarrQualityProfile?> result = await RadarrDialogs().editQualityProfile(context, profiles);

      if (result.item1 && result.item2 != null) {
        setState(() {
          _selectedRadarrQualityProfileId = result.item2!.id;
          _selectedRadarrQualityProfileName = result.item2!.name;
        });

        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.update(_selectedRadarrQualityProfileId);
        ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME.update(_selectedRadarrQualityProfileName);
      }
    } catch (e, stack) {
      ZagLogger().error('Error selecting Radarr quality profile', e, stack);
      showZagSnackBar(
        title: 'Error',
        message: 'Failed to load quality profiles',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _selectRadarrRootFolder() async {
    try {
      final folders = await context.read<RadarrState>().rootFolders;

      if (folders == null || folders.isEmpty) {
        showZagSnackBar(
          title: 'No Root Folders',
          message: 'No Radarr root folders found',
          type: ZagSnackbarType.INFO,
        );
        return;
      }

      final Tuple2<bool, RadarrRootFolder?> result = await RadarrDialogs().editRootFolder(context, folders);

      if (result.item1 && result.item2 != null) {
        setState(() {
          _selectedRadarrRootFolder = result.item2!.path;
        });

        ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.update(_selectedRadarrRootFolder);
      }
    } catch (e, stack) {
      ZagLogger().error('Error selecting Radarr root folder', e, stack);
      showZagSnackBar(
        title: 'Error',
        message: 'Failed to load root folders',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _selectSonarrQualityProfile() async {
    try {
      final profiles = await context.read<SonarrState>().qualityProfiles;

      if (profiles == null || profiles.isEmpty) {
        showZagSnackBar(
          title: 'No Quality Profiles',
          message: 'No Sonarr quality profiles found',
          type: ZagSnackbarType.INFO,
        );
        return;
      }

      final Tuple2<bool, SonarrQualityProfile?> result = await SonarrDialogs().editQualityProfile(context, profiles);

      if (result.item1 && result.item2 != null) {
        setState(() {
          _selectedSonarrQualityProfileId = result.item2!.id;
          _selectedSonarrQualityProfileName = result.item2!.name;
        });

        ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID.update(_selectedSonarrQualityProfileId);
        ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_NAME.update(_selectedSonarrQualityProfileName);
      }
    } catch (e, stack) {
      ZagLogger().error('Error selecting Sonarr quality profile', e, stack);
      showZagSnackBar(
        title: 'Error',
        message: 'Failed to load quality profiles',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _selectSonarrRootFolder() async {
    try {
      final folders = await context.read<SonarrState>().rootFolders;

      if (folders == null || folders.isEmpty) {
        showZagSnackBar(
          title: 'No Root Folders',
          message: 'No Sonarr root folders found',
          type: ZagSnackbarType.INFO,
        );
        return;
      }

      final Tuple2<bool, SonarrRootFolder?> result = await SonarrDialogs().editRootFolder(context, folders);

      if (result.item1 && result.item2 != null) {
        setState(() {
          _selectedSonarrRootFolder = result.item2!.path;
        });

        ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.update(_selectedSonarrRootFolder);
      }
    } catch (e, stack) {
      ZagLogger().error('Error selecting Sonarr root folder', e, stack);
      showZagSnackBar(
        title: 'Error',
        message: 'Failed to load root folders',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _selectSonarrMonitorType() async {
    try {
      final Tuple2<bool, SonarrSeriesMonitorType?> result = await SonarrDialogs().editMonitorType(context);

      if (result.item1 && result.item2 != null) {
        setState(() {
          _sonarrMonitorType = result.item2!;
        });

        ZagreusDatabase.Z_ASSISTANT_SONARR_MONITOR_TYPE.update(_sonarrMonitorType.value);
      }
    } catch (e, stack) {
      ZagLogger().error('Error selecting Sonarr monitor type', e, stack);
      showZagSnackBar(
        title: 'Error',
        message: 'Failed to select monitor type',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _selectSonarrSeriesType() async {
    try {
      final Tuple2<bool, SonarrSeriesType?> result = await SonarrDialogs().editSeriesType(context);

      if (result.item1 && result.item2 != null) {
        setState(() {
          _sonarrSeriesType = result.item2!;
        });

        ZagreusDatabase.Z_ASSISTANT_SONARR_SERIES_TYPE.update(_sonarrSeriesType.value);
      }
    } catch (e, stack) {
      ZagLogger().error('Error selecting Sonarr series type', e, stack);
      showZagSnackBar(
        title: 'Error',
        message: 'Failed to select series type',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _addMovieToRadarr(StagedMediaItem movie) async {
    try {
      // Load saved Radarr settings
      final qualityProfileId = ZagreusDatabase.Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID.read();
      final rootFolder = ZagreusDatabase.Z_ASSISTANT_RADARR_ROOT_FOLDER.read();
      final searchForMissing = ZagreusDatabase.Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING.read() ?? true;

      if (qualityProfileId == null || rootFolder == null) {
        showZagSnackBar(
          title: 'Missing Radarr Config',
          message: 'Please configure Radarr settings using the movie icon in the toolbar',
          type: ZagSnackbarType.INFO,
        );
        return;
      }

      final radarrState = context.read<RadarrState>();
      final profiles = await radarrState.qualityProfiles;
      final folders = await radarrState.rootFolders;

      if (profiles == null || folders == null) {
        showZagSnackBar(
          title: 'Radarr Not Available',
          message: 'Could not fetch Radarr configuration',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      final selectedProfile = profiles.firstWhere(
        (p) => p.id == qualityProfileId,
        orElse: () => profiles.first,
      );
      final selectedFolder = folders.firstWhere(
        (f) => f.path == rootFolder,
        orElse: () => folders.first,
      );

      // Show loading
      showZagSnackBar(
        title: 'Adding Movie',
        message: 'Adding ${movie.title} to Radarr...',
        type: ZagSnackbarType.INFO,
      );

      // Lookup movie
      final lookupResults = await radarrState.api!.movieLookup.get(
        term: "tmdb:${movie.tmdbId}",
      );

      if (lookupResults.isEmpty) {
        showZagSnackBar(
          title: 'Movie Not Found',
          message: '${movie.title} not found on TMDB',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      final radarrMovie = lookupResults.first;

      // Check if already in library
      if (radarrMovie.id != null && radarrMovie.id! > 0) {
        showZagSnackBar(
          title: 'Already in Library',
          message: '${movie.title} is already in your Radarr library',
          type: ZagSnackbarType.INFO,
        );
        return;
      }

      // Add to Radarr
      await radarrState.api!.movie.create(
        movie: radarrMovie,
        rootFolder: selectedFolder,
        monitored: true,
        minimumAvailability: RadarrAvailability.ANNOUNCED,
        qualityProfile: selectedProfile,
        searchForMovie: searchForMissing,
      );

      showZagSnackBar(
        title: 'Success',
        message: '${movie.title} added to Radarr',
        type: ZagSnackbarType.SUCCESS,
      );
    } catch (e, stack) {
      ZagLogger().error('Error adding movie to Radarr', e, stack);
      showZagSnackBar(
        title: 'Error',
        message: 'Failed to add movie: ${e.toString()}',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _addShowToSonarr(StagedMediaItem show) async {
    try {
      // Load saved Sonarr settings
      final qualityProfileId = ZagreusDatabase.Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID.read();
      final rootFolder = ZagreusDatabase.Z_ASSISTANT_SONARR_ROOT_FOLDER.read();
      final monitorTypeValue = ZagreusDatabase.Z_ASSISTANT_SONARR_MONITOR_TYPE.read();
      final searchForMissing = ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING.read() ?? true;
      final searchForCutoffUnmet = ZagreusDatabase.Z_ASSISTANT_SONARR_SEARCH_FOR_CUTOFF_UNMET.read() ?? false;

      if (qualityProfileId == null || rootFolder == null) {
        showZagSnackBar(
          title: 'Missing Sonarr Config',
          message: 'Please configure Sonarr settings using the TV icon in the toolbar',
          type: ZagSnackbarType.INFO,
        );
        return;
      }

      final sonarrState = context.read<SonarrState>();
      final profiles = await sonarrState.qualityProfiles;
      final folders = await sonarrState.rootFolders;

      if (profiles == null || folders == null) {
        showZagSnackBar(
          title: 'Sonarr Not Available',
          message: 'Could not fetch Sonarr configuration',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      final selectedProfile = profiles.firstWhere(
        (p) => p.id == qualityProfileId,
        orElse: () => profiles.first,
      );
      final selectedFolder = folders.firstWhere(
        (f) => f.path == rootFolder,
        orElse: () => folders.first,
      );

      final monitorType = SonarrSeriesMonitorType.values.firstWhere(
        (type) => type.value == monitorTypeValue,
        orElse: () => SonarrSeriesMonitorType.ALL,
      );

      // Show loading
      showZagSnackBar(
        title: 'Adding Show',
        message: 'Adding ${show.title} to Sonarr...',
        type: ZagSnackbarType.INFO,
      );

      // Lookup show
      final lookupResults = await sonarrState.api!.seriesLookup.get(
        term: "tmdb:${show.tmdbId}",
      );

      if (lookupResults.isEmpty) {
        showZagSnackBar(
          title: 'Show Not Found',
          message: '${show.title} not found on TMDB',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      final sonarrSeries = lookupResults.first;

      // Check if already in library
      if (sonarrSeries.id != null && sonarrSeries.id! > 0) {
        showZagSnackBar(
          title: 'Already in Library',
          message: '${show.title} is already in your Sonarr library',
          type: ZagSnackbarType.INFO,
        );
        return;
      }

      // Add to Sonarr
      await sonarrState.api!.series.create(
        series: sonarrSeries,
        seriesType: _sonarrSeriesType,
        seasonFolder: true,
        qualityProfile: selectedProfile,
        rootFolder: selectedFolder,
        monitorType: monitorType,
        searchForMissingEpisodes: searchForMissing,
        searchForCutoffUnmetEpisodes: searchForCutoffUnmet,
      );

      showZagSnackBar(
        title: 'Success',
        message: '${show.title} added to Sonarr',
        type: ZagSnackbarType.SUCCESS,
      );
    } catch (e, stack) {
      ZagLogger().error('Error adding show to Sonarr', e, stack);
      showZagSnackBar(
        title: 'Error',
        message: 'Failed to add show: ${e.toString()}',
        type: ZagSnackbarType.ERROR,
      );
    }
  }

  Future<void> _addSelectedToLibrary() async {
    if (_operation == null) return;

    // Get selected items
    final selectedItems = _selectedIndices.map((index) => _operation!.items[index]).toList();

    // Show immediate feedback toast
    showZagSnackBar(
      title: 'Adding Items',
      message: 'Adding ${selectedItems.length} items to library...',
      type: ZagSnackbarType.INFO,
    );

    // Split by media type
    final movies = selectedItems.where((item) => item.isMovie).toList();
    final shows = selectedItems.where((item) => item.isShow).toList();

    int successCount = 0;
    int failCount = 0;
    List<String> errors = [];

    // Add movies to Radarr
    if (movies.isNotEmpty) {
      if (_selectedRadarrQualityProfileId == null || _selectedRadarrRootFolder == null) {
        showZagSnackBar(
          title: 'Missing Radarr Config',
          message: 'Please configure Radarr quality profile and root folder',
          type: ZagSnackbarType.INFO,
        );
        return;
      }

      final radarrState = context.read<RadarrState>();
      final profiles = await radarrState.qualityProfiles;
      final folders = await radarrState.rootFolders;

      if (profiles == null || folders == null) {
        showZagSnackBar(
          title: 'Radarr Not Available',
          message: 'Could not fetch Radarr configuration',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      final selectedProfile = profiles.firstWhere((p) => p.id == _selectedRadarrQualityProfileId);
      final selectedFolder = folders.firstWhere((f) => f.path == _selectedRadarrRootFolder);

      for (final movie in movies) {
        try {
          // Lookup movie first
          final lookupResults = await radarrState.api!.movieLookup.get(term: "tmdb:${movie.tmdbId}");

          if (lookupResults.isEmpty) {
            errors.add('${movie.title}: Not found on TMDB');
            failCount++;
            continue;
          }

          final radarrMovie = lookupResults.first;

          // Check if already in library
          if (radarrMovie.id != null && radarrMovie.id! > 0) {
            errors.add('${movie.title}: Already in library');
            failCount++;
            continue;
          }

          // Add to Radarr
          await radarrState.api!.movie.create(
            movie: radarrMovie,
            rootFolder: selectedFolder,
            monitored: true,
            minimumAvailability: RadarrAvailability.ANNOUNCED,
            qualityProfile: selectedProfile,
            searchForMovie: _radarrSearchForMissing,
          );

          successCount++;
        } catch (e) {
          errors.add('${movie.title}: ${e.toString()}');
          failCount++;
        }
      }
    }

    // Add shows to Sonarr
    if (shows.isNotEmpty) {
      if (_selectedSonarrQualityProfileId == null || _selectedSonarrRootFolder == null) {
        showZagSnackBar(
          title: 'Missing Sonarr Config',
          message: 'Please configure Sonarr quality profile and root folder',
          type: ZagSnackbarType.INFO,
        );
        return;
      }

      final sonarrState = context.read<SonarrState>();
      final profiles = await sonarrState.qualityProfiles;
      final folders = await sonarrState.rootFolders;

      if (profiles == null || folders == null) {
        showZagSnackBar(
          title: 'Sonarr Not Available',
          message: 'Could not fetch Sonarr configuration',
          type: ZagSnackbarType.ERROR,
        );
        return;
      }

      final selectedProfile = profiles.firstWhere((p) => p.id == _selectedSonarrQualityProfileId);
      final selectedFolder = folders.firstWhere((f) => f.path == _selectedSonarrRootFolder);

      for (final show in shows) {
        try {
          // Lookup show first
          final lookupResults = await sonarrState.api!.seriesLookup.get(term: "tmdb:${show.tmdbId}");

          if (lookupResults.isEmpty) {
            errors.add('${show.title}: Not found on TMDB');
            failCount++;
            continue;
          }

          final sonarrSeries = lookupResults.first;

          // Check if already in library
          if (sonarrSeries.id != null && sonarrSeries.id! > 0) {
            errors.add('${show.title}: Already in library');
            failCount++;
            continue;
          }

          // Add to Sonarr
          await sonarrState.api!.series.create(
            series: sonarrSeries,
            seriesType: _sonarrSeriesType,
            seasonFolder: true,
            qualityProfile: selectedProfile,
            rootFolder: selectedFolder,
            monitorType: _sonarrMonitorType,
            searchForMissingEpisodes: _sonarrSearchForMissing,
            searchForCutoffUnmetEpisodes: _sonarrSearchForCutoffUnmet,
          );

          successCount++;
        } catch (e) {
          errors.add('${show.title}: ${e.toString()}');
          failCount++;
        }
      }
    }

    // Exit selection mode
    setState(() {
      _isSelectionMode = false;
      _selectedIndices.clear();
    });

    // Show result
    if (failCount == 0) {
      showZagSnackBar(
        title: 'Success',
        message: 'Added $successCount items to library',
        type: ZagSnackbarType.SUCCESS,
      );
    } else if (successCount == 0) {
      showZagSnackBar(
        title: 'Failed',
        message: 'Failed to add all items. Check logs for details.',
        type: ZagSnackbarType.ERROR,
      );
      errors.forEach((error) => ZagLogger().warning(error));
    } else {
      showZagSnackBar(
        title: 'Partial Success',
        message: 'Added $successCount items, $failCount failed',
        type: ZagSnackbarType.INFO,
      );
      errors.forEach((error) => ZagLogger().warning(error));
    }
  }

  Widget _buildPersonCard(StagedMediaItem item, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleItemSelection(index);
        } else {
          _onItemTapped(item);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                // Circular profile image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[900],
                  ),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: ClipOval(
                        child: item.posterPath != null
                            ? CachedNetworkImage(
                                imageUrl: item.profileUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.person, size: 48),
                                ),
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: const Icon(Icons.person, size: 48),
                              ),
                      ),
                    ),
                  ),
                ),
                // Purple "PERSON" badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PERSON',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_isSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.knownForDepartment != null) ...[
            const SizedBox(height: 2),
            Text(
              item.knownForDepartment!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (item.reason != null) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _showReasonPreview(item),
              child: Text(
                item.reason!,
                style: TextStyle(
                  fontSize: 12,
                  color: ZagColours.currentAccent.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
