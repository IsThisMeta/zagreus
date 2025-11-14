import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class HomeNavigationBar extends StatelessWidget {
  final PageController? pageController;

  static List<ScrollController> scrollControllers = List.generate(
    icons.length,
    (_) => ScrollController(),
  );

  static final List<String> titles = [
    'dashboard.Modules'.tr(),
    'dashboard.Calendar'.tr(),
  ];

  static const List<IconData> icons = [
    Icons.workspaces_rounded,
    Icons.calendar_today_rounded,
  ];

  const HomeNavigationBar({
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

class ProHomeNavigationBar extends StatelessWidget {
  final PageController? pageController;

  static List<ScrollController> scrollControllers = List.generate(
    icons.length,
    (_) => ScrollController(),
  );

  static const List<String> titles = [
    'Movies',
    'Shows',
    'Calendar',
    'Agent',
  ];

  static const List<IconData> icons = [
    Icons.movie_rounded,
    Icons.tv_rounded,
    Icons.calendar_today_rounded,
    Icons.smart_toy,
  ];

  const ProHomeNavigationBar({
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
