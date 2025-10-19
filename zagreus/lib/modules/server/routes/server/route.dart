import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/server.dart';
import 'package:zagreus/modules/server/routes/server/widgets/navigation_bar.dart';

class ServerRoute extends StatefulWidget {
  const ServerRoute({Key? key}) : super(key: key);

  @override
  State<ServerRoute> createState() => _State();
}

class _State extends State<ServerRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = ServerDatabase.NAVIGATION_INDEX.read();
    _pageController = ZagPageController(
      initialPage: _currentPage,
    )..addListener(() {
        if (_pageController!.page?.round() != _currentPage) {
          setState(() {
            _currentPage = _pageController!.page!.round();
          });
        }
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
        _buildPlaceholder('System'),
        _buildPlaceholder('Array'),
        _buildPlaceholder('Docker'),
        _buildPlaceholder('VMs'),
      ],
    );
  }

  Widget _buildPlaceholder(String name) {
    return Center(
      child: Text(
        name,
        style: const TextStyle(fontSize: 32),
      ),
    );
  }
}
