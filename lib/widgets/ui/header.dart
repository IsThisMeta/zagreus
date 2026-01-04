import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagHeader extends StatelessWidget {
  final String? text;
  final String? subtitle;

  const ZagHeader({
    Key? key,
    required this.text,
    this.subtitle,
  }) : super(key: key);

  Widget _headerText(BuildContext context) {
    return Text(
      text!,
      style: TextStyle(
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        fontSize: ZagUI.FONT_SIZE_H2,
        color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
      ),
    );
  }

  Widget _barSeperator(BuildContext context) {
    return Padding(
      child: Container(
        height: 2.0,
        width: ZagUI.DEFAULT_MARGIN_SIZE * 3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
          color: ZagColours.accentColor(context),
        ),
      ),
      padding: const EdgeInsets.only(
        top: ZagUI.DEFAULT_MARGIN_SIZE / 2,
        left: 0,
        bottom: ZagUI.DEFAULT_MARGIN_SIZE / 2,
      ),
    );
  }

  Widget _subtitle(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      child: Text(
        subtitle!,
        style: TextStyle(
          fontSize: ZagUI.FONT_SIZE_H4,
          color: isLight ? Colors.black87 : ZagColours.grey,
          fontWeight: FontWeight.w300,
        ),
      ),
      padding: const EdgeInsets.only(bottom: ZagUI.DEFAULT_MARGIN_SIZE / 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerText(context),
          _barSeperator(context),
          if (subtitle != null) _subtitle(context),
        ],
      ),
      padding: const EdgeInsets.only(
        left: ZagUI.DEFAULT_MARGIN_SIZE,
        right: ZagUI.DEFAULT_MARGIN_SIZE,
        top: ZagUI.DEFAULT_MARGIN_SIZE / 2,
      ),
    );
  }
}
