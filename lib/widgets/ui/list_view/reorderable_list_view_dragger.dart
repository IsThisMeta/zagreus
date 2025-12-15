import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagReorderableListViewDragger extends StatelessWidget {
  final int index;

  const ZagReorderableListViewDragger({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ReorderableDragStartListener(
          index: index,
          child: const ZagIconButton(
            icon: Icons.menu_rounded,
            mouseCursor: SystemMouseCursors.click,
          ),
        ),
      ],
    );
  }
}
