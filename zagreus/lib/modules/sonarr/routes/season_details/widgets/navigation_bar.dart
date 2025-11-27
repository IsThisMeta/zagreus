import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

class SonarrSeasonDetailsNavigationBar extends StatelessWidget {
  static const List<IconData> icons = [
    Icons.live_tv_rounded,
    Icons.history_rounded,
  ];

  static final List<String> titles = [
    'sonarr.Episodes'.tr(),
    'sonarr.History'.tr(),
  ];

  static List<ScrollController> scrollControllers =
      List.generate(icons.length, (_) => ScrollController());
  final PageController? pageController;
  final int seriesId;
  final int seasonNumber;

  const SonarrSeasonDetailsNavigationBar({
    Key? key,
    required this.pageController,
    required this.seriesId,
    required this.seasonNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBottomNavigationBar(
      pageController: pageController,
      scrollControllers: SonarrSeasonDetailsNavigationBar.scrollControllers,
      icons: SonarrSeasonDetailsNavigationBar.icons,
      titles: SonarrSeasonDetailsNavigationBar.titles,
    );
  }
}
