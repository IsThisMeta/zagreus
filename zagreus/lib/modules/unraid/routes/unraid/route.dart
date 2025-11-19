import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/unraid.dart';
import 'package:zagreus/modules/unraid/routes/unraid/widgets/navigation_bar.dart';
import 'package:zagreus/modules/unraid/routes/unraid/pages/system.dart';
import 'package:zagreus/modules/unraid/routes/unraid/pages/array.dart';
import 'package:zagreus/modules/unraid/routes/unraid/pages/docker.dart';
import 'package:zagreus/modules/unraid/routes/unraid/pages/vms.dart';

class UnraidRoute extends StatefulWidget {
  const UnraidRoute({Key? key}) : super(key: key);

  @override
  State<UnraidRoute> createState() => _State();
}

class _State extends State<UnraidRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;
  int _currentPage = UnraidDatabase.NAVIGATION_INDEX.read();

  @override
  void initState() {
    super.initState();
    _pageController = ZagPageController(
      initialPage: _currentPage,
    )..addListener(_handlePageChanged);

    // Inject global cube overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalCubeManager.instance.injectCube(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.UNRAID,
      drawer: ZagDrawer(page: ZagModule.UNRAID.key),
      appBar: ZagAppBar(
        title: 'Unraid',
        useDrawer: true,
        actions: _buildAppBarActions(),
      ),
      bottomNavigationBar: UnraidNavigationBar(pageController: _pageController),
      body: _body(),
    );
  }

  Widget _body() {
    return ZagPageView(
      controller: _pageController,
      children: [
        const UnraidSystemPage(),
        const UnraidArrayPage(),
        const UnraidDockerPage(),
        const UnraidVmPage(),
      ],
    );
  }

  List<Widget>? _buildAppBarActions() {
    if (!ZagreusDatabase.DOWNLOADS_DRAWER_ENABLED.read()) return null;
    return [
      IconButton(
        icon: const Icon(Icons.download_rounded),
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

  }

  @override
  void dispose() {
    _pageController?.removeListener(_handlePageChanged);
    _pageController?.dispose();
    super.dispose();
  }
}
