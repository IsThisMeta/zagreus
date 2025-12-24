import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:zagreus/extensions/page_controller.dart';
import 'package:zagreus/extensions/scroll_controller.dart';

class ZagBottomNavigationBar extends StatefulWidget {
  final PageController? pageController;
  final List<IconData> icons;
  final List<String> titles;
  final List<ScrollController>? scrollControllers;
  final List<Widget>? topActions;
  final ValueChanged<int>? onTabChange;
  final List<Widget?>? leadingOnTab;

  ZagBottomNavigationBar({
    Key? key,
    required this.pageController,
    required this.icons,
    required this.titles,
    this.topActions,
    this.onTabChange,
    this.leadingOnTab,
    this.scrollControllers,
  }) : super(key: key) {
    assert(
      icons.length == titles.length,
      'An unequal amount of titles and icons were passed to ZagNavigationBar.',
    );
    if (leadingOnTab != null) {
      assert(
        icons.length == leadingOnTab!.length,
        'An unequal amount of icons and leadingOnTab were passed to ZagNavigationBar.',
      );
    }
    if (scrollControllers != null) {
      assert(
        icons.length == scrollControllers!.length,
        'An unequal amount of icons and scrollControllers were passed to ZagNavigationBar.',
      );
    }
  }

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ZagBottomNavigationBar> {
  late int _index;

  @override
  void initState() {
    _index = widget.pageController?.initialPage ?? 0;
    widget.pageController?.addListener(_pageControllerListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.pageController?.removeListener(_pageControllerListener);
    super.dispose();
  }

  void _pageControllerListener() {
    if ((widget.pageController!.page?.round() ?? _index) == _index) return;
    setState(() => _index = widget.pageController!.page!.round());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.topActions?.isNotEmpty ?? false) _actionBar,
        _navigationBar,
      ],
    );
  }

  Widget get _actionBar {
    return ZagBottomActionBar(
      actions: widget.topActions,
      useSafeArea: false,
      padding: ZagUI.MARGIN_HALF,
      compactLandscape: true,
      landscapeScale: 0.75,
    );
  }

  Widget get _navigationBar {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final navPadding = isLandscape
        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0)
        : (widget.topActions?.isNotEmpty ?? false)
            ? ZagUI.MARGIN_DEFAULT.copyWith(top: 0.0)
            : ZagUI.MARGIN_DEFAULT;
    final buttonPadding = isLandscape
        ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0)
        : const EdgeInsets.all(10.0);
    final iconSize =
        isLandscape ? ZagUI.ICON_SIZE * 0.85 : ZagUI.ICON_SIZE;
    final fontSize =
        isLandscape ? ZagUI.FONT_SIZE_H4 : ZagUI.FONT_SIZE_H3;
    return Container(
      child: SafeArea(
        child: Padding(
          child: GNav(
            gap: ZagUI.MARGIN_SIZE_HALF,
            duration: const Duration(milliseconds: ZagUI.ANIMATION_SPEED),
            tabBackgroundColor: Theme.of(context).canvasColor.dimmed(),
            activeColor: ZagColours.currentAccent,
            tabs: List.generate(
                widget.icons.length,
                (index) => GButton(
                      icon: widget.icons[index],
                      text: widget.titles[index],
                      active: _index == index,
                      iconSize: iconSize,
                      haptic: true,
                      padding: buttonPadding.add(EdgeInsets.only(
                        left: _index == index ? ZagUI.MARGIN_SIZE_HALF : 0.0,
                      )),
                      iconColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                      textStyle: TextStyle(
                        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
                        fontSize: fontSize,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                      iconActiveColor: ZagColours.currentAccent,
                      leading: widget.leadingOnTab == null
                          ? null
                          : widget.leadingOnTab![index],
                    )).toList(),
            tabActiveBorder: ZagUI.shouldUseBorder
                ? Border.all(color: ZagColours.white10)
                : null,
            tabBorder: ZagUI.shouldUseBorder
                ? Border.all(color: Colors.transparent)
                : null,
            selectedIndex: _index,
            onTabChange: _onDestinationSelected,
          ),
          padding: navPadding,
        ),
        top: false,
      ),
      color: Theme.of(context).primaryColor,
    );
  }

  void _onDestinationSelected(int idx) {
    HapticFeedback.mediumImpact();
    if (idx == _index && widget.scrollControllers != null) {
      widget.scrollControllers![idx].animateToStart();
    } else if (widget.pageController != null) {
      widget.pageController!.protectedJumpToPage(idx);
    }
    if (widget.onTabChange != null) widget.onTabChange!(idx);
    setState(() => _index = idx);
  }
}
