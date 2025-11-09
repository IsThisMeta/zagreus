import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/nzbget.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/nzbget.dart';
import 'package:zagreus/router/routes/nzbget.dart';

import 'package:zagreus/system/filesystem/file.dart';
import 'package:zagreus/system/filesystem/filesystem.dart';

class NZBGetRoute extends StatefulWidget {
  final bool showDrawer;

  const NZBGetRoute({
    Key? key,
    this.showDrawer = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<NZBGetRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;
  String _profileState = ZagProfile.current.toString();
  NZBGetAPI _api = NZBGetAPI.from(ZagProfile.current);

  final List _refreshKeys = [
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
  ];

  // Session-based tab memory (cleared on app restart)
  static int? _sessionTabIndex;

  @override
  void initState() {
    super.initState();
    print('🔍 NZBGetRoute initState() called');

    // Read from session first, fallback to database
    final initialPage =
        _sessionTabIndex ?? NZBGetDatabase.NAVIGATION_INDEX.read();
    print('🔍 Reading saved index from session: $initialPage');

    _pageController = ZagPageController(initialPage: initialPage);

    // Listen to page changes and save immediately
    _pageController!.addListener(() {
      if (_pageController!.hasClients) {
        final page = _pageController!.page;
        if (page != null) {
          final currentIndex = page.round();
          _sessionTabIndex = currentIndex;
          print('🔍 Tab changed to: $currentIndex');
        }
      }
    });

    print('🔍 Page controller created with initialPage: $initialPage');

    // Inject global FAB overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalFABManager.instance.injectFAB(context);
    });
  }

  @override
  void deactivate() {
    print('🔍 NZBGetRoute deactivate() called');
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

  Widget _drawer() => ZagDrawer(page: ZagModule.NZBGET.key);

  Widget? _bottomNavigationBar() {
    if (ZagProfile.current.nzbgetEnabled) {
      return NZBGetNavigationBar(pageController: _pageController);
    }
    return null;
  }

  Widget _appBar() {
    List<String> profiles = ZagBox.profiles.keys.fold([], (value, element) {
      if (ZagBox.profiles.read(element)?.nzbgetEnabled ?? false)
        value.add(element);
      return value;
    });
    List<Widget>? actions;
    if (ZagProfile.current.nzbgetEnabled)
      actions = [
        Selector<NZBGetState, bool>(
          selector: (_, model) => model.error,
          builder: (context, error, widget) =>
              error ? Container() : const NZBGetAppBarStats(),
        ),
        ZagIconButton(
          icon: Icons.more_vert_rounded,
          onPressed: () async => _handlePopup(),
        ),
      ];
    return ZagAppBar.dropdown(
      title: ZagModule.NZBGET.title,
      useDrawer: widget.showDrawer,
      hideLeading: !widget.showDrawer,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: NZBGetNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    if (!ZagProfile.current.nzbgetEnabled)
      return ZagMessage.moduleNotEnabled(
        context: context,
        module: ZagModule.NZBGET.title,
      );
    return ZagPageView(
      controller: _pageController,
      children: [
        NZBGetQueue(
          refreshIndicatorKey: _refreshKeys[0],
        ),
        NZBGetHistory(
          refreshIndicatorKey: _refreshKeys[1],
        ),
      ],
    );
  }

  Future<void> _handlePopup() async {
    List<dynamic> values = await NZBGetDialogs.globalSettings(context);
    if (values[0])
      switch (values[1]) {
        case 'web_gui':
          ZagProfile profile = ZagProfile.current;
          await profile.nzbgetHost.openLink();
          break;
        case 'add_nzb':
          _addNZB();
          break;
        case 'sort':
          _sort();
          break;
        case 'server_details':
          _serverDetails();
          break;
        default:
          ZagLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  Future<void> _addNZB() async {
    List values = await NZBGetDialogs.addNZB(context);
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
    List values = await NZBGetDialogs.addNZBUrl(context);
    if (values[0])
      await _api
          .uploadURL(values[1])
          .then((_) => showZagSuccessSnackBar(
              title: 'Uploaded NZB (URL)', message: values[1]))
          .catchError((error) => showZagErrorSnackBar(
              title: 'Failed to Upload NZB', error: error));
  }

  Future<void> _addByFile() async {
    try {
      ZagFile? _file = await ZagFileSystem().read(context, [
        'nzb',
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
            message: 'Please select a valid file',
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

  Future<void> _sort() async {
    List values = await NZBGetDialogs.sortQueue(context);
    if (values[0])
      await _api.sortQueue(values[1]).then((_) {
        _refreshKeys[0]?.currentState?.show();
        showZagSuccessSnackBar(
            title: 'Sorted Queue', message: (values[1] as NZBGetSort?).name);
      }).catchError((error) {
        showZagErrorSnackBar(title: 'Failed to Sort Queue', error: error);
      });
  }

  Future<void> _serverDetails() async => NZBGetRoutes.STATISTICS.go();

  void _refreshProfile() {
    _api = NZBGetAPI.from(ZagProfile.current);
    _profileState = ZagProfile.current.toString();
    _refreshAllPages();
  }

  void _refreshAllPages() {
    for (var key in _refreshKeys) key?.currentState?.show();
  }
}
