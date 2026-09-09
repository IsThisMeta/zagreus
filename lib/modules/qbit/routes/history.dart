import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/qbit.dart';
import 'package:zagreus/modules/qbit/core/api/api.dart';
import 'package:zagreus/modules/qbit/core/api/data.dart';
import 'package:zagreus/modules/qbit/core/dialogs.dart';
import 'package:zagreus/modules/qbit/core/state.dart';
import 'package:zagreus/modules/qbit/widgets/history_tile.dart';
import 'package:zagreus/modules/qbit/widgets/navigation_bar.dart';
import 'package:zagreus/router/routes/qbit.dart';

class QBitHistory extends StatefulWidget {
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;
  final QBitAPI api;

  const QBitHistory({
    Key? key,
    this.refreshIndicatorKey,
    required this.api,
  }) : super(key: key);

  @override
  State<QBitHistory> createState() => _State();
}

class _State extends State<QBitHistory> with AutomaticKeepAliveClientMixin {
  List<QBitTorrentData> _torrents = [];
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
      final torrents = await widget.api.getHistory();

      if (!mounted) return;
      context.read<QBitState>().error = false;

      setState(() {
        _torrents = torrents;
        _loading = false;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to fetch qBit history', error, stack);
      if (!mounted) return;
      context.read<QBitState>().error = true;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      key: widget.refreshIndicatorKey,
      onRefresh: _fetchData,
      child: _body(),
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
        text: 'No completed torrents',
      );
    }

    return ZagListViewBuilder(
      controller: QBitNavigationBar
          .scrollControllers[QBitDatabase.NAVIGATION_INDEX.read()],
      itemCount: _torrents.length,
      itemBuilder: (context, index) {
        final torrent = _torrents[index];
        return QBitHistoryTile(
          torrent: torrent,
          onTap: () => QBitRoutes.TORRENT_DETAILS.go(
            params: {'hash': torrent.hash},
          ),
          onLongPress: () => _showTorrentOptions(torrent),
        );
      },
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
