import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ServerNavigationBar extends StatelessWidget {
  final PageController? pageController;

  static List<ScrollController> scrollControllers = List.generate(
    icons.length,
    (_) => ScrollController(),
  );

  static const List<IconData> icons = [
    Icons.dns_rounded,
    Icons.storage_rounded,
    Icons.widgets_rounded,
    Icons.computer_rounded,
  ];

  static const List<String> titles = [
    'System',
    'Array',
    'Docker',
    'VMs',
  ];

  const ServerNavigationBar({
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
