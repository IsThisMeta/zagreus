import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagBanner extends StatelessWidget {
  // An arbitrarily large number of max lines
  static const _MAX_LINES = 5000000;
  final String headerText;
  final String? bodyText;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? headerColor;
  final Color? bodyColor;
  final Function? dismissCallback;
  final List<ZagButton>? buttons;

  const ZagBanner({
    Key? key,
    this.dismissCallback,
    required this.headerText,
    this.bodyText,
    this.icon = Icons.info_outline_rounded,
    this.iconColor = ZagColours.accent,
    this.backgroundColor,
    this.headerColor,
    this.bodyColor,
    this.buttons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagCard(
      context: context,
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: ZagUI.MARGIN_H_DEFAULT_V_HALF.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ZagUI.MARGIN_H_DEFAULT_V_HALF,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    child: Icon(
                      icon,
                      size: 20.0,
                      color: iconColor,
                    ),
                    padding: EdgeInsets.only(
                        right: ZagUI.MARGIN_DEFAULT.right - 2.0),
                  ),
                  Expanded(
                    child: ZagText.title(
                      text: headerText,
                      color: headerColor ?? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87),
                      maxLines: _MAX_LINES,
                      softWrap: true,
                    ),
                  ),
                  if (dismissCallback != null)
                    InkWell(
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20.0,
                        color: ZagColours.accent,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                      onTap: dismissCallback as void Function()?,
                    ),
                ],
              ),
            ),
            if (bodyText?.isNotEmpty ?? false)
              Padding(
                padding: ZagUI.MARGIN_H_DEFAULT_V_HALF.copyWith(top: 0),
                child: ZagText.subtitle(
                  text: bodyText.toString(),
                  color: bodyColor ?? (Theme.of(context).brightness == Brightness.dark
                      ? ZagColours.grey
                      : Colors.grey.shade700),
                  softWrap: true,
                  maxLines: _MAX_LINES,
                ),
              ),
            if (buttons?.isNotEmpty ?? false)
              ZagButtonContainer(
                padding: EdgeInsets.symmetric(
                    horizontal: ZagUI.MARGIN_H_DEFAULT_V_HALF.left / 2),
                children: buttons!,
              ),
          ],
        ),
      ),
      color: backgroundColor,
    );
  }
}
