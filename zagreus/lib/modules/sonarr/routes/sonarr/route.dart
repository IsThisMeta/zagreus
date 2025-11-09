import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/system/session_state.dart';

class SonarrRoute extends StatefulWidget {
  const SonarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SonarrRoute> createState() => _State();
}

class _State extends State<SonarrRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;

  @override
  void initState() {
    super.initState();
    // Try to get saved position from session state, default to 0 (first tab)
    final savedIndex =
        ZagSessionState.instance.getModuleTabPosition('sonarr') ?? 0;
    print('🔍 SonarrRoute initState() called');
    print('🔍 Reading saved index from session: $savedIndex');
    _pageController = ZagPageController(
      initialPage: savedIndex,
    );
    print('🔍 Page controller created with initialPage: $savedIndex');

    // Listen to page changes and save immediately
    _pageController!.addListener(_onPageChanged);

    // Inject global FAB overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalFABManager.instance.injectFAB(context);
    });
  }

  void _onPageChanged() {
    if (_pageController?.hasClients ?? false) {
      final page = _pageController!.page;
      if (page != null) {
        final currentIndex = page.round();
        print('🔍 Tab changed to: $currentIndex');
        // Save immediately when tab changes
        ZagSessionState.instance.setModuleTabPosition('sonarr', currentIndex);
      }
    }
  }

  @override
  void deactivate() {
    print('🔍 SonarrRoute deactivate() called');
    super.deactivate();
  }

  @override
  void dispose() {
    print('🔍 SonarrRoute dispose() called');
    _pageController?.removeListener(_onPageChanged);
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.SONARR,
      drawer: _drawer(),
      appBar: _appBar(),
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _drawer() {
    return ZagDrawer(page: ZagModule.SONARR.key);
  }

  Widget? _bottomNavigationBar() {
    if (context.read<SonarrState>().enabled) {
      return SonarrNavigationBar(pageController: _pageController);
    }
    return null;
  }

  PreferredSizeWidget _appBar() {
    List<String> profiles = ZagBox.profiles.keys.fold(
      [],
      (value, element) {
        if (ZagBox.profiles.read(element)?.sonarrEnabled ?? false) {
          value.add(element);
        }
        return value;
      },
    );
    List<Widget>? actions;
    if (context.watch<SonarrState>().enabled) {
      actions = [
        const SonarrAppBarAddSeriesAction(),
        const SonarrAppBarGlobalSettingsAction(),
      ];
    }
    return ZagAppBar.dropdown(
      title: ZagModule.SONARR.title,
      useDrawer: true,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: SonarrNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    return Selector<SonarrState, Tuple2<bool, bool>>(
      selector: (_, state) => Tuple2(state.enabled, state.isConfigured),
      builder: (context, data, _) {
        final enabled = data.item1;
        final isConfigured = data.item2;

        if (!enabled) {
          return ZagMessage.moduleNotEnabled(
            context: context,
            module: 'Sonarr',
          );
        }

        if (!isConfigured) {
          return ZagMessage(
            text:
                'Please configure your Sonarr connection details in Settings.',
            buttonText: 'Go to Settings',
            onTap: () => SettingsRoutes.CONFIGURATION_SONARR.go(),
          );
        }

        return ZagPageView(
          controller: _pageController,
          children: const [
            SonarrCatalogueRoute(),
            SonarrUpcomingRoute(),
            SonarrMissingRoute(),
            SonarrMoreRoute(),
          ],
        );
      },
    );
  }
}
