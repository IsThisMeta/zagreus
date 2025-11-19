import 'package:flutter/material.dart';
import 'package:zagreus/widgets/ui.dart';

class DashboardAppBarAgentAction extends StatelessWidget {
  final VoidCallback onPressed;

  const DashboardAppBarAgentAction({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagIconButton(
      icon: Icons.smart_toy,
      iconSize: ZagUI.ICON_SIZE,
      onPressed: onPressed,
      tooltip: 'Z Agent',
    );
  }
}
