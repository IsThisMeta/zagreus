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
import 'package:zagreus/modules/dashboard/routes/dashboard/widgets/appbar_search_action.dart';
import 'package:zagreus/modules/discover/routes/discover/z_chat_overlay.dart';
import 'package:zagreus/services/upcoming_widget_service.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/widgets/ui/global_fab_overlay.dart';
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
  ZagPageController? _pageController;
  bool _isAgentActive = false;

  @override
  void initState() {
    super.initState();

    print('🏠 Dashboard initState called');
    int page = DashboardDatabase.NAVIGATION_INDEX.read();
    _pageController = ZagPageController(initialPage: page);

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
        DashboardAppBarAgentAction(onPressed: _openAgentOverlay),
        const DashboardAppBarSearchAction(),
        SwitchViewAction(pageController: _pageController),
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

    if (!_isAgentActive) return mainContent;

    return Stack(
      children: [
        mainContent,
        Positioned.fill(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: const KeyedSubtree(
              key: ValueKey('dashboard_agent'),
              child: ZChatPage(),
            ),
          ),
        ),
      ],
    );
  }
}
