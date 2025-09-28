import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/scroll_controller.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrSeriesSearchBarSortButton extends StatefulWidget {
  final ScrollController controller;

  const SonarrSeriesSearchBarSortButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<SonarrSeriesSearchBarSortButton> createState() => _State();
}

class _State extends State<SonarrSeriesSearchBarSortButton> {
  @override
  Widget build(BuildContext context) => ZagCard(
        context: context,
        child: Consumer<SonarrState>(
          builder: (context, state, _) =>
              ZagPopupMenuButton<SonarrSeriesSorting>(
            tooltip: 'sonarr.SortCatalogue'.tr(),
            icon: Icons.sort_rounded,
            onSelected: (result) {
              if (state.seriesSortType == result) {
                state.seriesSortAscending = !state.seriesSortAscending;
              } else {
                state.seriesSortAscending = true;
                state.seriesSortType = result;
              }
              widget.controller.animateToStart();
            },
            itemBuilder: (context) =>
                List<PopupMenuEntry<SonarrSeriesSorting>>.generate(
              SonarrSeriesSorting.values.length,
              (index) => PopupMenuItem<SonarrSeriesSorting>(
                value: SonarrSeriesSorting.values[index],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      SonarrSeriesSorting.values[index].readable,
                      style: TextStyle(
                        fontSize: ZagUI.FONT_SIZE_H3,
                        color: state.seriesSortType ==
                                SonarrSeriesSorting.values[index]
                            ? ZagColours.accent
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (state.seriesSortType ==
                        SonarrSeriesSorting.values[index])
                      Icon(
                        state.seriesSortAscending
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
        margin: const EdgeInsets.only(left: ZagUI.DEFAULT_MARGIN_SIZE),
        color: Theme.of(context).canvasColor,
      );
}
