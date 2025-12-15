import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrManualImportPathBar extends StatefulWidget
    implements PreferredSizeWidget {
  final ScrollController scrollController;

  const RadarrManualImportPathBar({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(ZagTextInputBar.defaultAppBarHeight);

  @override
  State<RadarrManualImportPathBar> createState() => _State();
}

class _State extends State<RadarrManualImportPathBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          Expanded(
            child: ZagTextInputBar(
              action: TextInputAction.done,
              labelIcon: Icons.sd_storage_rounded,
              labelText: 'radarr.FileBrowser'.tr(),
              controller: context
                  .watch<RadarrManualImportState>()
                  .currentPathTextController,
              scrollController: widget.scrollController,
              autofocus: false,
              onChanged: (value) {
                context.read<RadarrManualImportState>().currentPath = value;
                if (value.endsWith('/') || value.isEmpty) {
                  context
                      .read<RadarrManualImportState>()
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
