import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/scroll_controller.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrCatalogueSearchBarFilterButton extends StatefulWidget {
  final ScrollController controller;

  const RadarrCatalogueSearchBarFilterButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<RadarrCatalogueSearchBarFilterButton> createState() => _State();
}

class _State extends State<RadarrCatalogueSearchBarFilterButton> {
  @override
  Widget build(BuildContext context) {
    return ZagCard(
      context: context,
      child: Consumer<RadarrState>(
        builder: (context, state, _) => ZagPopupMenuButton<RadarrMoviesFilter>(
          tooltip: 'radarr.FilterCatalogue'.tr(),
          icon: ZagIcons.FILTER,
          onSelected: (result) {
            state.moviesFilterType = result;
            widget.controller.animateToStart();
          },
          itemBuilder: (context) =>
              List<PopupMenuEntry<RadarrMoviesFilter>>.generate(
            RadarrMoviesFilter.values.length,
            (index) => PopupMenuItem<RadarrMoviesFilter>(
              value: RadarrMoviesFilter.values[index],
              child: Text(
                RadarrMoviesFilter.values[index].readable,
                style: TextStyle(
                  fontSize: ZagUI.FONT_SIZE_H3,
                  color:
                      state.moviesFilterType == RadarrMoviesFilter.values[index]
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
      margin: const EdgeInsets.only(left: ZagUI.DEFAULT_MARGIN_SIZE),
      color: Theme.of(context).cardColor,
    );
  }
}
