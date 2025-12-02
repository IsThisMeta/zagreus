import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/overseerr.dart';
import 'package:zagreus/router/routes/settings.dart';

class OverseerrRoute extends StatefulWidget {
  const OverseerrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<OverseerrRoute> createState() => _State();
}

class _State extends State<OverseerrRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;

  @override
  void initState() {
    super.initState();
    print('🔍 OverseerrRoute initState() called');

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
    print('🔍 OverseerrRoute deactivate() called');
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
      module: ZagModule.OVERSEERR,
      drawer: _drawer(),
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _drawer() {
    return ZagDrawer(page: ZagModule.OVERSEERR.key);
  }

  Widget? _bottomNavigationBar() {
    if (context.read<OverseerrState>().enabled) {
      return OverseerrNavigationBar(pageController: _pageController);
    }
    return null;
  }

  Widget _appBar() {
    List<String> profiles = ZagBox.profiles.keys.fold(
      [],
      (value, element) {
        if (ZagBox.profiles.read(element)?.overseerrEnabled ?? false) {
          value.add(element);
        }
        return value;
      },
    );
    
    final instanceName = ZagProfile.getActiveInstanceName('overseerr');
    final title = instanceName != null 
        ? '${ZagModule.OVERSEERR.title} $instanceName'
        : ZagModule.OVERSEERR.title;
    
    return ZagAppBar.dropdown(
      title: title,
      useDrawer: true,
      actions: _buildAppBarActions(),
      profiles: profiles,
      pageController: _pageController,
      scrollControllers: OverseerrNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    return Selector<OverseerrState, Tuple2<bool, bool>>(
      selector: (_, state) => Tuple2(state.enabled, state.isConfigured),
      builder: (context, data, _) {
        if (!data.item1) {
          return ZagMessage(
            text: 'Overseerr is not enabled',
            buttonText: 'Enable in Settings',
            onTap: () {
              SettingsRoutes.CONFIGURATION_OVERSEERR.go();
            },
          );
        }
        if (!data.item2) {
          return ZagMessage(
            text: 'Overseerr is not configured',
            buttonText: 'Configure',
            onTap: () {
              SettingsRoutes.CONFIGURATION_OVERSEERR.go();
            },
          );
        }
        return _pages();
      },
    );
  }

  List<Widget>? _buildAppBarActions() {
    if (!context.read<OverseerrState>().enabled) return null;
    return [
      IconButton(
        icon: const Icon(Icons.language_rounded),
        tooltip: 'Open Web UI',
        onPressed: _openWebUI,
      ),
    ];
  }

  void _openWebUI() {
    final host = context.read<OverseerrState>().host;
    if (host.isNotEmpty) {
      host.openLinkInApp();
    }
  }

  Widget _pages() {
    return ZagPageView(
      controller: _pageController,
      children: const [
        OverseerrRequestsRoute(),
        OverseerrIssuesRoute(),
      ],
    );
  }
}
