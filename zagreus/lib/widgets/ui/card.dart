import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagCard extends Card {
  ZagCard({
    Key? key,
    required BuildContext context,
    required Widget child,
    EdgeInsets margin = ZagUI.MARGIN_H_DEFAULT_V_HALF,
    Color? color,
    Decoration? decoration,
    double? height,
    double? width,
  }) : super(
          key: key,
          child: Container(
            child: child,
            decoration: decoration,
            constraints:
                height != null ? BoxConstraints(minHeight: height) : null,
            width: width,
          ),
          margin: margin,
          color: color ??
              (Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor),
          shape: ZagUI.shapeBorder,
          elevation: 0.0,
          clipBehavior: Clip.antiAlias,
        );
}
