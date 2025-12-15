import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliCheckForUpdatesPMSTile extends StatelessWidget {
  final TautulliPMSUpdate update;

  const TautulliCheckForUpdatesPMSTile({
    Key? key,
    required this.update,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'Plex Media Server',
      body: _subtitle(),
      trailing: _trailing(),
    );
  }

  Widget _trailing() {
    return Column(
      children: [
        ZagIconButton(
          icon: ZagIcons.PLEX,
          iconSize: ZagUI.ICON_SIZE - 2.0,
          color: ZagColours().byListIndex(0),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  List<TextSpan> _subtitle() {
    return [
      if (!(update.updateAvailable ?? false))
        TextSpan(
          text: 'No Updates Available',
          style: TextStyle(
            color: ZagColours.currentAccent,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
      if (!(update.updateAvailable ?? false))
        TextSpan(
            text: 'Current Version: ${update.version ?? ZagUI.TEXT_EMDASH}'),
      if (update.updateAvailable ?? false)
        TextSpan(
          text: 'Update Available',
          style: TextStyle(
            color: ZagColours.orange,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
      if (update.updateAvailable ?? false)
        TextSpan(
            text: 'Latest Version: ${update.version ?? ZagUI.TEXT_EMDASH}'),
    ];
  }
}
