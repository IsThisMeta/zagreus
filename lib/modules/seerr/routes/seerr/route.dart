import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/seerr.dart';
import 'package:zagreus/router/routes/settings.dart';

class SeerrRoute extends StatefulWidget {
  const SeerrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SeerrRoute> createState() => _State();
}

class _State extends State<SeerrRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;

  @override
  void initState() {
    super.initState();
    print('🔍 SeerrRoute initState() called');

    _pageController = ZagPageController(
      initialPage: 0,
    );

    print('🔍 Page controller created with initialPage: 0');

    // Inject global cube overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalCubeManager.instance.injectCube(context);
    });
  }

  @override
  void deactivate() {
    print('🔍 SeerrRoute deactivate() called');
    super.deactivate();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.SEERR,
      drawer: _drawer(),
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _drawer() {
    return ZagDrawer(page: ZagModule.SEERR.key);
  }

  Widget? _bottomNavigationBar() {
    if (context.read<SeerrState>().enabled) {
      return SeerrNavigationBar(pageController: _pageController);
    }
    return null;
  }

  Widget _appBar() {
    // Get current profile and its seerr instances only
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'seerr');
    
    // Build list: main profile first, then shadow instances
    List<String> profiles = [];
    if (ZagBox.profiles.read(currentProfile)?.seerrEnabled ?? false) {
      profiles.add(currentProfile);
    }
    profiles.addAll(instances);
    
    final instanceName = ZagProfile.getActiveInstanceName('seerr');
    final title = instanceName != null 
        ? '${ZagModule.SEERR.title} $instanceName'
        : ZagModule.SEERR.title;
    
    return ZagAppBar.dropdown(
      title: title,
      useDrawer: true,
      actions: _buildAppBarActions(),
      profiles: profiles,
      pageController: _pageController,
      scrollControllers: SeerrNavigationBar.scrollControllers,
      onProfileSelected: (selected) {
        final parsed = ZagProfile.parseShadowKey(selected);
        if (parsed != null) {
          ZagInstanceContext().setActiveInstance('seerr', selected);
        } else {
          ZagInstanceContext().clearActiveInstance('seerr');
        }
        setState(() {});
        context.read<SeerrState>().reset();
      },
    );
  }

  Widget _body() {
    return Selector<SeerrState, Tuple2<bool, bool>>(
      selector: (_, state) => Tuple2(state.enabled, state.isConfigured),
      builder: (context, data, _) {
        if (!data.item1) {
          return ZagMessage(
            text: 'seerr.NotEnabled'.tr(),
            buttonText: 'seerr.EnableInSettings'.tr(),
            onTap: () {
              SettingsRoutes.CONFIGURATION_SEERR.go();
            },
          );
        }
        if (!data.item2) {
          return ZagMessage(
            text: 'seerr.NotConfigured'.tr(),
            buttonText: 'seerr.Configure'.tr(),
            onTap: () {
              SettingsRoutes.CONFIGURATION_SEERR.go();
            },
          );
        }
        return _pages();
      },
    );
  }

  List<Widget>? _buildAppBarActions() {
    if (!context.read<SeerrState>().enabled) return null;
    return [
      IconButton(
        icon: const Icon(Icons.language_rounded),
        tooltip: 'seerr.OpenWebUi'.tr(),
        onPressed: _openWebUI,
      ),
    ];
  }

  void _openWebUI() {
    final host = context.read<SeerrState>().host;
    if (host.isNotEmpty) {
      host.openLinkInApp();
    }
  }

  Widget _pages() {
    return ZagPageView(
      controller: _pageController,
      children: const [
        SeerrRequestsRoute(),
        SeerrIssuesRoute(),
      ],
    );
  }
}
