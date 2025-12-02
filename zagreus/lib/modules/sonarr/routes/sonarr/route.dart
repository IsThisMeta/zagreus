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
    print('🔍 SonarrRoute initState() called');
    final savedIndex = SonarrDatabase.NAVIGATION_INDEX.read();
    _pageController = ZagPageController(
      initialPage: savedIndex,
    );
    print('🔍 Page controller created with initialPage: $savedIndex');

    // Inject global cube overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalCubeManager.instance.injectCube(context);
    });
  }

  @override
  void deactivate() {
    print('🔍 SonarrRoute deactivate() called');
    super.deactivate();
  }

  @override
  void dispose() {
    print('🔍 SonarrRoute dispose() called');
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.SONARR,
      drawer: _drawer(),
      endDrawer: ZagGlobalCubeManager.instance.getEndDrawer(),
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
    
    final instanceName = ZagProfile.getActiveInstanceName('sonarr');
    final title = instanceName != null 
        ? '${ZagModule.SONARR.title} $instanceName'
        : ZagModule.SONARR.title;
    
    return ZagAppBar.dropdown(
      title: title,
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
          children: [
            const SonarrCatalogueRoute(),
            const SonarrUpcomingRoute(),
            const SonarrMissingRoute(),
            QueueRoute(
              embedInNavigation: true,
              scrollController: SonarrNavigationBar.scrollControllers[3],
            ),
          ],
        );
      },
    );
  }
}
