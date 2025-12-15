import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class AddMovieRoute extends StatefulWidget {
  final String query;

  const AddMovieRoute({
    Key? key,
    required this.query,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<AddMovieRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late ZagPageController _pageController;
  bool hasQuery = false;

  @override
  void initState() {
    super.initState();

    final page = RadarrDatabase.NAVIGATION_INDEX_ADD_MOVIE.read();
    hasQuery = widget.query.isNotEmpty;
    _pageController = ZagPageController(initialPage: hasQuery ? 0 : page);
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _bottomNavigationBar() {
    return RadarrAddMovieNavigationBar(pageController: _pageController);
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'radarr.AddMovie'.tr(),
      pageController: _pageController,
      scrollControllers: RadarrAddMovieNavigationBar.scrollControllers,
    );
  }

  Widget _body() {
    return ChangeNotifierProvider(
      create: (context) => RadarrAddMovieState(
        context,
        widget.query,
      ),
      builder: (context, _) => ZagPageView(
        controller: _pageController,
        children: [
          RadarrAddMovieSearchPage(
            autofocusSearchBar: hasQuery && _pageController.initialPage == 0,
          ),
          const RadarrAddMovieDiscoverPage(),
        ],
      ),
    );
  }
}
