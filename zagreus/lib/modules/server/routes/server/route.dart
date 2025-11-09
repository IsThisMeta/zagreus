import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/server.dart';
import 'package:zagreus/modules/server/routes/server/widgets/navigation_bar.dart';
import 'package:zagreus/modules/server/routes/server/pages/system.dart';
import 'package:zagreus/modules/server/routes/server/pages/array.dart';
import 'package:zagreus/modules/server/routes/server/pages/docker.dart';
import 'package:zagreus/modules/server/routes/server/pages/vms.dart';
import 'package:zagreus/system/session_state.dart';

class ServerRoute extends StatefulWidget {
  const ServerRoute({Key? key}) : super(key: key);

  @override
  State<ServerRoute> createState() => _State();
}

class _State extends State<ServerRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;
  int _currentPage = 0;
  late final bool _tabMemoryEnabled;

  @override
  void initState() {
    super.initState();
    _tabMemoryEnabled = ZagSessionState.instance.tabMemoryEnabled;
    _currentPage =
        _tabMemoryEnabled ? ServerDatabase.NAVIGATION_INDEX.read() : 0;
    _pageController = ZagPageController(
      initialPage: _currentPage,
    )..addListener(_handlePageChanged);

    // Inject global FAB overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalFABManager.instance.injectFAB(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.SERVER,
      drawer: ZagDrawer(page: ZagModule.SERVER.key),
      appBar: ZagAppBar(
        title: 'Server',
        useDrawer: true,
      ),
      bottomNavigationBar: ServerNavigationBar(pageController: _pageController),
      body: _body(),
    );
  }

  Widget _body() {
    return ZagPageView(
      controller: _pageController,
      children: [
        const ServerSystemPage(),
        const ServerArrayPage(),
        const ServerDockerPage(),
        const ServerVmPage(),
      ],
    );
  }

  void _handlePageChanged() {
    final controller = _pageController;
    if (controller == null || !controller.hasClients) return;

    final page = controller.page;
    if (page == null) return;

    final newIndex = page.round();
    if (newIndex == _currentPage) return;

    setState(() {
      _currentPage = newIndex;
    });

    if (_tabMemoryEnabled) {
      ServerDatabase.NAVIGATION_INDEX.update(newIndex);
      ZagSessionState.instance
          .setModuleTabPosition(ZagModule.SERVER.key, newIndex);
    }
  }

  @override
  void dispose() {
    _pageController?.removeListener(_handlePageChanged);
    _pageController?.dispose();
    super.dispose();
  }
}
