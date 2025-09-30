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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
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

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'Z Assistant Results',
      actions: [
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
          return _buildMediaItem(item);
        },
      ),
    );
  }

  Widget _buildMediaItem(StagedMediaItem item) {
    return GestureDetector(
      onTap: () => _onItemTapped(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
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
}