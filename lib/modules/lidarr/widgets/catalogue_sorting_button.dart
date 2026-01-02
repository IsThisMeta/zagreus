import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/scroll_controller.dart';
import 'package:zagreus/modules/lidarr.dart';

class LidarrCatalogueSortButton extends StatefulWidget {
  final ScrollController controller;

  const LidarrCatalogueSortButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<LidarrCatalogueSortButton> createState() => _State();
}

class _State extends State<LidarrCatalogueSortButton> {
  @override
  Widget build(BuildContext context) => ZagCard(
        context: context,
        height: ZagTextInputBar.defaultHeight,
        width: ZagTextInputBar.defaultHeight,
        child: Consumer<LidarrState>(
          builder: (context, model, _) =>
              ZagPopupMenuButton<LidarrCatalogueSorting>(
            tooltip: 'lidarr.SortCatalogue'.tr(),
            icon: Icons.sort_rounded,
            onSelected: (result) {
              if (model.sortCatalogueType == result) {
                model.sortCatalogueAscending = !model.sortCatalogueAscending;
              } else {
                model.sortCatalogueAscending = true;
                model.sortCatalogueType = result;
              }
              widget.controller.animateToStart();
            },
            itemBuilder: (context) =>
                List<PopupMenuEntry<LidarrCatalogueSorting>>.generate(
              LidarrCatalogueSorting.values.length,
              (index) => PopupMenuItem<LidarrCatalogueSorting>(
                value: LidarrCatalogueSorting.values[index],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LidarrCatalogueSorting.values[index].readable,
                      style: const TextStyle(
                        fontSize: ZagUI.FONT_SIZE_H3,
                      ),
                    ),
                    if (model.sortCatalogueType ==
                        LidarrCatalogueSorting.values[index])
                      Icon(
                        model.sortCatalogueAscending
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
        margin: EdgeInsets.zero,
        color: Theme.of(context).canvasColor,
      );
}
