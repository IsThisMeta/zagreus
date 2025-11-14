import 'package:flutter/material.dart';

import 'package:zagreus/modules.dart';
import 'package:zagreus/database/tables/dashboard.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/pages/calendar.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/pages/modules.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/switch_view_action.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/navigation_bar.dart';
import 'package:zagreus/services/upcoming_widget_service.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/widgets/ui/global_fab_overlay.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/modules/discover/routes/discover/route.dart';
import 'package:zagreus/modules/discover/routes/discover/z_chat_overlay.dart';

class DashboardRoute extends StatefulWidget {
  const DashboardRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardRoute> createState() => _State();
}

class _State extends State<DashboardRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;
  final _moviesDiscoverKey = GlobalKey<DiscoverHomeRouteState>();
  final _showsDiscoverKey = GlobalKey<DiscoverHomeRouteState>();
  bool _moviesSearchActive = false;
  bool _showsSearchActive = false;
  int _currentPageIndex = 0;

  bool get _isPremiumDashboard => ZagreusPro.isEnabled;
  int get _calendarPageIndex => _isPremiumDashboard ? 2 : 1;

  @override
  void initState() {
    super.initState();

    print('🏠 Dashboard initState called');
    int page = DashboardDatabase.NAVIGATION_INDEX.read();
    final maxPage = _isPremiumDashboard ? 3 : 1;
    final int initialPage = page.clamp(0, maxPage).toInt();
    _currentPageIndex = initialPage;
    if (initialPage != page) {
      DashboardDatabase.NAVIGATION_INDEX.update(initialPage);
    }
    _pageController = ZagPageController(initialPage: initialPage);
    _pageController?.addListener(_handlePageChange);

    // Inject global FAB overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalFABManager.instance.injectFAB(context);
    });

    // Update home screen widget with Radarr/Sonarr upcoming content
    print('🏠 Dashboard: Platform is iOS? ${ZagPlatform.isIOS}');
    if (ZagPlatform.isIOS) {
      print('🏠 Dashboard: Scheduling widget update...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('🏠 Dashboard: PostFrameCallback triggered!');
        _updateWidget();
      });
    }
  }

  Future<void> _updateWidget() async {
    try {
      print('🔄 Dashboard: Starting widget update...');
      final radarrState = context.read<RadarrState>();
      final sonarrState = context.read<SonarrState>();

      print(
          '🔄 Dashboard: Radarr enabled=${radarrState.enabled}, Sonarr enabled=${sonarrState.enabled}');

      // Wait a bit for states to initialize if needed
      await Future.delayed(const Duration(milliseconds: 500));

      await UpcomingWidgetService.updateWidget(
        radarrState: radarrState,
        sonarrState: sonarrState,
        skipIfAlreadyUpdated: true,
      );
    } catch (e) {
      print('❌ Dashboard: Widget update error: $e');
    }
  }

  void _handlePageChange() {
    final controller = _pageController;
    if (controller == null) return;
    final next = controller.page?.round() ?? _currentPageIndex;
    if (next == _currentPageIndex) return;
    setState(() => _currentPageIndex = next);
    if (_isPremiumDashboard) {
      if (next != 0) {
        _moviesDiscoverKey.currentState?.closeSearchOverlayExternally();
      }
      if (next != 1) {
        _showsDiscoverKey.currentState?.closeSearchOverlayExternally();
      }
    }
  }

  @override
  void dispose() {
    _pageController?.removeListener(_handlePageChange);
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.DASHBOARD,
      body: _body(),
      appBar: _appBar(),
      drawer: ZagDrawer(page: ZagModule.DASHBOARD.key),
      bottomNavigationBar: _isPremiumDashboard
          ? ProHomeNavigationBar(pageController: _pageController)
          : HomeNavigationBar(pageController: _pageController),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'Zagreus',
      useDrawer: true,
      scrollControllers: _isPremiumDashboard
          ? ProHomeNavigationBar.scrollControllers
          : HomeNavigationBar.scrollControllers,
      pageController: _pageController,
      actions: _buildAppBarActions(),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isPremiumDashboard) {
      final actions = <Widget>[];
      if (_currentPageIndex == _calendarPageIndex) {
        actions.add(
          SwitchViewAction(
            pageController: _pageController,
            calendarPageIndex: _calendarPageIndex,
          ),
        );
      }
      if (_currentPageIndex == 0 || _currentPageIndex == 1) {
        final isSearchActive =
            _currentPageIndex == 0 ? _moviesSearchActive : _showsSearchActive;
        actions.add(
          IconButton(
            icon: Icon(
              isSearchActive ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: () {
              if (isSearchActive) {
                _handleProSearchClose();
              } else {
                _handleProSearchPressed();
              }
            },
          ),
        );
      }
      return actions;
    }
    return [
      SwitchViewAction(
        pageController: _pageController,
        calendarPageIndex: _calendarPageIndex,
      ),
    ];
  }

  void _handleProSearchPressed() {
    if (_currentPageIndex == 0) {
      _moviesDiscoverKey.currentState?.openSearchOverlayExternally();
    } else if (_currentPageIndex == 1) {
      _showsDiscoverKey.currentState?.openSearchOverlayExternally();
    }
  }

  void _handleProSearchClose() {
    if (_currentPageIndex == 0) {
      _moviesDiscoverKey.currentState?.closeSearchOverlayExternally();
    } else if (_currentPageIndex == 1) {
      _showsDiscoverKey.currentState?.closeSearchOverlayExternally();
    }
  }

  void _onProSearchStateChanged(DiscoverEmbeddedTab tab, bool active) {
    bool shouldUpdate = false;
    if (tab == DiscoverEmbeddedTab.movies && _moviesSearchActive != active) {
      _moviesSearchActive = active;
      shouldUpdate = true;
    } else if (tab == DiscoverEmbeddedTab.shows &&
        _showsSearchActive != active) {
      _showsSearchActive = active;
      shouldUpdate = true;
    }
    if (shouldUpdate) setState(() {});
  }

  Widget _body() {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) =>
          _isPremiumDashboard ? _premiumBody() : _standardBody(),
    );
  }

  Widget _standardBody() {
    return ZagPageView(
      controller: _pageController,
      children: [
        ModulesPage(key: ValueKey(ZagreusDatabase.ENABLED_PROFILE.read())),
        CalendarPage(key: ValueKey(ZagreusDatabase.ENABLED_PROFILE.read())),
      ],
    );
  }

  Widget _premiumBody() {
    final profileId = ZagreusDatabase.ENABLED_PROFILE.read();
    return ZagPageView(
      controller: _pageController,
      children: [
        KeyedSubtree(
          key: ValueKey('dashboard_movies_$profileId'),
          child: DiscoverHomeRoute(
            key: _moviesDiscoverKey,
            embeddedTab: DiscoverEmbeddedTab.movies,
            onSearchStateChanged: (active) =>
                _onProSearchStateChanged(DiscoverEmbeddedTab.movies, active),
          ),
        ),
        KeyedSubtree(
          key: ValueKey('dashboard_shows_$profileId'),
          child: DiscoverHomeRoute(
            key: _showsDiscoverKey,
            embeddedTab: DiscoverEmbeddedTab.shows,
            onSearchStateChanged: (active) =>
                _onProSearchStateChanged(DiscoverEmbeddedTab.shows, active),
          ),
        ),
        CalendarPage(key: ValueKey(profileId)),
        const ZChatPage(),
      ],
    );
  }
}
