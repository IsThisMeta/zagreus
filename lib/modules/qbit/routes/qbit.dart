import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/qbit.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/qbit/core/api/api.dart';
import 'package:zagreus/modules/qbit/core/dialogs.dart';
import 'package:zagreus/modules/qbit/core/state.dart';
import 'package:zagreus/modules/qbit/routes/history.dart';
import 'package:zagreus/modules/qbit/routes/queue.dart';
import 'package:zagreus/modules/qbit/widgets/app_bar_stats.dart';
import 'package:zagreus/modules/qbit/widgets/navigation_bar.dart';
import 'package:zagreus/system/filesystem/file.dart';
import 'package:zagreus/system/filesystem/filesystem.dart';

class QBitRoute extends StatefulWidget {
  final bool showDrawer;

  const QBitRoute({
    Key? key,
    this.showDrawer = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<QBitRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;
  String _profileState = ZagProfile.current.toString();
  QBitAPI _api = QBitAPI.from(ZagProfile.current);

  final List _refreshKeys = [
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
  ];

  @override
  void initState() {
    super.initState();

    final initialPage = QBitDatabase.NAVIGATION_INDEX.read();
    _pageController = ZagPageController(initialPage: initialPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalCubeManager.instance.injectCube(context);
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
      drawer: widget.showDrawer ? _drawer() : null,
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      extendBodyBehindAppBar: false,
      extendBody: false,
      onProfileChange: (_) {
        if (_profileState != ZagProfile.current.toString()) _refreshProfile();
      },
    );
  }

  Widget _drawer() => ZagDrawer(page: ZagModule.QBIT.key);

  Widget? _bottomNavigationBar() {
    if (ZagProfile.current.qbitEnabled) {
      return QBitNavigationBar(pageController: _pageController);
    }
    return null;
  }

  Widget _appBar() {
    List<String> profiles = ZagBox.profiles.keys.fold([], (value, element) {
      if (ZagBox.profiles.read(element)?.qbitEnabled ?? false)
        value.add(element);
      return value;
    });
    List<Widget>? actions;
    if (ZagProfile.current.qbitEnabled)
      actions = [
        Selector<QBitState, bool>(
          selector: (_, model) => model.error,
          builder: (context, error, widget) =>
              error ? Container() : const QBitAppBarStats(),
        ),
        ZagIconButton(
          icon: Icons.more_vert_rounded,
          onPressed: () async => _handlePopup(),
        ),
      ];
    return ZagAppBar.dropdown(
      title: ZagModule.QBIT.title,
      useDrawer: widget.showDrawer,
      hideLeading: !widget.showDrawer,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: QBitNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    if (!ZagProfile.current.qbitEnabled)
      return ZagMessage.moduleNotEnabled(
        context: context,
        module: ZagModule.QBIT.title,
      );
    return ZagPageView(
      controller: _pageController,
      children: [
        QBitQueue(
          refreshIndicatorKey: _refreshKeys[0],
        ),
        QBitHistory(
          refreshIndicatorKey: _refreshKeys[1],
        ),
      ],
    );
  }

  Future<void> _handlePopup() async {
    List<dynamic> values = await QBitDialogs.globalSettings(context);
    if (values[0])
      switch (values[1]) {
        case 'web_gui':
          ZagProfile profile = ZagProfile.current;
          await profile.effectiveQbitHost().openLink();
          break;
        case 'add_torrent':
          _addTorrent();
          break;
        case 'pause_all':
          _pauseAll();
          break;
        case 'resume_all':
          _resumeAll();
          break;
        default:
          ZagLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  Future<void> _addTorrent() async {
    List values = await QBitDialogs.addTorrent(context);
    if (values[0])
      switch (values[1]) {
        case 'link':
          _addByURL();
          break;
        case 'file':
          _addByFile();
          break;
        default:
          ZagLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  Future<void> _addByURL() async {
    List values = await QBitDialogs.addTorrentUrl(context);
    if (values[0])
      await _api
          .addTorrentUrl(values[1])
          .then((_) => showZagSuccessSnackBar(
              title: 'Added Torrent', message: values[1]))
          .catchError((error) => showZagErrorSnackBar(
              title: 'Failed to Add Torrent', error: error));
  }

  Future<void> _addByFile() async {
    try {
      ZagFile? _file = await ZagFileSystem().read(context, [
        'torrent',
      ]);
      if (_file != null) {
        if (_file.data.isNotEmpty) {
          await _api.addTorrentFile(_file.data, _file.name).then((value) {
            _refreshKeys[0]?.currentState?.show();
            showZagSuccessSnackBar(
              title: 'Added Torrent (File)',
              message: _file.name,
            );
          });
        } else {
          showZagErrorSnackBar(
            title: 'Failed to Add Torrent',
            message: 'Please select a valid file',
          );
        }
      }
    } catch (error, stack) {
      ZagLogger().error('Failed to add torrent by file', error, stack);
      showZagErrorSnackBar(
        title: 'Failed to Add Torrent',
        error: error,
      );
    }
  }

  Future<void> _pauseAll() async {
    try {
      await _api.pauseAll();
      showZagSuccessSnackBar(title: 'Paused All Torrents', message: null);
      _refreshAllPages();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Pause All', error: error);
    }
  }

  Future<void> _resumeAll() async {
    try {
      await _api.resumeAll();
      showZagSuccessSnackBar(title: 'Resumed All Torrents', message: null);
      _refreshAllPages();
    } catch (error) {
      showZagErrorSnackBar(title: 'Failed to Resume All', error: error);
    }
  }

  void _refreshProfile() {
    _api = QBitAPI.from(ZagProfile.current);
    _profileState = ZagProfile.current.toString();
    _refreshAllPages();
  }

  void _refreshAllPages() {
    for (var key in _refreshKeys) key?.currentState?.show();
  }
}
