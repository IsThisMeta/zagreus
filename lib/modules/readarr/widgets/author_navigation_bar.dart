import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ReadarrAuthorNavigationBar extends StatelessWidget {
  static List<ScrollController> scrollControllers =
      List.generate(icons.length, (_) => ScrollController());
  final PageController pageController;

  static List<String> get titles => [
        'readarr.Overview'.tr(),
        'readarr.Books'.tr(),
      ];

  static const List<IconData> icons = [
    Icons.subject_rounded,
    Icons.menu_book_rounded,
  ];

  const ReadarrAuthorNavigationBar({
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
