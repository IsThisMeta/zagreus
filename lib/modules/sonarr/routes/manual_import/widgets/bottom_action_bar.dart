import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

class SonarrManualImportBottomActionBar extends StatelessWidget {
  const SonarrManualImportBottomActionBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBottomActionBar(
      actions: [
        // Quick import not implemented for Sonarr yet
        // ZagButton.text(
        //   text: 'sonarr.Quick'.tr(),
        //   icon: Icons.search_rounded,
        //   onTap: () async => SonarrAPIController().quickImport(
        //     context: context,
        //     path: context.read<SonarrManualImportState>().currentPath,
        //   ),
        // ),
        ZagButton.text(
          text: 'sonarr.Interactive'.tr(),
          icon: Icons.person_rounded,
          onTap: () => SonarrRoutes.MANUAL_IMPORT_DETAILS.go(queryParams: {
            'path': context.read<SonarrManualImportState>().currentPath,
          }),
        ),
      ],
    );
  }
}
