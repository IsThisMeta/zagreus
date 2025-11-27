import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

class RadarrMovieDetailsNavigationBar extends StatelessWidget {
  static const List<IconData> icons = [
    Icons.subject_rounded,
    Icons.insert_drive_file_outlined,
    Icons.history_rounded,
    Icons.person_rounded
  ];
  static const List<String> titles = [
    'Overview',
    'Files',
    'History',
    'Cast & Crew'
  ];
  static List<ScrollController> scrollControllers =
      List.generate(icons.length, (_) => ScrollController());
  final PageController? pageController;
  final RadarrMovie? movie;

  const RadarrMovieDetailsNavigationBar({
    Key? key,
    required this.pageController,
    required this.movie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBottomNavigationBar(
      pageController: pageController,
      scrollControllers: RadarrMovieDetailsNavigationBar.scrollControllers,
      icons: RadarrMovieDetailsNavigationBar.icons,
      titles: RadarrMovieDetailsNavigationBar.titles,
    );
  }
}
