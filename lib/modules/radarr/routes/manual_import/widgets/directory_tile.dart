import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrManualImportDirectoryTile extends StatefulWidget {
  final RadarrFileSystemDirectory directory;

  const RadarrManualImportDirectoryTile({
    Key? key,
    required this.directory,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrManualImportDirectoryTile> {
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    RadarrFileSystemDirectory _dir = widget.directory;
    if (_dir.path?.isEmpty ?? true) return const SizedBox(height: 0.0);
    return ZagBlock(
      title: _dir.name ?? ZagUI.TEXT_EMDASH,
      body: [TextSpan(text: _dir.path)],
      trailing: ZagIconButton.arrow(loadingState: _loadingState),
      onTap: () async {
        if (_loadingState == ZagLoadingState.INACTIVE) {
          if (mounted) setState(() => _loadingState = ZagLoadingState.ACTIVE);
          context.read<RadarrManualImportState>().fetchDirectories(
                context,
                _dir.path,
              );
        }
      },
    );
  }
}
