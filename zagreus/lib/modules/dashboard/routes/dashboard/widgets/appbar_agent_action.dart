import 'package:flutter/material.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/router/routes/settings.dart';

class DashboardAppBarAgentAction extends StatelessWidget {
  const DashboardAppBarAgentAction({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagIconButton(
      icon: Icons.psychology_rounded,
      iconSize: ZagUI.ICON_SIZE,
      onPressed: SettingsRoutes.Z_AGENT.go,
      tooltip: 'Z Agent',
    );
  }
}
