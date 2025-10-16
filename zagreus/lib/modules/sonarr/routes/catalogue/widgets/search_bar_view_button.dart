import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/scroll_controller.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/types/list_view_option.dart';

class SonarrSeriesSearchBarViewButton extends StatefulWidget {
  final ScrollController controller;

  const SonarrSeriesSearchBarViewButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<SonarrSeriesSearchBarViewButton> createState() => _State();
}

class _State extends State<SonarrSeriesSearchBarViewButton> {
  @override
  Widget build(BuildContext context) {
    return ZagCard(
      context: context,
      child: Consumer<SonarrState>(
        builder: (context, state, _) => ZagPopupMenuButton<ZagListViewOption>(
          tooltip: 'zagreus.View'.tr(),
          icon: ZagIcons.VIEW,
          onSelected: (result) {
            state.seriesViewType = result;
            widget.controller.animateToStart();
          },
          itemBuilder: (context) =>
              List<PopupMenuEntry<ZagListViewOption>>.generate(
            ZagListViewOption.values.length,
            (index) => PopupMenuItem<ZagListViewOption>(
              value: ZagListViewOption.values[index],
              child: Text(
                ZagListViewOption.values[index].readable,
                style: TextStyle(
                  fontSize: ZagUI.FONT_SIZE_H3,
                  color:
                      state.seriesViewType == ZagListViewOption.values[index]
                          ? ZagColours.accent
                          : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ),
      ),
      margin: const EdgeInsets.only(left: ZagUI.DEFAULT_MARGIN_SIZE),
      color: Theme.of(context).cardColor,
      height: ZagTextInputBar.defaultHeight,
      width: ZagTextInputBar.defaultHeight,
    );
  }
}
