import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagTextSpan extends TextSpan {
  const ZagTextSpan.extended({
    required String? text,
  }) : super(
          text: text,
          style: const TextStyle(
            height: ZagBlock.SUBTITLE_HEIGHT / ZagUI.FONT_SIZE_H3,
          ),
        );
}
