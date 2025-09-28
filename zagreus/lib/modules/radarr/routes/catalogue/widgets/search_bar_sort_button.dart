import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/scroll_controller.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrCatalogueSearchBarSortButton extends StatefulWidget {
  final ScrollController controller;

  const RadarrCatalogueSearchBarSortButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<RadarrCatalogueSearchBarSortButton> createState() => _State();
}

class _State extends State<RadarrCatalogueSearchBarSortButton> {
  @override
  Widget build(BuildContext context) {
    return ZagCard(
      context: context,
      child: Consumer<RadarrState>(
        builder: (context, state, _) =>
            ZagPopupMenuButton<RadarrMoviesSorting>(
          tooltip: 'radarr.SortCatalogue'.tr(),
          icon: ZagIcons.SORT,
          onSelected: (result) {
            if (state.moviesSortType == result) {
              state.moviesSortAscending = !state.moviesSortAscending;
            } else {
              state.moviesSortAscending = true;
              state.moviesSortType = result;
            }
            widget.controller.animateToStart();
          },
          itemBuilder: (context) =>
              List<PopupMenuEntry<RadarrMoviesSorting>>.generate(
            RadarrMoviesSorting.values.length,
            (index) => PopupMenuItem<RadarrMoviesSorting>(
              value: RadarrMoviesSorting.values[index],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    RadarrMoviesSorting.values[index].readable,
                    style: TextStyle(
                      fontSize: ZagUI.FONT_SIZE_H3,
                      color: state.moviesSortType ==
                              RadarrMoviesSorting.values[index]
                          ? ZagColours.accent
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (state.moviesSortType == RadarrMoviesSorting.values[index])
                    Icon(
                      state.moviesSortAscending
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
      margin: const EdgeInsets.only(left: ZagUI.DEFAULT_MARGIN_SIZE),
      color: Theme.of(context).canvasColor,
      height: ZagTextInputBar.defaultHeight,
      width: ZagTextInputBar.defaultHeight,
    );
  }
}
