import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ReadarrNavigationBar extends StatelessWidget {
  final PageController? pageController;
  static List<ScrollController> scrollControllers = List.generate(
    icons.length,
    (_) => ScrollController(),
  );

  static const List<IconData> icons = [
    Icons.menu_book_rounded,
    Icons.search_off_rounded,
    Icons.history_rounded,
  ];

  static List<String> get titles => [
        'readarr.Catalogue'.tr(),
        'readarr.Missing'.tr(),
        'readarr.History'.tr(),
      ];

  const ReadarrNavigationBar({
    super.key,
    required this.pageController,
  });

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
