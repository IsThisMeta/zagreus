import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrMovieDetailsFilesExtraFileBlock extends StatelessWidget {
  final RadarrExtraFile file;

  const RadarrMovieDetailsFilesExtraFileBlock({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      content: [
        ZagTableContent(
          title: 'radarr.RelativePath'.tr(),
          body: file.zagRelativePath,
        ),
        ZagTableContent(title: 'radarr.Type'.tr(), body: file.zagType),
        ZagTableContent(
          title: 'radarr.Extension'.tr(),
          body: file.zagExtension,
        ),
      ],
    );
  }
}
