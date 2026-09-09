import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/qbit.dart';
import 'package:zagreus/modules/qbit/core/api/api.dart';
import 'package:zagreus/modules/qbit/core/api/data.dart';
import 'package:zagreus/modules/qbit/core/dialogs.dart';
import 'package:zagreus/modules/qbit/core/state.dart';
import 'package:zagreus/modules/qbit/widgets/navigation_bar.dart';
import 'package:zagreus/modules/qbit/widgets/queue_fab.dart';
import 'package:zagreus/modules/qbit/widgets/queue_tile.dart';
import 'package:zagreus/router/routes/qbit.dart';

enum _TorrentFilter {
  all('All'),
  downloading('Downloading'),
  seeding('Seeding'),
  paused('Paused'),
  done('Done'),
  errored('Errored');

  final String label;
  const _TorrentFilter(this.label);
}

class QBitQueue extends StatefulWidget {
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;
  final QBitAPI api;

  const QBitQueue({
    Key? key,
    this.refreshIndicatorKey,
    required this.api,
  }) : super(key: key);

  @override
  State<QBitQueue> createState() => _State();
}

class _State extends State<QBitQueue> with AutomaticKeepAliveClientMixin {
  List<QBitTorrentData> _torrents = [];
  _TorrentFilter _filter = _TorrentFilter.all;
  bool _loading = true;
  bool _error = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final torrents = await widget.api.getQueue();
      final status = await widget.api.getTransferInfo();

      if (!mounted) return;

      final state = context.read<QBitState>();
      state.error = false;
      state.downloadSpeed = status.dlInfoSpeed;
      state.uploadSpeed = status.upInfoSpeed;
      state.currentDownloadSpeed = _formatSpeed(status.dlInfoSpeed);
      state.currentUploadSpeed = _formatSpeed(status.upInfoSpeed);

      // Check if any torrents are downloading (not paused)
      state.paused = !torrents.any((t) => t.isDownloading && !t.isPaused);

      setState(() {
        _torrents = torrents;
        _loading = false;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to fetch qBit queue', error, stack);
      if (!mounted) return;
      context.read<QBitState>().error = true;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  String _formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) return '$bytesPerSecond B/s';
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    }
    if (bytesPerSecond < 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB/s';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: QBitQueueFAB(
        api: widget.api,
        onComplete: () => widget.refreshIndicatorKey?.currentState?.show(),
      ),
      body: RefreshIndicator(
        key: widget.refreshIndicatorKey,
        onRefresh: _fetchData,
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _torrents.isEmpty) {
      return const ZagLoader();
    }
    if (_error) {
      return ZagMessage.error(
        onTap: () => widget.refreshIndicatorKey?.currentState?.show(),
      );
    }
    if (_torrents.isEmpty) {
      return ZagMessage.inList(
        text: 'No torrents found',
      );
    }

    final controller = QBitNavigationBar
        .scrollControllers[QBitDatabase.NAVIGATION_INDEX.read()];
    final torrents = _filteredTorrents;

