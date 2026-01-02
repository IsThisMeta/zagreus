import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class SonarrSeriesDetailsNavigationBar extends StatelessWidget {
  static List<ScrollController> scrollControllers =
      List.generate(icons.length, (_) => ScrollController());

  static const List<IconData> icons = [
    Icons.subject_rounded,
    Icons.live_tv_rounded,
    Icons.history_rounded,
    Icons.people_rounded,
  ];

  static List<String> get titles => [
        'sonarr.Overview'.tr(),
        'sonarr.Seasons'.tr(),
        'sonarr.History'.tr(),
        'sonarr.CastAndCrew'.tr(),
      ];

  final PageController? pageController;

  const SonarrSeriesDetailsNavigationBar({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBottomNavigationBar(
      pageController: pageController,
      scrollControllers: scrollControllers,
      icons: icons,
      titles: titles,
    );
  }
}
