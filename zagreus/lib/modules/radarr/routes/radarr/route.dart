import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
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

  @override
  void initState() {
    super.initState();
    print('🔍 RadarrRoute initState() called');

    _currentPage = RadarrDatabase.NAVIGATION_INDEX.read();
    print('🔍 Loaded initial index: $_currentPage');

    _pageController = ZagPageController(
      initialPage: _currentPage,
    )..addListener(_handlePageChanged);

    print('🔍 Page controller created with initialPage: $_currentPage');

    // Inject global cube overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalCubeManager.instance.injectCube(context);
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
      endDrawer: ZagGlobalCubeManager.instance.getEndDrawer(),
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
    
    // Get instances for the current profile
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'radarr');
    final hasInstances = instances.isNotEmpty;
    
    List<Widget>? actions;
    if (context.watch<RadarrState>().enabled) {
      actions = [
        // Instance selector - only show if there are instances
        if (hasInstances)
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Switch Instance',
            onPressed: _showInstanceSelector,
          ),
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
    // Build title with instance name if active
    final instanceName = ZagProfile.getActiveInstanceName('radarr');
    final title = instanceName != null 
        ? '${ZagModule.RADARR.title} $instanceName'
        : ZagModule.RADARR.title;
    
    return ZagAppBar.dropdown(
      title: title,
      useDrawer: true,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: RadarrNavigationBar.scrollControllers,
    );
  }

  void _showInstanceSelector() async {
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'radarr');
    final currentInstance = ZagInstanceContext().getActiveInstance('radarr');
    
    // Build list: Main + all instances
    final options = <String?>[null, ...instances];
    
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Instance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((instanceKey) {
            final isSelected = instanceKey == currentInstance;
            final name = instanceKey == null 
                ? ZagModule.RADARR.title
                : '${ZagModule.RADARR.title} ${ZagProfile.getInstanceDisplayName(instanceKey) ?? ""}';
            return ListTile(
              title: Text(name),
              leading: isSelected 
                  ? Icon(Icons.check, color: ZagModule.RADARR.color)
                  : const SizedBox(width: 24),
              onTap: () => Navigator.pop(context, instanceKey),
            );
          }).toList(),
        ),
      ),
    );
    
    // null means dialog was dismissed, empty string would mean "Main" was selected
    if (!mounted) return;
    
    // Check if selection changed
    if (result != currentInstance) {
      ZagInstanceContext().setActiveInstance('radarr', result);
      context.read<RadarrState>().reset();
      setState(() {}); // Refresh app bar title
    }
  }

  List<Widget> _buildQueueDrawerAction() {
    if (!ZagreusDatabase.DOWNLOADS_DRAWER_ENABLED.read()) return [];
    return [
      IconButton(
        icon: const Icon(Icons.live_tv_rounded),
        tooltip: 'Queue',
        onPressed: _openQueueDrawer,
      ),
    ];
  }

  void _openQueueDrawer() {
    final scaffoldState = _scaffoldKey.currentState;
    if (scaffoldState?.hasEndDrawer ?? false) {
      scaffoldState?.openEndDrawer();
    }
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
            QueueRoute(
              embedInNavigation: true,
              scrollController: RadarrNavigationBar.scrollControllers[3],
            ),
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
    }
  }
}
