import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/scroll_controller.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrReleasesAppBarSortButton extends StatefulWidget {
  final ScrollController controller;

  const SonarrReleasesAppBarSortButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<SonarrReleasesAppBarSortButton> createState() => _State();
}

class _State extends State<SonarrReleasesAppBarSortButton> {
  @override
  Widget build(BuildContext context) {
    return ZagCard(
      context: context,
      child: Consumer<SonarrReleasesState>(
        builder: (context, state, _) =>
            ZagPopupMenuButton<SonarrReleasesSorting>(
          tooltip: 'sonarr.SortReleases'.tr(),
          icon: Icons.sort_rounded,
          onSelected: (result) {
            if (state.sortType == result) {
              state.sortAscending = !state.sortAscending;
            } else {
              state.sortAscending = true;
              state.sortType = result;
            }
            widget.controller.animateToStart();
          },
          itemBuilder: (context) =>
              List<PopupMenuEntry<SonarrReleasesSorting>>.generate(
            SonarrReleasesSorting.values.length,
            (index) => PopupMenuItem<SonarrReleasesSorting>(
              value: SonarrReleasesSorting.values[index],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    SonarrReleasesSorting.values[index].readable,
                    style: TextStyle(
                      fontSize: ZagUI.FONT_SIZE_H3,
                      color:
                          state.sortType == SonarrReleasesSorting.values[index]
                              ? ZagColours.accent
                              : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (state.sortType == SonarrReleasesSorting.values[index])
                    Icon(
                      state.sortAscending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: ZagUI.FONT_SIZE_H2,
                      color: ZagColours.accent,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      height: ZagTextInputBar.defaultHeight,
      width: ZagTextInputBar.defaultHeight,
      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 13.5),
      color: Theme.of(context).canvasColor,
    );
  }
}
