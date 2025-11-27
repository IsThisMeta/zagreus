import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrBookDetailsNavigationBar extends StatelessWidget {
  static const List<IconData> icons = [
    Icons.subject_rounded,
    Icons.insert_drive_file_outlined,
  ];
  static const List<String> titles = [
    'Overview',
    'Files',
  ];
  static List<ScrollController> scrollControllers =
      List.generate(icons.length, (_) => ScrollController());

  final PageController? pageController;
  final ReadarrBookData book;
  final int authorId;

  const ReadarrBookDetailsNavigationBar({
    Key? key,
    required this.pageController,
    required this.book,
    required this.authorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBottomNavigationBar(
      pageController: pageController,
      scrollControllers: ReadarrBookDetailsNavigationBar.scrollControllers,
      icons: ReadarrBookDetailsNavigationBar.icons,
      titles: ReadarrBookDetailsNavigationBar.titles,
    );
  }
}
