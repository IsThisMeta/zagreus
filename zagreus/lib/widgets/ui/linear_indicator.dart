import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ZagLinearPercentIndicator extends StatelessWidget {
  static const double _DEFAULT_LINE_HEIGHT = 12.0;
  static const double _COMPACT_LINE_HEIGHT = 4.0;
  static const double height = _DEFAULT_LINE_HEIGHT;
  static const double compactHeight =
      _COMPACT_LINE_HEIGHT + (ZagUI.DEFAULT_MARGIN_SIZE / 2);

  final double? percent;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool compact;

  const ZagLinearPercentIndicator({
    Key? key,
    this.percent,
    this.progressColor,
    this.backgroundColor,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double lineHeight =
        compact ? _COMPACT_LINE_HEIGHT : _DEFAULT_LINE_HEIGHT;
    final double totalHeight = compact ? compactHeight : height;

    return SizedBox(
      height: totalHeight,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: LinearPercentIndicator(
          percent: percent!,
          padding: EdgeInsets.zero,
          lineHeight: lineHeight,
          progressColor: progressColor,
          barRadius: const Radius.circular(ZagUI.BORDER_RADIUS),
          backgroundColor: backgroundColor ??
              (progressColor ?? ZagColours.currentAccent)
                  .withOpacity(ZagUI.OPACITY_SPLASH),
        ),
      ),
    );
  }
}
