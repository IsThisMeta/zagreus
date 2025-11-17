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
import 'package:zagreus/router/routes/discover.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/widgets/ui/global_fab_overlay.dart';

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

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.DASHBOARD,
      body: _body(),
      appBar: _appBar(),
      drawer: ZagDrawer(page: ZagModule.DASHBOARD.key),
      bottomNavigationBar: HomeNavigationBar(pageController: _pageController),
    );
  }

  PreferredSizeWidget _appBar() {
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
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.smart_toy),
                    tooltip: 'Z Agent',
                    onPressed: () => DiscoverRoutes.HOME.push(queryParams: {'agent': 'true'}),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    tooltip: 'Search',
                    onPressed: () => DiscoverRoutes.HOME.push(queryParams: {'search': 'true'}),
                  ),
                ],
              );
            }
            return SwitchViewAction(pageController: _pageController);
          },
        ),
      ],
    );
  }

  Widget _body() {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => ZagPageView(
        controller: _pageController,
        children: [
          ModulesPage(key: ValueKey(ZagreusDatabase.ENABLED_PROFILE.read())),
          CalendarPage(key: ValueKey(ZagreusDatabase.ENABLED_PROFILE.read())),
        ],
      ),
    );
  }
}
