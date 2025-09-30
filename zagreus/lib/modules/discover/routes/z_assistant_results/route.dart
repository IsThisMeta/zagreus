import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/services/staged_operations_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ZAssistantResultsRoute extends StatefulWidget {
  final String stageId;
  final Function(int tmdbId, String title)? onMovieTap;
  final Function(int tmdbId, String title)? onShowTap;

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

  int? _selectedSonarrQualityProfileId;
  String? _selectedSonarrQualityProfileName;
  String? _selectedSonarrRootFolder;

  @override
  void initState() {
    super.initState();
    _loadData();
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
            onPressed: _selectedIndices.isEmpty ? null : () {
              // TODO: Add selected items to library
              ZagLogger().debug('Add ${_selectedIndices.length} items to library');
            },
            tooltip: 'Add to Library',
          ),
        ],
      );
    }

    return ZagAppBar(
      title: 'Results',
      actions: [
        IconButton(
          icon: const Icon(Icons.movie),
          onPressed: _showRadarrConfig,
          tooltip: 'Radarr Settings',
        ),
        IconButton(
          icon: const Icon(Icons.tv),
          onPressed: _showSonarrConfig,
          tooltip: 'Sonarr Settings',
        ),
        IconButton(
          icon: const Icon(Icons.checklist),
          onPressed: _toggleSelectionMode,
          tooltip: 'Select Items',
        ),
        IconButton(
          icon: Icon(ZagIcons.REFRESH),
          onPressed: _loadData,
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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
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
          if (item.year != null)
            Text(
              item.year.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  void _onItemTapped(StagedMediaItem item) {
    if (item.isMovie && widget.onMovieTap != null) {
      widget.onMovieTap!(item.tmdbId, item.title);
    } else if (item.isShow && widget.onShowTap != null) {
      widget.onShowTap!(item.tmdbId, item.title);
    }
  }

  Future<void> _showItemPreview(StagedMediaItem item) async {
    // Show text preview dialog with copy button (like Add Movie screen)
    await ZagDialogs().textPreview(
      context,
      item.title,
      'No overview available.',
    );
  }

  void _showRadarrConfig() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
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
              subtitle: Text(_selectedRadarrQualityProfileName ?? 'Select quality profile'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _selectRadarrQualityProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Root Folder'),
              subtitle: Text(_selectedRadarrRootFolder ?? 'Select root folder'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _selectRadarrRootFolder();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSonarrConfig() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
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
              subtitle: Text(_selectedSonarrQualityProfileName ?? 'Select quality profile'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _selectSonarrQualityProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Root Folder'),
              subtitle: Text(_selectedSonarrRootFolder ?? 'Select root folder'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _selectSonarrRootFolder();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectRadarrQualityProfile() {
    // TODO: Fetch and show Radarr quality profiles
    showZagSnackBar(
      title: 'Coming Soon',
      message: 'Quality profile selection will be implemented',
      type: ZagSnackbarType.INFO,
    );
  }

  void _selectRadarrRootFolder() {
    // TODO: Fetch and show Radarr root folders
    showZagSnackBar(
      title: 'Coming Soon',
      message: 'Root folder selection will be implemented',
      type: ZagSnackbarType.INFO,
    );
  }

  void _selectSonarrQualityProfile() {
    // TODO: Fetch and show Sonarr quality profiles
    showZagSnackBar(
      title: 'Coming Soon',
      message: 'Quality profile selection will be implemented',
      type: ZagSnackbarType.INFO,
    );
  }

  void _selectSonarrRootFolder() {
    // TODO: Fetch and show Sonarr root folders
    showZagSnackBar(
      title: 'Coming Soon',
      message: 'Root folder selection will be implemented',
      type: ZagSnackbarType.INFO,
    );
  }
}