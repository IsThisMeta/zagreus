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

  @override
  void initState() {
    super.initState();

    print('🏠 Dashboard initState called');
    int page = DashboardDatabase.NAVIGATION_INDEX.read();
    _pageController = ZagPageController(initialPage: page);

    // Add listener to rebuild app bar when page changes
    _pageController?.addListener(() {
      if (mounted) setState(() {});
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
      scrollControllers: HomeNavigationBar.scrollControllers,
      pageController: _pageController,
      actions: [
        Builder(
          builder: (context) {
            final controller = _pageController;
            if (controller == null) return const SizedBox();
            final currentPage = controller.hasClients ? controller.page?.round() ?? 0 : 0;

            if (currentPage == 0) {
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

            // Calendar tab (page 1) - show view switcher for all users
            return SwitchViewAction(pageController: _pageController);
          },
        ),
      ],
    );
  }

  Widget _body() {
    final mainContent = ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => ZagPageView(
        controller: _pageController,
        children: [
          ModulesPage(key: ValueKey(ZagreusDatabase.ENABLED_PROFILE.read())),
          CalendarPage(key: ValueKey(ZagreusDatabase.ENABLED_PROFILE.read())),
        ],
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
