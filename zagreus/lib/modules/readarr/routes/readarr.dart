import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/routes/readarr.dart';

class ReadarrRoute extends StatefulWidget {
  const ReadarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ReadarrRoute> createState() => _State();
}

class _State extends State<ReadarrRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;
  String _profileState = ZagProfile.current.toString();
  ReadarrAPI _api = ReadarrAPI.from(ZagProfile.current);

  final List _refreshKeys = [
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    print('🔍 ReadarrRoute initState() called');

    final initialPage = ReadarrDatabase.NAVIGATION_INDEX.read();
    print('🔍 Loaded initial index: $initialPage');

    _pageController = ZagPageController(initialPage: initialPage);

    print('🔍 Page controller created with initialPage: $initialPage');

    // Inject global cube overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalCubeManager.instance.injectCube(context);
    });
  }

  @override
  void deactivate() {
    print('🔍 ReadarrRoute deactivate() called');
    super.deactivate();
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
      module: ZagModule.READARR,
      body: _body(),
      drawer: _drawer(),
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      onProfileChange: (_) {
        if (_profileState != ZagProfile.current.toString()) _refreshProfile();
      },
    );
  }

  Widget _drawer() => ZagDrawer(page: ZagModule.READARR.key);

  Widget? _bottomNavigationBar() {
    if (ZagProfile.current.readarrEnabled)
      return ReadarrNavigationBar(pageController: _pageController);
    return null;
  }

  Widget _body() {
    if (!ZagProfile.current.readarrEnabled)
      return ZagMessage.moduleNotEnabled(
        context: context,
        module: ZagModule.READARR.title,
      );
    return ZagPageView(
      controller: _pageController,
      children: [
        ReadarrCatalogue(
          refreshIndicatorKey: _refreshKeys[0],
          refreshAllPages: _refreshAllPages,
        ),
        ReadarrMissing(
          refreshIndicatorKey: _refreshKeys[1],
          refreshAllPages: _refreshAllPages,
        ),
        ReadarrHistory(
          refreshIndicatorKey: _refreshKeys[2],
          refreshAllPages: _refreshAllPages,
        ),
      ],
    );
  }

  Widget _appBar() {
    const db = ZagBox.profiles;
    final profiles = db.keys.fold<List<String>>([], (arr, key) {
      if (ZagBox.profiles.read(key)?.readarrEnabled ?? false) arr.add(key);
      return arr;
    });
    List<Widget>? actions;
    if (ZagProfile.current.readarrEnabled)
      actions = [
        ZagIconButton(
          icon: Icons.add_rounded,
          onPressed: () async => _enterAddAuthor(),
        ),
        if (ZagreusDatabase.DOWNLOADS_DRAWER_ENABLED.read())
          ZagIconButton(
            icon: Icons.download_rounded,
            onPressed: _openQueueDrawer,
          ),
        ZagIconButton(
          icon: Icons.more_vert_rounded,
          onPressed: () async => _handlePopup(),
        ),
      ];
    return ZagAppBar.dropdown(
      title: ZagModule.READARR.title,
      useDrawer: true,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: ReadarrNavigationBar.scrollControllers,
    );
  }

  Future<void> _enterAddAuthor() async {
    final _model = Provider.of<ReadarrState>(context, listen: false);
    _model.addSearchQuery = '';
    ReadarrRoutes.ADD_AUTHOR.go();
  }

  Future<void> _handlePopup() async {
    List<dynamic> values = await ReadarrDialogs.globalSettings(context);
    if (values[0])
      switch (values[1]) {
        case 'web_gui':
          ZagProfile profile = ZagProfile.current;
          await profile.effectiveReadarrHost().openLink();
          break;
        case 'update_library':
          await _api
              .updateLibrary()
              .then((_) => showZagSuccessSnackBar(
                  title: 'Updating Library...',
                  message: 'Updating your library in the background'))
              .catchError((error) => showZagErrorSnackBar(
                  title: 'Failed to Update Library', error: error));
          break;
        case 'rss_sync':
          await _api
              .triggerRssSync()
              .then((_) => showZagSuccessSnackBar(
                  title: 'Running RSS Sync...',
                  message: 'Running RSS sync in the background'))
              .catchError((error) => showZagErrorSnackBar(
                  title: 'Failed to Run RSS Sync', error: error));
          break;
        case 'backup':
          await _api
              .triggerBackup()
              .then((_) => showZagSuccessSnackBar(
                  title: 'Backing Up Database...',
                  message: 'Backing up database in the background'))
              .catchError((error) => showZagErrorSnackBar(
                  title: 'Failed to Backup Database', error: error));
          break;
        case 'missing_search':
          {
            List<dynamic> values =
                await ReadarrDialogs.searchAllMissing(context);
            if (values[0])
              await _api
                  .searchAllMissing()
                  .then((_) => showZagSuccessSnackBar(
                      title: 'Searching...',
                      message: 'Search for all missing books'))
                  .catchError((error) => showZagErrorSnackBar(
                      title: 'Failed to Search', error: error));
            break;
          }
        default:
          ZagLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  void _openQueueDrawer() {
    final scaffoldState = _scaffoldKey.currentState;
    if (scaffoldState?.hasEndDrawer ?? false) {
      scaffoldState?.openEndDrawer();
    }
  }

  void _refreshProfile() {
    _api = ReadarrAPI.from(ZagProfile.current);
    _profileState = ZagProfile.current.toString();
    _refreshAllPages();
  }

  void _refreshAllPages() {
    for (var key in _refreshKeys) key?.currentState?.show();
  }
}