    return Scrollbar(
      controller: controller,
      interactive: true,
      child: ListView.builder(
        controller: controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: MediaQuery.of(context).padding.add(ZagUI.MARGIN_HALF_VERTICAL)
            as EdgeInsets,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: torrents.isEmpty ? 2 : torrents.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _filterBar();
          if (torrents.isEmpty) {
            return ZagMessage.inList(
                text: 'No ${_filter.label.toLowerCase()} torrents');
          }

          final torrent = torrents[index - 1];
          return QBitQueueTile(
            torrent: torrent,
            onTap: () => QBitRoutes.TORRENT_DETAILS.go(
              params: {'hash': torrent.hash},
            ),
            onLongPress: () => _showTorrentOptions(torrent),
          );
        },
      ),
    );
  }

  List<QBitTorrentData> get _filteredTorrents {
    switch (_filter) {
      case _TorrentFilter.all:
        return _torrents;
      case _TorrentFilter.downloading:
        return _torrents.where((torrent) => torrent.isDownloading).toList();
      case _TorrentFilter.seeding:
        return _torrents.where((torrent) => torrent.isSeeding).toList();
      case _TorrentFilter.paused:
        return _torrents.where((torrent) => torrent.isPaused).toList();
      case _TorrentFilter.done:
        return _torrents
            .where((torrent) => torrent.isCompleted && !torrent.isSeeding)
            .toList();
      case _TorrentFilter.errored:
        return _torrents.where((torrent) => torrent.isError).toList();
    }
  }

  Widget _filterBar() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: ZagUI.DEFAULT_MARGIN_SIZE),
        itemCount: _TorrentFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _TorrentFilter.values[index];
          final selected = filter == _filter;
          return ChoiceChip(
            label: Text(filter.label),
            selected: selected,
            showCheckmark: false,
            selectedColor: ZagColours.currentAccent.withValues(alpha: 0.25),
            onSelected: (_) => setState(() => _filter = filter),
          );
        },
      ),
    );
  }

  Future<void> _showTorrentOptions(QBitTorrentData torrent) async {
    final values = await QBitDialogs.torrentSettings(
      context,
      torrent.name,
      torrent.isPaused,
    );
    if (!values[0]) return;

    switch (values[1]) {
      case 'status':
        await _toggleTorrentStatus(torrent);
        break;
      case 'category':
        await _changeCategory(torrent);
        break;
      case 'rename':
        await _renameTorrent(torrent);
        break;
      case 'recheck':
        await _recheckTorrent(torrent);
        break;
      case 'reannounce':
        await _reannounceTorrent(torrent);
        break;
      case 'delete':
        await _deleteTorrent(torrent);
        break;
    }
  }

  Future<void> _toggleTorrentStatus(QBitTorrentData torrent) async {
    try {
      if (torrent.isPaused) {
        await widget.api.resumeTorrents([torrent.hash]);
        showZagSuccessSnackBar(title: 'Resumed Torrent', message: null);
      } else {
        await widget.api.pauseTorrents([torrent.hash]);
        showZagSuccessSnackBar(title: 'Paused Torrent', message: null);
      }
      widget.refreshIndicatorKey?.currentState?.show();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Update Status', error: error);
    }
  }

  Future<void> _changeCategory(QBitTorrentData torrent) async {
    try {
      final categories = await widget.api.getCategories();
      if (!mounted) return;

      final values = await QBitDialogs.changeCategory(context, categories);
      if (!values[0]) return;

      final category = values[1] as QBitCategoryData;
      await widget.api.setCategory([torrent.hash], category.name);
      showZagSuccessSnackBar(
        title: 'Changed Category',
        message: category.displayName,
      );
      widget.refreshIndicatorKey?.currentState?.show();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Change Category', error: error);
    }
  }

  Future<void> _renameTorrent(QBitTorrentData torrent) async {
    final values = await QBitDialogs.renameTorrent(context, torrent.name);
    if (!values[0]) return;

    try {
      await widget.api.renameTorrent(torrent.hash, values[1]);
      showZagSuccessSnackBar(title: 'Renamed Torrent', message: null);
      widget.refreshIndicatorKey?.currentState?.show();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Rename Torrent', error: error);
    }
  }

  Future<void> _recheckTorrent(QBitTorrentData torrent) async {
    try {
      await widget.api.recheckTorrent(torrent.hash);
      showZagSuccessSnackBar(title: 'Rechecking Torrent', message: null);
      widget.refreshIndicatorKey?.currentState?.show();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Recheck Torrent', error: error);
    }
  }

  Future<void> _reannounceTorrent(QBitTorrentData torrent) async {
    try {
      await widget.api.reannounceTorrent(torrent.hash);
      showZagSuccessSnackBar(title: 'Reannounced Torrent', message: null);
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Reannounce Torrent', error: error);
    }
  }

  Future<void> _deleteTorrent(QBitTorrentData torrent) async {
    final values = await QBitDialogs.deleteTorrent(context);
    if (!values[0]) return;

    try {
      await widget.api.deleteTorrents(
        [torrent.hash],
        deleteFiles: values[1],
      );
      showZagSuccessSnackBar(title: 'Deleted Torrent', message: null);
      widget.refreshIndicatorKey?.currentState?.show();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Delete Torrent', error: error);
    }
  }
}
