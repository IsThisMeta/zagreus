import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/sabnzbd.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/sabnzbd.dart';
import 'package:zagreus/router/routes/sabnzbd.dart';
import 'package:zagreus/system/filesystem/file.dart';
import 'package:zagreus/system/filesystem/filesystem.dart';
import 'package:zagreus/system/session_state.dart';

class SABnzbdRoute extends StatefulWidget {
  final bool showDrawer;

  const SABnzbdRoute({
    Key? key,
    this.showDrawer = true,
  }) : super(key: key);

  @override
  State<SABnzbdRoute> createState() => _State();
}

class _State extends State<SABnzbdRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;
  String _profileState = ZagProfile.current.toString();
  SABnzbdAPI _api = SABnzbdAPI.from(ZagProfile.current);

  final List _refreshKeys = [
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
  ];

  // Session-based tab memory (cleared on app restart)
  static int? _sessionTabIndex;
  late final bool _tabMemoryEnabled;

  @override
  void initState() {
    super.initState();
    print('🔍 SABnzbdRoute initState() called');

    _tabMemoryEnabled = ZagSessionState.instance.tabMemoryEnabled;

    // Read from session first, fallback to database
    final initialPage = _tabMemoryEnabled
        ? _sessionTabIndex ?? SABnzbdDatabase.NAVIGATION_INDEX.read()
        : 0;
    print('🔍 Reading saved index from session: $initialPage');

    _pageController = ZagPageController(initialPage: initialPage);

    // Listen to page changes and save immediately
    _pageController!.addListener(_handlePageChanged);

    print('🔍 Page controller created with initialPage: $initialPage');

    // Inject global FAB overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalFABManager.instance.injectFAB(context);
    });
  }

  @override
  void deactivate() {
    print('🔍 SABnzbdRoute deactivate() called');
    super.deactivate();
  }

  @override
  void dispose() {
    _pageController?.removeListener(_handlePageChanged);
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

  Widget _drawer() => ZagDrawer(page: ZagModule.SABNZBD.key);

  Widget? _bottomNavigationBar() {
    if (ZagProfile.current.sabnzbdEnabled)
      return SABnzbdNavigationBar(pageController: _pageController);
    return null;
  }

  Widget _appBar() {
    List<String> profiles = ZagBox.profiles.keys.fold([], (value, element) {
      if (ZagBox.profiles.read(element)?.sabnzbdEnabled ?? false)
        value.add(element);
      return value;
    });
    List<Widget>? actions;
    if (ZagProfile.current.sabnzbdEnabled)
      actions = [
        Selector<SABnzbdState, bool>(
          selector: (_, model) => model.error,
          builder: (context, error, widget) =>
              error ? Container() : const SABnzbdAppBarStats(),
        ),
        ZagIconButton(
          icon: Icons.more_vert_rounded,
          onPressed: () async => _handlePopup(),
        ),
      ];
    return ZagAppBar.dropdown(
      title: ZagModule.SABNZBD.title,
      useDrawer: widget.showDrawer,
      hideLeading: !widget.showDrawer,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: SABnzbdNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    if (!ZagProfile.current.sabnzbdEnabled)
      return ZagMessage.moduleNotEnabled(
        context: context,
        module: ZagModule.SABNZBD.title,
      );
    return ZagPageView(
      controller: _pageController,
      children: [
        SABnzbdQueue(
          refreshIndicatorKey: _refreshKeys[0],
        ),
        SABnzbdHistory(
          refreshIndicatorKey: _refreshKeys[1],
        ),
      ],
    );
  }

  Future<void> _handlePopup() async {
    List<dynamic> values = await SABnzbdDialogs.globalSettings(context);
    if (values[0])
      switch (values[1]) {
        case 'web_gui':
          ZagProfile profile = ZagProfile.current;
          await profile.sabnzbdHost.openLink();
          break;
        case 'add_nzb':
          _addNZB();
          break;
        case 'sort':
          _sort();
          break;
        case 'clear_history':
          _clearHistory();
          break;
        case 'complete_action':
          _completeAction();
          break;
        case 'server_details':
          _serverDetails();
          break;
        default:
          ZagLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  Future<void> _serverDetails() async => SABnzbdRoutes.STATISTICS.go();

  Future<void> _completeAction() async {
    List values = await SABnzbdDialogs.changeOnCompleteAction(context);
    if (values[0])
      SABnzbdAPI.from(ZagProfile.current)
          .setOnCompleteAction(values[1])
          .then((_) => showZagSuccessSnackBar(
                title: 'On Complete Action Set',
                message: values[2],
              ))
          .catchError((error) => showZagErrorSnackBar(
                title: 'Failed to Set Complete Action',
                error: error,
              ));
  }

  Future<void> _clearHistory() async {
    List values = await SABnzbdDialogs.clearAllHistory(context);
    if (values[0])
      SABnzbdAPI.from(ZagProfile.current)
          .clearHistory(values[1], values[2])
          .then((_) {
        showZagSuccessSnackBar(
          title: 'History Cleared',
          message: values[3],
        );
        _refreshAllPages();
      }).catchError((error) {
        showZagErrorSnackBar(
          title: 'Failed to Upload NZB',
          error: error,
        );
      });
  }

  Future<void> _sort() async {
    List values = await SABnzbdDialogs.sortQueue(context);
    if (values[0])
      await SABnzbdAPI.from(ZagProfile.current)
          .sortQueue(values[1], values[2])
          .then((_) {
        showZagSuccessSnackBar(
          title: 'Sorted Queue',
          message: values[3],
        );
        (_refreshKeys[0] as GlobalKey<RefreshIndicatorState>)
            .currentState
            ?.show();
      }).catchError((error) {
        showZagErrorSnackBar(
          title: 'Failed to Sort Queue',
          error: error,
        );
      });
  }

  Future<void> _addNZB() async {
    List values = await SABnzbdDialogs.addNZB(context);
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

  Future<void> _addByFile() async {
    try {
      ZagFile? _file = await ZagFileSystem().read(context, [
        'nzb',
        'zip',
        'rar',
        'gz',
      ]);
      if (_file != null) {
        if (_file.data.isNotEmpty) {
          await _api.uploadFile(_file.data, _file.name).then((value) {
            _refreshKeys[0]?.currentState?.show();
            showZagSuccessSnackBar(
              title: 'Uploaded NZB (File)',
              message: _file.name,
            );
          });
        } else {
          showZagErrorSnackBar(
            title: 'Failed to Upload NZB',
            message: 'Please select a valid file type',
          );
        }
      }
    } catch (error, stack) {
      ZagLogger().error('Failed to add NZB by file', error, stack);
      showZagErrorSnackBar(
        title: 'Failed to Upload NZB',
        error: error,
      );
    }
  }

  Future<void> _addByURL() async {
    List values = await SABnzbdDialogs.addNZBUrl(context);
    if (values[0])
      await _api
          .uploadURL(values[1])
          .then((_) => showZagSuccessSnackBar(
                title: 'Uploaded NZB (URL)',
                message: values[1],
              ))
          .catchError((error) => showZagErrorSnackBar(
                title: 'Failed to Upload NZB',
                error: error,
              ));
  }

  void _refreshProfile() {
    _api = SABnzbdAPI.from(ZagProfile.current);
    _profileState = ZagProfile.current.toString();
    _refreshAllPages();
  }

  void _refreshAllPages() {
    for (var key in _refreshKeys) key?.currentState?.show();
  }

  void _handlePageChanged() {
    if (!(_pageController?.hasClients ?? false)) return;
    final page = _pageController!.page;
    if (page == null) return;
    final currentIndex = page.round();
    if (_tabMemoryEnabled) {
      _sessionTabIndex = currentIndex;
      print('🔍 Tab changed to: $currentIndex');
    }
  }
}
