import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagReorderableListViewBuilder extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics physics;
  final ScrollController controller;
  final void Function(int, int) onReorder;
  final bool buildDefaultDragHandles;

  const ZagReorderableListViewBuilder({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    required this.controller,
    required this.onReorder,
    this.padding,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.buildDefaultDragHandles = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      interactive: true,
      child: ReorderableListView.builder(
        scrollController: controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: padding as EdgeInsets? ??
            MediaQuery.of(context).padding.add(EdgeInsets.symmetric(
                  vertical: ZagUI.MARGIN_H_DEFAULT_V_HALF.bottom,
                )) as EdgeInsets?,
        physics: physics,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        onReorder: onReorder,
        buildDefaultDragHandles: buildDefaultDragHandles,
      ),
    );
  }
}
