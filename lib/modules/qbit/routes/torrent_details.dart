import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/qbit/core/api/api.dart';
import 'package:zagreus/modules/qbit/core/api/data.dart';
import 'package:zagreus/modules/qbit/core/dialogs.dart';

class QBitTorrentDetailsRoute extends StatefulWidget {
  final String hash;

  const QBitTorrentDetailsRoute({
    Key? key,
    required this.hash,
  }) : super(key: key);

  @override
  State<QBitTorrentDetailsRoute> createState() => _State();
}

class _State extends State<QBitTorrentDetailsRoute>
    with SingleTickerProviderStateMixin, ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late QBitAPI _api;
  late TabController _tabController;

  List<QBitTorrentData>? _torrentList;
  QBitTorrentData? _torrent;
  List<QBitFileData> _files = [];
  List<QBitTrackerData> _trackers = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _api = QBitAPI.from(ZagProfile.current);
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final torrents = await _api.getTorrents();
      _torrentList = torrents;
      _torrent = torrents.firstWhere(
        (t) => t.hash == widget.hash,
        orElse: () => throw Exception('Torrent not found'),
      );

      final files = await _api.getTorrentFiles(widget.hash);
      final trackers = await _api.getTorrentTrackers(widget.hash);

      if (!mounted) return;
      setState(() {
        _files = files;
        _trackers = trackers;
        _loading = false;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to fetch torrent details', error, stack);
      if (!mounted) return;
      setState(() {
        _error = true;
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
      title: _torrent?.name ?? 'Torrent Details',
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Info'),
          Tab(text: 'Files'),
          Tab(text: 'Trackers'),
        ],
      ),
      actions: [
        if (_torrent != null)
          ZagIconButton(
            icon: Icons.more_vert_rounded,
            onPressed: _showOptions,
          ),
      ],
    );
  }

  Widget _body() {
    if (_loading) {
      return const ZagLoader();
    }
    if (_error || _torrent == null) {
      return ZagMessage.error(
        onTap: _fetchData,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildInfoTab(),
        _buildFilesTab(),
        _buildTrackersTab(),
      ],
    );
  }

  Widget _buildInfoTab() {
    final torrent = _torrent!;
    return ZagListView(
      controller: scrollController,
      children: [
        ZagHeader(text: 'Status'),
        ZagBlock(
          title: 'State',
          body: [TextSpan(text: torrent.statusText)],
        ),
        ZagBlock(
          title: 'Progress',
          body: [TextSpan(text: torrent.formattedProgress)],
        ),
        ZagBlock(
          title: 'ETA',
          body: [TextSpan(text: torrent.formattedEta)],
        ),
        ZagDivider(),
        ZagHeader(text: 'Transfer'),
        ZagBlock(
          title: 'Download Speed',
          body: [TextSpan(text: _formatSpeed(torrent.dlSpeed))],
        ),
        ZagBlock(
          title: 'Upload Speed',
          body: [TextSpan(text: _formatSpeed(torrent.upSpeed))],
        ),
        ZagBlock(
          title: 'Downloaded',
          body: [TextSpan(text: _formatBytes(torrent.downloaded))],
        ),
        ZagBlock(
          title: 'Uploaded',
          body: [TextSpan(text: _formatBytes(torrent.uploaded))],
        ),
        ZagBlock(
          title: 'Ratio',
          body: [TextSpan(text: torrent.ratio.toStringAsFixed(3))],
        ),
        ZagDivider(),
        ZagHeader(text: 'Details'),
        ZagBlock(
          title: 'Size',
          body: [TextSpan(text: _formatBytes(torrent.size))],
        ),
        ZagBlock(
          title: 'Category',
          body: [TextSpan(text: torrent.category.isEmpty ? 'None' : torrent.category)],
        ),
        ZagBlock(
          title: 'Save Path',
          body: [TextSpan(text: torrent.savePath)],
        ),
        ZagBlock(
          title: 'Hash',
          body: [TextSpan(text: torrent.hash)],
        ),
        ZagDivider(),
        ZagHeader(text: 'Peers'),
        ZagBlock(
          title: 'Seeds',
          body: [TextSpan(text: '${torrent.seedersCurrent} (${torrent.seedersTotal} total)')],
        ),
        ZagBlock(
          title: 'Leechers',
          body: [TextSpan(text: '${torrent.leechersCurrent} (${torrent.leechersTotal} total)')],
        ),
      ],
    );
  }

  Widget _buildFilesTab() {
    if (_files.isEmpty) {
      return ZagMessage.inList(text: 'No files');
    }

    return ZagListViewBuilder(
      controller: scrollController,
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index];
        return ZagBlock(
          title: file.fileName,
          body: [
            TextSpan(text: '${_formatBytes(file.size)} - ${file.formattedProgress}'),
            const TextSpan(text: '\n'),
            TextSpan(
              text: file.priorityEnum.name,
              style: TextStyle(
                color: file.isSkipped ? ZagColours.red : ZagColours.currentAccent,
              ),
            ),
          ],
          trailing: ZagIconButton(
            icon: Icons.low_priority_rounded,
            onPressed: () => _setFilePriority(file),
          ),
        );
      },
    );
  }

  Widget _buildTrackersTab() {
    // Filter out DHT, PeX, and LSD entries for cleaner view
    final filteredTrackers = _trackers.where((t) =>
        !t.url.startsWith('** [') && t.url.isNotEmpty).toList();

    if (filteredTrackers.isEmpty) {
      return ZagMessage.inList(text: 'No trackers');
    }

    return ZagListViewBuilder(
      controller: scrollController,
      itemCount: filteredTrackers.length,
      itemBuilder: (context, index) {
        final tracker = filteredTrackers[index];
        return ZagBlock(
          title: tracker.url,
          body: [
            TextSpan(
              text: tracker.statusText,
              style: TextStyle(
                color: tracker.isWorking
                    ? Colors.green
                    : tracker.isNotWorking
                        ? ZagColours.red
                        : null,
              ),
            ),
            if (tracker.message.isNotEmpty) ...[
              const TextSpan(text: '\n'),
              TextSpan(text: tracker.message),
            ],
            const TextSpan(text: '\n'),
            TextSpan(
              text: 'Seeds: ${tracker.numSeeds} | Leeches: ${tracker.numLeeches}',
            ),
          ],
        );
      },
    );
  }

  Future<void> _showOptions() async {
    final torrent = _torrent!;
    final values = await QBitDialogs.torrentSettings(
      context,
      torrent.name,
      torrent.isPaused,
    );
    if (!values[0]) return;

    switch (values[1]) {
      case 'status':
        await _toggleStatus();
        break;
      case 'category':
        await _changeCategory();
        break;
      case 'rename':
        await _rename();
        break;
      case 'recheck':
        await _recheck();
        break;
      case 'reannounce':
        await _reannounce();
        break;
      case 'delete':
        await _delete();
        break;
    }
  }

  Future<void> _toggleStatus() async {
    final torrent = _torrent!;
    try {
      if (torrent.isPaused) {
        await _api.resumeTorrents([torrent.hash]);
        showZagSuccessSnackBar(title: 'Resumed Torrent', message: null);
      } else {
        await _api.pauseTorrents([torrent.hash]);
        showZagSuccessSnackBar(title: 'Paused Torrent', message: null);
      }
      _fetchData();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Update Status', error: error);
    }
  }

  Future<void> _changeCategory() async {
    try {
      final categories = await _api.getCategories();
      if (!mounted) return;

      final values = await QBitDialogs.changeCategory(context, categories);
      if (!values[0]) return;

      final category = values[1] as QBitCategoryData;
      await _api.setCategory([widget.hash], category.name);
      showZagSuccessSnackBar(
        title: 'Changed Category',
        message: category.displayName,
      );
      _fetchData();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Change Category', error: error);
    }
  }

  Future<void> _rename() async {
    final torrent = _torrent!;
    final values = await QBitDialogs.renameTorrent(context, torrent.name);
    if (!values[0]) return;

    try {
      await _api.renameTorrent(torrent.hash, values[1]);
      showZagSuccessSnackBar(title: 'Renamed Torrent', message: null);
      _fetchData();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Rename Torrent', error: error);
    }
  }

  Future<void> _recheck() async {
    try {
      await _api.recheckTorrent(widget.hash);
      showZagSuccessSnackBar(title: 'Rechecking Torrent', message: null);
      _fetchData();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Recheck Torrent', error: error);
    }
  }

  Future<void> _reannounce() async {
    try {
      await _api.reannounceTorrent(widget.hash);
      showZagSuccessSnackBar(title: 'Reannounced Torrent', message: null);
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Reannounce Torrent', error: error);
    }
  }

  Future<void> _delete() async {
    final values = await QBitDialogs.deleteTorrent(context);
    if (!values[0]) return;

    try {
      await _api.deleteTorrents([widget.hash], deleteFiles: values[1]);
      showZagSuccessSnackBar(title: 'Deleted Torrent', message: null);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Delete Torrent', error: error);
    }
  }

  Future<void> _setFilePriority(QBitFileData file) async {
    final values = await QBitDialogs.setFilePriority(context);
    if (!values[0]) return;

    try {
      final priority = values[1] as QBitFilePriority;
      await _api.setFilePriority(widget.hash, [file.index], priority.value);
      showZagSuccessSnackBar(title: 'Updated File Priority', message: null);
      _fetchData();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Set Priority', error: error);
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

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
