import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrManualImportPathBar extends StatefulWidget
    implements PreferredSizeWidget {
  final ScrollController scrollController;

  const SonarrManualImportPathBar({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(ZagTextInputBar.defaultAppBarHeight);

  @override
  State<SonarrManualImportPathBar> createState() => _State();
}

class _State extends State<SonarrManualImportPathBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          Expanded(
            child: ZagTextInputBar(
              action: TextInputAction.done,
              labelIcon: Icons.sd_storage_rounded,
              labelText: 'sonarr.FileBrowser'.tr(),
              controller: context
                  .watch<SonarrManualImportState>()
                  .currentPathTextController,
              scrollController: widget.scrollController,
              autofocus: false,
              onChanged: (value) {
                context.read<SonarrManualImportState>().currentPath = value;
                if (value.endsWith('/') || value.isEmpty) {
                  context
                      .read<SonarrManualImportState>()
                      .fetchDirectories(context, value);
                }
              },
              margin: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      height: ZagTextInputBar.defaultAppBarHeight,
    );
  }
}
