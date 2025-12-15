import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliCheckForUpdatesTautulliTile extends StatelessWidget {
  final TautulliUpdateCheck update;

  const TautulliCheckForUpdatesTautulliTile({
    Key? key,
    required this.update,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'Tautulli',
      body: _subtitle(),
      trailing: _trailing(),
    );
  }

  Widget _trailing() {
    return Column(
      children: [
        ZagIconButton(
          icon: ZagIcons.TAUTULLI,
          color: ZagColours().byListIndex(1),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  List<TextSpan> _subtitle() {
    return [
      if (!(update.update ?? false))
        TextSpan(
          text: 'No Updates Available',
          style: TextStyle(
            color: ZagColours.currentAccent,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
      if (update.update ?? false)
        TextSpan(
          text: 'Update Available',
          style: TextStyle(
            color: ZagColours.orange,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
      if (update.update ?? false)
        TextSpan(
          children: [
            TextSpan(text: 'Current Version: '),
            TextSpan(
              text: update.currentRelease ??
                  update.currentVersion?.substring(
                    0,
                    min(7, update.currentVersion!.length),
                  ) ??
                  'zagreus.Unknown'.tr(),
            ),
          ],
        ),
      if (update.update ?? false)
        TextSpan(
          children: [
            TextSpan(text: 'Latest Version: '),
            TextSpan(
              text: update.latestRelease ??
                  update.latestVersion?.substring(
                    0,
                    min(7, update.latestVersion!.length),
                  ) ??
                  'zagreus.Unknown'.tr(),
            ),
          ],
        ),
      TextSpan(
          text: 'Install Type: ${update.installType ?? ZagUI.TEXT_EMDASH}'),
    ];
  }
}
