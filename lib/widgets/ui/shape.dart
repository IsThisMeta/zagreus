import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagShapeBorder extends RoundedRectangleBorder {
  ZagShapeBorder({
    bool useBorder = false,
    bool topOnly = false,
  }) : super(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(ZagUI.BORDER_RADIUS),
            topRight: const Radius.circular(ZagUI.BORDER_RADIUS),
            bottomLeft: topOnly
                ? Radius.zero
                : const Radius.circular(ZagUI.BORDER_RADIUS),
            bottomRight: topOnly
                ? Radius.zero
                : const Radius.circular(ZagUI.BORDER_RADIUS),
          ),
          side: useBorder
              ? BorderSide(
                  color: ZagTheme.themeMode == 'light'
                      ? Colors.black.withOpacity(0.08)
                      : ZagColours.white10
                )
              : BorderSide.none,
        );
}
