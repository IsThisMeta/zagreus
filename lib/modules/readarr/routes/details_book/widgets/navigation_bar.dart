import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrBookDetailsNavigationBar extends StatefulWidget {
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
  final VoidCallback onManualSearch;

  const ReadarrBookDetailsNavigationBar({
    Key? key,
    required this.pageController,
    required this.book,
    required this.authorId,
    required this.onManualSearch,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ReadarrBookDetailsNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return ZagBottomNavigationBar(
      pageController: widget.pageController,
      scrollControllers: ReadarrBookDetailsNavigationBar.scrollControllers,
      icons: ReadarrBookDetailsNavigationBar.icons,
      titles: ReadarrBookDetailsNavigationBar.titles,
      topActions: [
        ZagButton.text(
          text: 'Search',
          icon: Icons.search_rounded,
          onTap: widget.onManualSearch,
        ),
      ],
    );
  }
}
