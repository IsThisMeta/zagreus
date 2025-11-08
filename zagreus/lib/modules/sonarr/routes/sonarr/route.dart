import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/settings.dart';

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
    final savedIndex = SonarrDatabase.NAVIGATION_INDEX.read();
    print('🔍 SonarrRoute initState() called');
    print('🔍 Reading saved index from database: $savedIndex');
    _pageController = ZagPageController(
      initialPage: savedIndex,
    );
    print('🔍 Page controller created with initialPage: $savedIndex');
  }

  void _saveCurrentPage() {
    if (_pageController?.hasClients ?? false) {
      final page = _pageController!.page;
      print('🔍 Current page (double): $page');
      final currentIndex = (page?.round()) ?? 0;
      print('🔍 Saving index: $currentIndex');
      SonarrDatabase.NAVIGATION_INDEX.update(currentIndex);
      print('🔍 Saved to database');
    } else {
      print('🔍 Page controller has no clients or is null, not saving');
    }
  }

  @override
  void deactivate() {
    print('🔍 SonarrRoute deactivate() called');
    _saveCurrentPage();
    super.deactivate();
  }

  @override
  void dispose() {
    print('🔍 SonarrRoute dispose() called');
    print('🔍 _pageController: $_pageController');
    print('🔍 hasClients: ${_pageController?.hasClients}');
    _saveCurrentPage();
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
      floatingActionButton: ZagreusDatabase.MODULE_SWITCHER_FAB_ENABLED.read()
          ? ZagModuleSwitcherFAB(
              currentModuleKey: ZagModule.SONARR.key,
            )
          : null,
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
