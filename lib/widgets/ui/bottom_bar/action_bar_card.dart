import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';

class ZagActionBarCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? color;
  final IconData icon;
  final bool centerText;
  final Function? onTap;
  final Function? onLongPress;
  final bool? checkboxState;
  final void Function(bool?)? checkboxOnChanged;

  const ZagActionBarCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.color,
    this.icon = ZagIcons.ARROW_RIGHT,
    this.centerText = false,
    this.checkboxState,
    this.checkboxOnChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagCard(
      context: context,
      child: InkWell(
        child: SizedBox(
          child: Padding(
            child: Row(
              children: [
                if (centerText && checkboxState == null)
                  const SizedBox(width: 30.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: centerText
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      ZagText(
                        text: title,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        textAlign:
                            centerText ? TextAlign.center : TextAlign.start,
                        style: TextStyle(
                          fontSize: ZagUI.FONT_SIZE_BUTTON,
                          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
                          color: color,
                        ),
                      ),
                      if (subtitle != null)
                        ZagText(
                          text: subtitle!,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          textAlign:
                              centerText ? TextAlign.center : TextAlign.start,
                          style: const TextStyle(
                            fontSize: ZagUI.FONT_SIZE_SUBHEADER,
                            color: ZagColours.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                if (checkboxState != null)
                  Container(
                    width: 30.0,
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 20.0,
                      child: Checkbox(
                        value: checkboxState,
                        onChanged: checkboxOnChanged,
                      ),
                    ),
                  ),
                if (checkboxState == null)
                  Container(
                    width: 30.0,
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 20.0,
                      child: Icon(
                        icon,
                        size: 20.0,
                      ),
                    ),
                  ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),
          height: ZagButton.DEFAULT_HEIGHT,
        ),
        borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
        onTap: _onTapHandler() as void Function()?,
        onLongPress: _onLongPressHandler() as void Function()?,
      ),
      margin: ZagUI.MARGIN_HALF,
      color: backgroundColor != null
          ? backgroundColor!.withOpacity(ZagUI.OPACITY_DIMMED)
          : Theme.of(context).brightness == Brightness.dark
              ? (ZagTheme.isAMOLEDTheme
                  ? Colors.black.withOpacity(ZagUI.OPACITY_DIMMED)
                  : ZagColours.primary.withOpacity(ZagUI.OPACITY_DIMMED))
              : Colors.grey.shade200,
    );
  }

  Function? _onTapHandler() {
    if (onTap != null) {
      return () async {
        HapticFeedback.lightImpact();
        onTap!();
      };
    }
    if (checkboxState != null && checkboxOnChanged != null) {
      return () async => checkboxOnChanged!(!checkboxState!);
    }
    return null;
  }

  Function? _onLongPressHandler() {
    if (onLongPress != null) {
      return () async {
        HapticFeedback.heavyImpact();
        onLongPress!();
      };
    }
    return null;
  }
}
