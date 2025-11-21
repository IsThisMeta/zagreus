import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class SonarrSeriesDetailsNavigationBar extends StatelessWidget {
  static const List<IconData> _baseIcons = [
    Icons.subject_rounded,
    Icons.live_tv_rounded,
    Icons.history_rounded,
  ];

  static final List<String> _baseTitles = [
    'sonarr.Overview'.tr(),
    'sonarr.Seasons'.tr(),
    'sonarr.History'.tr(),
  ];

  static List<IconData> get icons => ZagreusPro.isEnabled
    ? [..._baseIcons, Icons.people_rounded]
    : _baseIcons;

  static List<String> get titles => ZagreusPro.isEnabled
    ? [..._baseTitles, 'Cast & Crew']
    : _baseTitles;

  static List<ScrollController> get scrollControllers =>
      List.generate(icons.length, (_) => ScrollController());

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
