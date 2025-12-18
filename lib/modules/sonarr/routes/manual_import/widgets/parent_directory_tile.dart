import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrManualImportParentDirectoryTile extends StatefulWidget {
  final SonarrFileSystem? fileSystem;

  const SonarrManualImportParentDirectoryTile({
    Key? key,
    required this.fileSystem,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SonarrManualImportParentDirectoryTile> {
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    if (widget.fileSystem == null ||
        widget.fileSystem!.parent == null ||
        widget.fileSystem!.parent!.isEmpty) return const SizedBox(height: 0.0);
    return ZagBlock(
      title: ZagUI.TEXT_ELLIPSIS,
      body: [TextSpan(text: 'sonarr.ParentDirectory'.tr())],
      trailing: ZagIconButton(
        icon: Icons.arrow_upward_rounded,
        loadingState: _loadingState,
      ),
      onTap: () async {
        if (_loadingState == ZagLoadingState.INACTIVE) {
          if (mounted) setState(() => _loadingState = ZagLoadingState.ACTIVE);
          context.read<SonarrManualImportState>().fetchDirectories(
                context,
                widget.fileSystem!.parent,
              );
        }
      },
    );
  }
}
