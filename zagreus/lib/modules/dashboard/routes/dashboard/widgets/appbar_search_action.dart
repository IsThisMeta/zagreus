import 'package:flutter/material.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/modules.dart';

class DashboardAppBarSearchAction extends StatelessWidget {
  const DashboardAppBarSearchAction({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagIconButton(
      icon: Icons.search_rounded,
      iconSize: ZagUI.ICON_SIZE,
      onPressed: ZagModule.SEARCH.launch,
      tooltip: 'Search',
    );
  }
}
