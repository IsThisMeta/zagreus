import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ZagLinearPercentIndicator extends StatelessWidget {
  static const _LINE_HEIGHT = 8.0;
  static const double height = _LINE_HEIGHT + ZagUI.DEFAULT_MARGIN_SIZE / 2;

  final double? percent;
  final Color? progressColor;
  final Color? backgroundColor;

  const ZagLinearPercentIndicator({
    Key? key,
    this.percent,
    this.progressColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.bottomCenter,
      child: LinearPercentIndicator(
        percent: percent!,
        padding: EdgeInsets.zero,
        lineHeight: 8.0,
        progressColor: progressColor,
        barRadius: const Radius.circular(ZagUI.BORDER_RADIUS),
        backgroundColor:
            backgroundColor ?? (progressColor ?? ZagColours.currentAccent).withOpacity(ZagUI.OPACITY_SPLASH),
      ),
    );
  }
}
