import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SeriesSeasonDetailsRoute extends StatefulWidget {
  final int seriesId;
  final int seasonNumber;

  const SeriesSeasonDetailsRoute({
    Key? key,
    required this.seriesId,
    required this.seasonNumber,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SeriesSeasonDetailsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController? _pageController;
  ZagLoadingState _automaticLoadingState = ZagLoadingState.INACTIVE;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: SonarrDatabase.NAVIGATION_INDEX_SEASON_DETAILS.read(),
    );
  }

  Future<void> _automatic() async {
    Future<void> setLoadingState(ZagLoadingState state) async {
      if (this.mounted) setState(() => _automaticLoadingState = state);
    }

    setLoadingState(ZagLoadingState.ACTIVE);
    SonarrAPIController()
        .automaticSeasonSearch(
          context: context,
          seriesId: widget.seriesId,
          seasonNumber: widget.seasonNumber,
        )
        .whenComplete(() => setLoadingState(ZagLoadingState.INACTIVE));
  }

  Future<void> _manual() async {
    return SonarrRoutes.RELEASES.go(queryParams: {
      'series': widget.seriesId.toString(),
      'season': widget.seasonNumber.toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar:
          context.watch<SonarrState>().enabled ? _bottomNavigationBar() : null,
      body: _body(),
    );
  }

  Widget _appBar() {
    String _season;
    switch (widget.seasonNumber) {
      case -1:
        _season = 'sonarr.AllSeasons'.tr();
        break;
      case 0:
        _season = 'sonarr.Specials'.tr();
        break;
      default:
        _season =
            'sonarr.SeasonNumber'.tr(args: [widget.seasonNumber.toString()]);
        break;
    }

    List<Widget>? _actions;
    if (widget.seasonNumber >= 0) {
      _actions = [
        ZagButton(
          type: ZagButtonType.TEXT,
          text: 'sonarr.Automatic'.tr(),
          icon: Icons.search_rounded,
          onTap: _automatic,
          loadingState: _automaticLoadingState,
        ),
        ZagButton.text(
          text: 'sonarr.Interactive'.tr(),
          icon: Icons.person_rounded,
          onTap: _manual,
        ),
      ];
    }

    return ZagAppBar(
      title: _season,
      scrollControllers: SonarrSeasonDetailsNavigationBar.scrollControllers,
      pageController: _pageController,
      actions: _actions,
    );
  }

  Widget? _bottomNavigationBar() {
    if (widget.seasonNumber < 0) return null;
    return SonarrSeasonDetailsNavigationBar(
      pageController: _pageController,
      seriesId: widget.seriesId,
      seasonNumber: widget.seasonNumber,
    );
  }

  Widget _body() {
    return ChangeNotifierProvider(
      create: (context) => SonarrSeasonDetailsState(
        context: context,
        seriesId: widget.seriesId,
        seasonNumber: widget.seasonNumber != -1 ? widget.seasonNumber : null,
      ),
      builder: (context, _) {
        return ZagPageView(
          controller: _pageController,
          children: [
            const SonarrSeasonDetailsEpisodesPage(),
            if (widget.seasonNumber >= 0)
              const SonarrSeasonDetailsHistoryPage(),
          ],
        );
      },
    );
  }
}
