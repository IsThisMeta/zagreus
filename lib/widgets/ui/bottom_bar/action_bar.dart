import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

/// Create a [ZagBottomActionBar] that contains button actions.
///
/// The children are expected to be [ZagButton]s or children of [ZagButton].
class ZagBottomActionBar extends StatelessWidget {
  final EdgeInsets padding;
  final List<Widget>? actions;
  final int actionsPerRow;
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool compactLandscape;
  final double landscapeScale;

  ZagBottomActionBar({
    required this.actions,
    this.padding = const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
    this.actionsPerRow = 2,
    this.useSafeArea = true,
    this.backgroundColor,
    this.compactLandscape = true,
    this.landscapeScale = 0.5,
    Key? key,
  }) : super(key: key) {
    assert(actions?.isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final shouldCompact = isLandscape && compactLandscape;
    final clampedScale = landscapeScale.clamp(0.4, 1.0);
    final effectivePadding = shouldCompact
        ? EdgeInsets.fromLTRB(
            padding.left,
            padding.top * clampedScale,
            padding.right,
            padding.bottom * clampedScale,
          )
        : padding;
    final effectiveButtonHeight =
        shouldCompact ? ZagButton.DEFAULT_HEIGHT * clampedScale : null;

    return Container(
      child: SafeArea(
        top: useSafeArea,
        bottom: useSafeArea,
        left: useSafeArea,
        right: useSafeArea,
        child: Padding(
          child: ZagButtonContainer(
            children: actions!,
            padding: EdgeInsets.zero,
            buttonsPerRow: actionsPerRow,
            buttonHeight: effectiveButtonHeight,
          ),
          padding: effectivePadding,
        ),
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).primaryColor,
      ),
    );
  }
}
