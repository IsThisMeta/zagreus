import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class GraphsRoute extends StatefulWidget {
  const GraphsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<GraphsRoute> createState() => _State();
}

class _State extends State<GraphsRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = ZagPageController(
        initialPage: TautulliDatabase.NAVIGATION_INDEX_GRAPHS.read());
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      pageController: _pageController,
      scrollControllers: TautulliGraphsNavigationBar.scrollControllers,
      title: 'Graphs',
      actions: const [
        TautulliGraphsTypeButton(),
      ],
    );
  }

  Widget _bottomNavigationBar() {
    return TautulliGraphsNavigationBar(pageController: _pageController);
  }

  Widget _body() {
    return ZagPageView(
      controller: _pageController,
      children: const [
        TautulliGraphsPlayByPeriodRoute(),
        TautulliGraphsStreamInformationRoute(),
      ],
    );
  }
}
