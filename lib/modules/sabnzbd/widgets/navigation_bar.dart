import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class SABnzbdNavigationBar extends StatelessWidget {
  static List<ScrollController> scrollControllers =
      List.generate(icons.length, (_) => ScrollController());
  final PageController? pageController;

  static const List<IconData> icons = [
    Icons.queue_play_next_rounded,
    Icons.history_rounded,
  ];

  static const List<String> titles = [
    'Queue',
    'History',
  ];

  const SABnzbdNavigationBar({
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
