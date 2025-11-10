import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/system/session_state.dart';
import 'package:zagreus/router/routes/settings.dart';

class RadarrRoute extends StatefulWidget {
  const RadarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<RadarrRoute> createState() => _State();
}

class _State extends State<RadarrRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State<RadarrMissingRoute>> _missingRouteKey = GlobalKey();
  ZagPageController? _pageController;
  int _currentPage = 0;
  late final bool _tabMemoryEnabled;

  // Session-based tab memory (cleared on app restart)
  static int? _sessionTabIndex;

  @override
  void initState() {
    super.initState();
    print('🔍 RadarrRoute initState() called');

    _tabMemoryEnabled = ZagSessionState.instance.tabMemoryEnabled;

    // Read from session first, fallback to database
    _currentPage = _tabMemoryEnabled
        ? _sessionTabIndex ?? RadarrDatabase.NAVIGATION_INDEX.read()
        : 0;
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
    print('🔍 RadarrRoute deactivate() called');
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
      module: ZagModule.RADARR,
      drawer: _drawer(),
      endDrawer: ZagGlobalFABManager.instance.getEndDrawer(),
      endDrawerEnableOpenDragGesture: 25.0,
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _drawer() {
    return ZagDrawer(page: ZagModule.RADARR.key);
  }

  Widget? _bottomNavigationBar() {
    if (context.read<RadarrState>().enabled) {
      return RadarrNavigationBar(pageController: _pageController);
    }
    return null;
  }

  Widget _appBar() {
    List<String> profiles = ZagBox.profiles.keys.fold(
      [],
      (value, element) {
        if (ZagBox.profiles.read(element)?.radarrEnabled ?? false) {
          value.add(element);
        }
        return value;
      },
    );
    List<Widget>? actions;
    if (context.watch<RadarrState>().enabled) {
      actions = [
        const RadarrAppBarAddMoviesAction(),
        if (_currentPage == 2) // Missing tab
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () {
              final missingState = _missingRouteKey.currentState;
              if (missingState != null) {
                (missingState as dynamic).toggleMultiSelect();
              }
            },
            tooltip: 'Multi-Select',
          ),
        const RadarrAppBarGlobalSettingsAction(),
      ];
    }
    return ZagAppBar.dropdown(
      title: ZagModule.RADARR.title,
      useDrawer: true,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: RadarrNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    return Selector<RadarrState, Tuple2<bool, bool>>(
      selector: (_, state) => Tuple2(state.enabled, state.isConfigured),
      builder: (context, data, _) {
        final enabled = data.item1;
        final isConfigured = data.item2;

        if (!enabled) {
          return ZagMessage.moduleNotEnabled(
            context: context,
            module: 'Radarr',
          );
        }

        if (!isConfigured) {
          return ZagMessage(
            text:
                'Please configure your Radarr connection details in Settings.',
            buttonText: 'Go to Settings',
            onTap: () => SettingsRoutes.CONFIGURATION_RADARR.go(),
          );
        }

        return ZagPageView(
          controller: _pageController,
          children: [
            const RadarrCatalogueRoute(),
            const RadarrUpcomingRoute(),
            RadarrMissingRoute(key: _missingRouteKey),
            const RadarrMoreRoute(),
          ],
        );
      },
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
