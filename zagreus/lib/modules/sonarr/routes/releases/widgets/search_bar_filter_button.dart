import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/scroll_controller.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrReleasesAppBarFilterButton extends StatefulWidget {
  final ScrollController controller;

  const SonarrReleasesAppBarFilterButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<SonarrReleasesAppBarFilterButton> createState() => _State();
}

class _State extends State<SonarrReleasesAppBarFilterButton> {
  @override
  Widget build(BuildContext context) {
    return ZagCard(
      context: context,
      child: Consumer<SonarrReleasesState>(
        builder: (context, state, _) =>
            ZagPopupMenuButton<SonarrReleasesFilter>(
          tooltip: 'sonarr.FilterReleases'.tr(),
          icon: Icons.filter_list_rounded,
          onSelected: (result) {
            state.filterType = result;
            widget.controller.animateToStart();
          },
          itemBuilder: (context) =>
              List<PopupMenuEntry<SonarrReleasesFilter>>.generate(
            SonarrReleasesFilter.values.length,
            (index) => PopupMenuItem<SonarrReleasesFilter>(
              value: SonarrReleasesFilter.values[index],
              child: Text(
                SonarrReleasesFilter.values[index].readable,
                style: TextStyle(
                  fontSize: ZagUI.FONT_SIZE_H3,
                  color: state.filterType == SonarrReleasesFilter.values[index]
                      ? ZagColours.accent
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ),
      ),
      height: ZagTextInputBar.defaultHeight,
      width: ZagTextInputBar.defaultHeight,
      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 14.0),
      color: Theme.of(context).canvasColor,
    );
  }
}
