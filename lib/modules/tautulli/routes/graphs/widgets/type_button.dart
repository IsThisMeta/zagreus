import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliGraphsTypeButton extends StatelessWidget {
  const TautulliGraphsTypeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Selector<TautulliState, TautulliGraphYAxis>(
        selector: (_, state) => state.graphYAxis,
        builder: (context, type, _) => ZagPopupMenuButton<TautulliGraphYAxis>(
            tooltip: 'Graph Type',
            icon: Icons.merge_type_rounded,
            onSelected: (value) {
              context.read<TautulliState>().graphYAxis = value;
              context.read<TautulliState>().resetAllPlayPeriodGraphs();
              context.read<TautulliState>().resetAllStreamInformationGraphs();
            },
            itemBuilder: (context) =>
                List<PopupMenuEntry<TautulliGraphYAxis>>.generate(
                  TautulliStatsType.values.length,
                  (index) => PopupMenuItem<TautulliGraphYAxis>(
                    value: TautulliGraphYAxis.values[index],
                    child: Text(
                      TautulliStatsType.values[index].value!.toTitleCase(),
                      style: TextStyle(
                        fontSize: ZagUI.FONT_SIZE_H3,
                        color: type == TautulliGraphYAxis.values[index]
                            ? ZagColours.accent
                            : Colors.white,
                      ),
                    ),
                  ),
                )),
      );
}
