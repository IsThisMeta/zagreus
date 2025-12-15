import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class HomeNavigationBar extends StatelessWidget {
  final PageController? pageController;

  static List<ScrollController> scrollControllers = List.generate(
    2, // Max possible tabs
    (_) => ScrollController(),
  );

  static final List<String> _allTitles = [
    'dashboard.Modules'.tr(),
    'dashboard.Calendar'.tr(),
  ];

  static const List<IconData> _allIcons = [
    Icons.workspaces_rounded,
    Icons.calendar_today_rounded,
  ];

  const HomeNavigationBar({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  static List<String> getVisibleTitles() {
    final List<String> visibleTitles = [];
    if (ZagreusDatabase.DASHBOARD_SHOW_MODULES_TAB.read()) {
      visibleTitles.add(_allTitles[0]);
    }
    if (ZagreusDatabase.SHOW_CALENDAR_TAB.read()) {
      visibleTitles.add(_allTitles[1]);
    }
    return visibleTitles;
  }

  static List<IconData> getVisibleIcons() {
    final List<IconData> visibleIcons = [];
    if (ZagreusDatabase.DASHBOARD_SHOW_MODULES_TAB.read()) {
      visibleIcons.add(_allIcons[0]);
    }
    if (ZagreusDatabase.SHOW_CALENDAR_TAB.read()) {
      visibleIcons.add(_allIcons[1]);
    }
    return visibleIcons;
  }

  static List<ScrollController> getVisibleScrollControllers() {
    final List<ScrollController> visibleControllers = [];
    if (ZagreusDatabase.DASHBOARD_SHOW_MODULES_TAB.read()) {
      visibleControllers.add(scrollControllers[0]);
    }
    if (ZagreusDatabase.SHOW_CALENDAR_TAB.read()) {
      visibleControllers.add(scrollControllers[1]);
    }
    return visibleControllers;
  }

  @override
  Widget build(BuildContext context) {
    return ZagreusDatabase.DASHBOARD_SHOW_MODULES_TAB.listenableBuilder(
      builder: (context, _) => ZagreusDatabase.SHOW_CALENDAR_TAB.listenableBuilder(
        builder: (context, _) {
          final visibleTitles = getVisibleTitles();
          final visibleIcons = getVisibleIcons();
          final visibleScrollControllers = getVisibleScrollControllers();

          if (visibleTitles.isEmpty) {
            return const SizedBox.shrink();
          }

          return ZagBottomNavigationBar(
            pageController: pageController,
            scrollControllers: visibleScrollControllers,
            icons: visibleIcons,
            titles: visibleTitles,
          );
        },
      ),
    );
  }
}
