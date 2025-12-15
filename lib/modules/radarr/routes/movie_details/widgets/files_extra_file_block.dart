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
        ZagTableContent(title: 'relative path', body: file.zagRelativePath),
        ZagTableContent(title: 'type', body: file.zagType),
        ZagTableContent(title: 'extension', body: file.zagExtension),
      ],
    );
  }
}
