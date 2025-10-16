import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/system/state.dart';
import 'package:zagreus/types/loading_state.dart';
import 'package:zagreus/widgets/ui.dart';

enum ZagButtonType {
  TEXT,
  ICON,
  LOADER,
}

/// A Zag-styled button.
class ZagButton extends Card {
  static const DEFAULT_HEIGHT = 46.0;

  ZagButton._({
    Key? key,
    required Widget child,
    EdgeInsets margin = ZagUI.MARGIN_HALF,
    Color? backgroundColor,
    double height = DEFAULT_HEIGHT,
    Alignment alignment = Alignment.center,
    Decoration? decoration,
    Function? onTap,
    Function? onLongPress,
    ZagLoadingState? loadingState,
  }) : super(
          key: key,
          child: InkWell(
            child: Container(
              child: child,
              decoration: decoration,
              height: height,
              alignment: alignment,
            ),
            borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
            onTap: () async {
              HapticFeedback.lightImpact();
              if (onTap != null && loadingState != ZagLoadingState.ACTIVE)
                onTap();
            },
            onLongPress: () async {
              HapticFeedback.heavyImpact();
              if (onLongPress != null &&
                  loadingState != ZagLoadingState.ACTIVE) onLongPress();
            },
          ),
          margin: margin,
          color: backgroundColor != null
              ? backgroundColor.withOpacity(ZagUI.OPACITY_DIMMED)
              : Theme.of(ZagState.context)
                  .cardColor
                  .withOpacity(ZagUI.OPACITY_DIMMED),
          shape:
              backgroundColor != null ? ZagShapeBorder() : ZagUI.shapeBorder,
          elevation: ZagUI.ELEVATION,
          clipBehavior: Clip.antiAlias,
        );

  /// Create a default button.
  ///
  /// If [ZagLoadingState] is passed in, will build the correct button based on the type.
  factory ZagButton({
    required ZagButtonType type,
    Color? color,
    Color? backgroundColor,
    String? text,
    IconData? icon,
    double iconSize = ZagUI.ICON_SIZE,
    ZagLoadingState? loadingState,
    EdgeInsets margin = ZagUI.MARGIN_HALF,
    double height = DEFAULT_HEIGHT,
    Alignment alignment = Alignment.center,
    Decoration? decoration,
    Function? onTap,
    Function? onLongPress,
  }) {
    switch (loadingState) {
      case ZagLoadingState.ACTIVE:
        return ZagButton.loader(
          color: color,
          backgroundColor: backgroundColor,
          margin: margin,
          height: height,
          alignment: alignment,
          decoration: decoration,
          onTap: onTap,
          onLongPress: onLongPress,
          loadingState: loadingState,
        );
      case ZagLoadingState.ERROR:
        return ZagButton.icon(
          icon: Icons.error_rounded,
          iconSize: iconSize,
          color: color,
          backgroundColor: backgroundColor,
          margin: margin,
          height: height,
          alignment: alignment,
          decoration: decoration,
          onTap: onTap,
          onLongPress: onLongPress,
          loadingState: loadingState,
        );
      default:
        break;
    }
    switch (type) {
      case ZagButtonType.TEXT:
        return ZagButton.text(
          text: text!,
          icon: icon,
          iconSize: iconSize,
          color: color,
          backgroundColor: backgroundColor,
          margin: margin,
          height: height,
          alignment: alignment,
          decoration: decoration,
          onTap: onTap,
          onLongPress: onLongPress,
          loadingState: loadingState,
        );
      case ZagButtonType.ICON:
        assert(icon != null);
        return ZagButton.icon(
          icon: icon,
          iconSize: iconSize,
          color: color,
          backgroundColor: backgroundColor,
          margin: margin,
          height: height,
          alignment: alignment,
          decoration: decoration,
          onTap: onTap,
          onLongPress: onLongPress,
          loadingState: loadingState,
        );
      case ZagButtonType.LOADER:
        return ZagButton.loader(
          color: color,
          backgroundColor: backgroundColor,
          margin: margin,
          height: height,
          alignment: alignment,
          decoration: decoration,
          onTap: onTap,
          onLongPress: onLongPress,
          loadingState: loadingState,
        );
    }
  }

  /// Build a button that contains a centered text string.
  factory ZagButton.text({
    required String text,
    required IconData? icon,
    double iconSize = ZagUI.ICON_SIZE,
    Color? color,
    Color? backgroundColor,
    EdgeInsets margin = ZagUI.MARGIN_HALF,
    double height = DEFAULT_HEIGHT,
    Alignment alignment = Alignment.center,
    Decoration? decoration,
    ZagLoadingState? loadingState,
    Function? onTap,
    Function? onLongPress,
  }) {
    return ZagButton._(
      child: Padding(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null)
              Padding(
                child: Builder(
                  builder: (context) => Icon(
                    icon,
                    color: color == ZagColours.currentAccent 
                        ? color 
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87),
                    size: iconSize,
                  ),
                ),
                padding: const EdgeInsets.only(
                    right: ZagUI.DEFAULT_MARGIN_SIZE / 2),
              ),
            Flexible(
              child: Builder(
                builder: (context) => Text(
                  text,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: ZagUI.FONT_WEIGHT_BOLD,
                    fontSize: ZagUI.FONT_SIZE_H3,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: ZagUI.DEFAULT_MARGIN_SIZE),
      ),
      margin: margin,
      height: height,
      backgroundColor: backgroundColor,
      alignment: alignment,
      decoration: decoration,
      onTap: onTap,
      onLongPress: onLongPress,
      loadingState: loadingState,
    );
  }

  /// Build a button that contains a [ZagLoader].
  factory ZagButton.loader({
    EdgeInsets margin = ZagUI.MARGIN_HALF,
    Color? color,
    Color? backgroundColor,
    double height = DEFAULT_HEIGHT,
    Alignment alignment = Alignment.center,
    Decoration? decoration,
    Function? onTap,
    Function? onLongPress,
    ZagLoadingState? loadingState,
  }) {
    return ZagButton._(
      child: ZagLoader(
        useSafeArea: false,
        color: color,
        size: ZagUI.FONT_SIZE_H3,
      ),
      margin: margin,
      height: height,
      backgroundColor: backgroundColor,
      alignment: alignment,
      decoration: decoration,
      onTap: onTap,
      onLongPress: onLongPress,
      loadingState: loadingState,
    );
  }

  /// Build a button that contains a single, centered [Icon].
  factory ZagButton.icon({
    required IconData? icon,
    Color? color,
    Color? backgroundColor,
    EdgeInsets margin = ZagUI.MARGIN_HALF,
    double height = DEFAULT_HEIGHT,
    double iconSize = ZagUI.ICON_SIZE,
    Alignment alignment = Alignment.center,
    Decoration? decoration,
    Function? onTap,
    Function? onLongPress,
    ZagLoadingState? loadingState,
  }) {
    return ZagButton._(
      child: Icon(
        icon,
        color: color,
        size: iconSize,
      ),
      margin: margin,
      height: height,
      backgroundColor: backgroundColor,
      alignment: alignment,
      decoration: decoration,
      onTap: onTap,
      onLongPress: onLongPress,
      loadingState: loadingState,
    );
  }
}
