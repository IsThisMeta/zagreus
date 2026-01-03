import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class SeerrNavigationBar extends StatelessWidget {
  final PageController? pageController;
  static List<ScrollController> scrollControllers = List.generate(
    icons.length,
    (_) => ScrollController(),
  );

  static const List<IconData> icons = [
    Icons.inbox_rounded,
    Icons.bug_report_rounded,
  ];

  static List<String> get titles => [
        'seerr.Requests'.tr(),
        'seerr.Issues'.tr(),
      ];

  const SeerrNavigationBar({
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
