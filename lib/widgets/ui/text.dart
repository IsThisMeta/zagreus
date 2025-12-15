import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagText extends Text {
  /// Create a new [Text] widget.
  const ZagText({
    required String text,
    Key? key,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    TextStyle? style,
    TextAlign? textAlign,
  }) : super(
          text,
          key: key,
          maxLines: maxLines == 0 ? null : maxLines,
          overflow: overflow,
          softWrap: softWrap,
          style: style,
          textAlign: textAlign,
        );

  /// Create a [ZagText] widget with the styling pre-assigned to be a Zagreus title.
  factory ZagText.title({
    Key? key,
    required String text,
    int maxLines = 1,
    bool softWrap = false,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.fade,
    Color? color,
  }) =>
      ZagText(
        text: text,
        key: key,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        textAlign: textAlign,
        style: TextStyle(
          color: color,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          fontSize: ZagUI.FONT_SIZE_H2,
        ),
      );

  /// Create a [ZagText] widget with the styling pre-assigned to be a Zagreus subtitle.
  factory ZagText.subtitle({
    Key? key,
    required String text,
    int maxLines = 1,
    bool softWrap = false,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.fade,
    Color color = ZagColours.grey,
    FontStyle fontStyle = FontStyle.normal,
  }) =>
      ZagText(
        key: key,
        text: text,
        softWrap: softWrap,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
        style: TextStyle(
          color: color,
          fontSize: ZagUI.FONT_SIZE_H3,
          fontStyle: fontStyle,
        ),
      );
}
