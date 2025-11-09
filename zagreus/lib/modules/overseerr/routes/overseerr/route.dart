import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/overseerr.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/system/session_state.dart';

class OverseerrRoute extends StatefulWidget {
  const OverseerrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<OverseerrRoute> createState() => _State();
}

class _State extends State<OverseerrRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;
  int _currentPage = 0;
  late final bool _tabMemoryEnabled;

  // Session-based tab memory (cleared on app restart)
  static int? _sessionTabIndex;

  @override
  void initState() {
    super.initState();
    print('🔍 OverseerrRoute initState() called');

    _tabMemoryEnabled = ZagSessionState.instance.tabMemoryEnabled;

    // Read from session first, fallback to 0 (no database default for Overseerr)
    _currentPage = _tabMemoryEnabled ? _sessionTabIndex ?? 0 : 0;
    print('🔍 Reading saved index from session: $_currentPage');

    _pageController = ZagPageController(
      initialPage: _currentPage,
    )..addListener(_handlePageChanged);

    print('🔍 Page controller created with initialPage: $_currentPage');

    // Inject global FAB overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalFABManager.instance.injectFAB(context);
    });
  }

  @override
  void deactivate() {
    print('🔍 OverseerrRoute deactivate() called');
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
      module: ZagModule.OVERSEERR,
      drawer: _drawer(),
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _drawer() {
    return ZagDrawer(page: ZagModule.OVERSEERR.key);
  }

  Widget? _bottomNavigationBar() {
    if (context.read<OverseerrState>().enabled) {
      return OverseerrNavigationBar(pageController: _pageController);
    }
    return null;
  }

  Widget _appBar() {
    List<String> profiles = ZagBox.profiles.keys.fold(
      [],
      (value, element) {
        if (ZagBox.profiles.read(element)?.overseerrEnabled ?? false) {
          value.add(element);
        }
        return value;
      },
    );
    return ZagAppBar.dropdown(
      title: ZagModule.OVERSEERR.title,
      useDrawer: true,
      profiles: profiles,
      pageController: _pageController,
      scrollControllers: OverseerrNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    return Selector<OverseerrState, Tuple2<bool, bool>>(
      selector: (_, state) => Tuple2(state.enabled, state.isConfigured),
      builder: (context, data, _) {
        if (!data.item1) {
          return ZagMessage(
            text: 'Overseerr is not enabled',
            buttonText: 'Enable in Settings',
            onTap: () {
              SettingsRoutes.CONFIGURATION_OVERSEERR.go();
            },
          );
        }
        if (!data.item2) {
          return ZagMessage(
            text: 'Overseerr is not configured',
            buttonText: 'Configure',
            onTap: () {
              SettingsRoutes.CONFIGURATION_OVERSEERR.go();
            },
          );
        }
        return _pages();
      },
    );
  }

  Widget _pages() {
    return ZagPageView(
      controller: _pageController,
      children: const [
        OverseerrRequestsRoute(),
        OverseerrIssuesRoute(),
      ],
    );
  }

  void _handlePageChanged() {
    if (_pageController?.page?.round() != _currentPage) {
      final newPage = _pageController!.page!.round();
      setState(() {
        _currentPage = newPage;
      });
      if (_tabMemoryEnabled) {
        _sessionTabIndex = newPage;
        print('🔍 Tab changed to: $newPage');
      }
    }
  }
}
