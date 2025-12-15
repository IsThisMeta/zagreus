import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrDiskSpaceTile extends StatelessWidget {
  final RadarrDiskSpace diskSpace;

  const RadarrDiskSpaceTile({
    Key? key,
    required this.diskSpace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: diskSpace.zagPath,
      body: [TextSpan(text: diskSpace.zagSpace)],
      bottom: ZagLinearPercentIndicator(
        percent: diskSpace.zagPercentage / 100,
        progressColor: diskSpace.zagColor,
      ),
      bottomHeight: ZagLinearPercentIndicator.height,
      trailing: ZagIconButton(
        text: diskSpace.zagPercentageString,
        textSize: ZagUI.FONT_SIZE_H4,
        color: diskSpace.zagColor,
      ),
    );
  }
}
