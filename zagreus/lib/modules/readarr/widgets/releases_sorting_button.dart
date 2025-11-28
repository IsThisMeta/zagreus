import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/scroll_controller.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrReleasesSortButton extends StatefulWidget {
  final ScrollController controller;

  const ReadarrReleasesSortButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<ReadarrReleasesSortButton> createState() => _State();
}

class _State extends State<ReadarrReleasesSortButton> {
  @override
  Widget build(BuildContext context) => ZagCard(
        context: context,
        height: ZagTextInputBar.defaultHeight,
        width: ZagTextInputBar.defaultHeight,
        child: Consumer<ReadarrState>(
          builder: (context, model, _) =>
              ZagPopupMenuButton<ReadarrReleasesSorting>(
            tooltip: 'Sort Releases',
            icon: Icons.sort_rounded,
            onSelected: (result) {
              if (model.sortReleasesType == result) {
                model.sortReleasesAscending = !model.sortReleasesAscending;
              } else {
                model.sortReleasesAscending = true;
                model.sortReleasesType = result;
              }
              widget.controller.animateToStart();
            },
            itemBuilder: (context) =>
                List<PopupMenuEntry<ReadarrReleasesSorting>>.generate(
              ReadarrReleasesSorting.values.length,
              (index) => PopupMenuItem<ReadarrReleasesSorting>(
                value: ReadarrReleasesSorting.values[index],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ReadarrReleasesSorting.values[index].readable,
                      style: const TextStyle(
                        fontSize: ZagUI.FONT_SIZE_H3,
                      ),
                    ),
                    if (model.sortReleasesType ==
                        ReadarrReleasesSorting.values[index])
                      Icon(
                        model.sortReleasesAscending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: ZagUI.FONT_SIZE_H2,
                        color: ZagColours.currentAccent,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        margin: ZagTextInputBar.appBarMargin
            .subtract(const EdgeInsets.only(left: 12.0)) as EdgeInsets,
        color: Theme.of(context).canvasColor,
      );
}
