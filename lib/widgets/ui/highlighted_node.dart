import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagHighlightedNode extends StatelessWidget {
  final Color? backgroundColor;
  final Color textColor;
  final String text;

  const ZagHighlightedNode({
    Key? key,
    required this.text,
    this.backgroundColor,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(
            fontSize: ZagUI.FONT_SIZE_H4,
            color: textColor,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
      ),
    );
  }
}
