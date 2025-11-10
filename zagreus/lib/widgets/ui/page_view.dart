import 'package:flutter/material.dart';
import 'package:zagreus/database/tables/zagreus.dart';

class FastPageScrollPhysics extends PageScrollPhysics {
  const FastPageScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  FastPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 1,
        stiffness: 700,
        damping: 60,
      );
}

class ZagPageView extends StatelessWidget {
  final PageController? controller;
  final List<Widget> children;
  final bool? allowSwipe;

  const ZagPageView({
    Key? key,
    this.controller,
    required this.children,
    this.allowSwipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (allowSwipe != null) {
      return _buildPageView(allowSwipe!);
    }

    return ZagreusDatabase.NAVIGATION_DISABLE_HORIZONTAL_SWIPE.listenableBuilder(
      builder: (context, _) {
        final prefersSwipe =
            !ZagreusDatabase.NAVIGATION_DISABLE_HORIZONTAL_SWIPE.read();
        return _buildPageView(prefersSwipe);
      },
    );
  }

  Widget _buildPageView(bool enableSwipe) {
    return PageView(
      controller: controller,
      children: children,
      physics: enableSwipe
          ? const FastPageScrollPhysics(parent: BouncingScrollPhysics())
          : const NeverScrollableScrollPhysics(),
    );
  }
}
