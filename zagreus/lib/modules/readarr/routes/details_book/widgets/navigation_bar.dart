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
  final VoidCallback onAutomaticSearch;
  final VoidCallback onManualSearch;

  const ReadarrBookDetailsNavigationBar({
    Key? key,
    required this.pageController,
    required this.book,
    required this.authorId,
    required this.onAutomaticSearch,
    required this.onManualSearch,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ReadarrBookDetailsNavigationBar> {
  ZagLoadingState _automaticLoadingState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZagBottomNavigationBar(
      pageController: widget.pageController,
      scrollControllers: ReadarrBookDetailsNavigationBar.scrollControllers,
      icons: ReadarrBookDetailsNavigationBar.icons,
      titles: ReadarrBookDetailsNavigationBar.titles,
      topActions: [
        ZagButton(
          type: ZagButtonType.TEXT,
          text: 'Automatic',
          icon: Icons.search_rounded,
          onTap: _automatic,
          loadingState: _automaticLoadingState,
        ),
        ZagButton.text(
          text: 'Interactive',
          icon: Icons.person_rounded,
          onTap: widget.onManualSearch,
        ),
      ],
    );
  }

  Future<void> _automatic() async {
    setState(() => _automaticLoadingState = ZagLoadingState.ACTIVE);
    widget.onAutomaticSearch();
    // Reset loading state after a brief delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _automaticLoadingState = ZagLoadingState.INACTIVE);
    }
  }
}
