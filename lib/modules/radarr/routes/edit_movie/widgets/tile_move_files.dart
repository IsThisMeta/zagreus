import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrMoviesEditMoveFilesTile extends StatelessWidget {
  const RadarrMoviesEditMoveFilesTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'radarr.MoveFiles'.tr(),
      body: [
        TextSpan(
          text: 'radarr.MoveFilesDescription'.tr(),
        ),
      ],
      trailing: Checkbox(
        value: context.watch<RadarrMoviesEditState>().moveFiles,
        onChanged: (value) {
          context.read<RadarrMoviesEditState>().moveFiles = value ?? false;
        },
      ),
      onTap: () {
        final state = context.read<RadarrMoviesEditState>();
        state.moveFiles = !state.moveFiles;
      },
    );
  }
}
