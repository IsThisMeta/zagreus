import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrSeriesEditMoveFilesTile extends StatelessWidget {
  const SonarrSeriesEditMoveFilesTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'sonarr.MoveFiles'.tr(),
      body: [
        TextSpan(
          text: 'sonarr.MoveFilesDescription'.tr(),
        ),
      ],
      trailing: Checkbox(
        value: context.watch<SonarrSeriesEditState>().moveFiles,
        onChanged: (value) {
          context.read<SonarrSeriesEditState>().moveFiles = value ?? false;
        },
      ),
      onTap: () {
        final state = context.read<SonarrSeriesEditState>();
        state.moveFiles = !state.moveFiles;
      },
    );
  }
}
