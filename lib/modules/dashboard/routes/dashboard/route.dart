import 'package:flutter/material.dart';

import 'package:zagreus/modules.dart';
import 'package:zagreus/database/tables/dashboard.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/pages/calendar.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/pages/modules.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/switch_view_action.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/navigation_bar.dart';
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/appbar_agent_action.dart';
import 'package:zagreus/services/upcoming_widget_service.dart';
import 'package:zagreus/router/routes/discover.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/widgets/ui/global_cube_overlay.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/modules/discover/routes/discover/z_chat_overlay.dart';
import 'package:zagreus/router/routes/settings.dart';

class DashboardRoute extends StatefulWidget {
  const DashboardRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardRoute> createState() => _State();
}

class _State extends State<DashboardRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _agentChatKey = GlobalKey<ZChatPageState>();
  ZagPageController? _pageController;
  bool _isAgentActive = false;
  int? _currentPage;

  @override
  void initState() {
    super.initState();

    print('🏠 Dashboard initState called');
    int page = DashboardDatabase.NAVIGATION_INDEX.read();

    // Ensure the initial page is valid for the visible tabs
    final visiblePageCount = _getVisiblePageCount();
    if (page >= visiblePageCount) {
      page = 0;
    }

    _pageController = ZagPageController(initialPage: page);
    _currentPage = page;

    // Add listener to rebuild app bar when page changes
    // Only rebuild when the page index actually changes, not during animation
    _pageController?.addListener(() {
      if (mounted) {
        final newPage = _pageController!.page?.round();
        if (newPage != null && newPage != _currentPage) {
          setState(() {
            _currentPage = newPage;
          });
        }
      }
    });

    // Inject global cube overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalCubeManager.instance.injectCube(context);
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

  int _getVisiblePageCount() {
    int count = 0;
    if (ZagreusDatabase.DASHBOARD_SHOW_MODULES_TAB.read()) count++;
    if (ZagreusDatabase.SHOW_CALENDAR_TAB.read()) count++;
    return count;
  }

  List<Widget> _getVisiblePages() {
    final List<Widget> pages = [];
    if (ZagreusDatabase.DASHBOARD_SHOW_MODULES_TAB.read()) {
      pages.add(ModulesPage(key: ValueKey(ZagreusDatabase.ENABLED_PROFILE.read())));
    }
    if (ZagreusDatabase.SHOW_CALENDAR_TAB.read()) {
      pages.add(CalendarPage(key: ValueKey(ZagreusDatabase.ENABLED_PROFILE.read())));
    }
    return pages;
  }

  int? _getVisiblePageIndex(int absoluteIndex) {
    // Maps absolute page indices (0 = modules, 1 = calendar) to visible page indices
    if (absoluteIndex == 0 && ZagreusDatabase.DASHBOARD_SHOW_MODULES_TAB.read()) {
      return 0; // Modules is always first if visible
    }
    if (absoluteIndex == 1 && ZagreusDatabase.SHOW_CALENDAR_TAB.read()) {
      // Calendar is second if modules is visible, first otherwise
      return ZagreusDatabase.DASHBOARD_SHOW_MODULES_TAB.read() ? 1 : 0;
    }
    return null; // Page is not visible
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
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

  void _openAgentOverlay() {
    if (_isAgentActive) return;
    setState(() {
      _isAgentActive = true;
    });
  }

  void _closeAgentOverlay() {
    if (!_isAgentActive) return;
    setState(() {
      _isAgentActive = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _clearAgentChat() {
    _agentChatKey.currentState?.clearChat();
  }

  void _showZAssistantSettings() {
    SettingsRoutes.Z_AGENT.go();
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.DASHBOARD,
      body: _body(),
      appBar: _appBar(),
      drawer: ZagDrawer(page: ZagModule.DASHBOARD.key),
      bottomNavigationBar: _isAgentActive ? null : HomeNavigationBar(pageController: _pageController),
    );
  }

  PreferredSizeWidget _appBar() {
    if (_isAgentActive) {
      return ZagAppBar(
        title: 'Z Agent',
        useDrawer: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _clearAgentChat,
            tooltip: 'Clear chat',
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showZAssistantSettings,
            tooltip: 'Z Agent Settings',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeAgentOverlay,
            tooltip: 'Close',
          ),
        ],
      );
    }

    return ZagAppBar(
      title: 'Zagreus',
      useDrawer: true,
      scrollControllers: HomeNavigationBar.getVisibleScrollControllers(),
      pageController: _pageController,
      actions: [
        Builder(
          builder: (context) {
            final controller = _pageController;
            if (controller == null) return const SizedBox();
            final currentPage = controller.hasClients ? controller.page?.round() ?? 0 : 0;

            // Check which page we're on based on visible tabs
            final modulesIndex = _getVisiblePageIndex(0); // 0 = modules
            final calendarIndex = _getVisiblePageIndex(1); // 1 = calendar

            if (modulesIndex != null && currentPage == modulesIndex) {
              // Modules tab - show tier-based icons
              final isMegaOrUltra = ZagreusMega.isEnabled || ZagreusUltra.isEnabled;
              final isPro = ZagreusPro.isEnabled;

              if (isMegaOrUltra) {
                // Mega/Ultra: Show both Agent and Search
                return Row(
                  children: [
                    DashboardAppBarAgentAction(onPressed: _openAgentOverlay),
                    IconButton(
                      icon: const Icon(Icons.search_rounded),
                      tooltip: 'Search',
                      onPressed: () => DiscoverRoutes.HOME.go(queryParams: {'search': 'true'}),
                    ),
                  ],
                );
              } else if (isPro) {
                // Pro: Show only Search
                return IconButton(
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search',
                  onPressed: () => DiscoverRoutes.HOME.go(queryParams: {'search': 'true'}),
                );
              } else {
                // Free users: no app bar actions (drawer is Pro-only)
                // Don't show download icon since they can't access the drawer
                return const SizedBox();
              }
            }

            if (calendarIndex != null && currentPage == calendarIndex) {
              // Calendar tab - show view switcher for all users
              return SwitchViewAction(pageController: _pageController);
            }

            // Default: show nothing
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _body() {
    final mainContent = ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => ZagreusDatabase.DASHBOARD_SHOW_MODULES_TAB.listenableBuilder(
        builder: (context, _) => ZagreusDatabase.SHOW_CALENDAR_TAB.listenableBuilder(
          builder: (context, _) {
            final visiblePages = _getVisiblePages();
            if (visiblePages.isEmpty) {
              return const Center(
                child: Text('No tabs enabled. Please enable at least one tab in Settings > Navigation.'),
              );
            }
            return ZagPageView(
              controller: _pageController,
              children: visiblePages,
            );
          },
        ),
      ),
    );

    return Stack(
      children: [
        mainContent,
        Positioned.fill(
          child: Offstage(
            offstage: !_isAgentActive,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ZChatPage(key: _agentChatKey),
            ),
          ),
        ),
      ],
    );
  }
}
