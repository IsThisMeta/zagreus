import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/duration/timestamp.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliBarGraphHelper {
  static const int BAR_COUNT = 7;
  static const double BAR_WIDTH = 30.0;

  TautulliBarGraphHelper._();

  static List<BarChartGroupData> barGroups(
          BuildContext context, TautulliGraphData data) =>
      List<BarChartGroupData>.generate(
        data.categories!.take(BAR_COUNT).length,
        (cIndex) => BarChartGroupData(
          x: cIndex,
          barRods: [
            BarChartRodData(
              toY: data.series!.fold<double>(
                  0, (value, data) => value + data.data![cIndex]!),
              width: BAR_WIDTH,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(ZagUI.BORDER_RADIUS / 3),
                topRight: Radius.circular(ZagUI.BORDER_RADIUS / 3),
              ),
              rodStackItems: List<BarChartRodStackItem>.generate(
                data.series!.length,
                (sIndex) => BarChartRodStackItem(
                  _fromY(cIndex, sIndex, data.series!),
                  _toY(cIndex, sIndex, data.series!),
                  ZagColours().byGraphLayer(sIndex),
                ),
              ),
            ),
          ],
        ),
      );

  static BarTouchData barTouchData(
          BuildContext context, TautulliGraphData data) =>
      BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) =>
              ZagTheme.isAMOLEDTheme ? Colors.black : ZagColours.primary,
          tooltipRoundedRadius: ZagUI.BORDER_RADIUS,
          tooltipPadding: const EdgeInsets.all(8.0),
          maxContentWidth: MediaQuery.of(context).size.width / 1.25,
          fitInsideVertically: true,
          fitInsideHorizontally: true,
          getTooltipItem: (group, gIndex, rod, rIndex) {
            String _header = '${data.categories![gIndex]}\n\n';
            String _body = '';
            for (int i = 0; i < rod.rodStackItems.length; i++) {
              double _number =
                  rod.rodStackItems[i].toY - rod.rodStackItems[i].fromY;
              String _value = data.series![i].name ?? 'Unknown';
              String _text = context.read<TautulliState>().graphYAxis ==
                      TautulliGraphYAxis.PLAYS
                  ? _number.truncate().toString()
                  : Duration(seconds: _number.truncate()).asWordsTimestamp();
              _body += '$_value: $_text\n';
            }
            return BarTooltipItem(
              (_header + _body).trim(),
              const TextStyle(
                color: ZagColours.grey,
                fontSize: ZagUI.FONT_SIZE_SUBHEADER,
              ),
            );
          },
        ),
      );

  static double _fromY(
    int cIndex,
    int sIndex,
    List<TautulliSeriesData> series,
  ) =>
      series
          .take(sIndex)
          .fold<double>(0, (value, data) => value + data.data![cIndex]!);

  static double _toY(
    int cIndex,
    int sIndex,
    List<TautulliSeriesData> series,
  ) =>
      series
          .take(sIndex + 1)
          .fold<double>(0, (value, data) => value + data.data![cIndex]!);
}
