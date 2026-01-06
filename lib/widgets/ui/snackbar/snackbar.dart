import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/router/router.dart';

enum ZagSnackbarType {
  SUCCESS,
  ERROR,
  INFO,
}

extension ZagSnackbarTypeExtension on ZagSnackbarType {
  Color get color {
    switch (this) {
      case ZagSnackbarType.SUCCESS:
        return ZagColours.currentAccent;
      case ZagSnackbarType.ERROR:
        return ZagColours.red;
      case ZagSnackbarType.INFO:
        return ZagColours.blue;
      default:
        return ZagColours.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case ZagSnackbarType.SUCCESS:
        return Icons.check_circle_outline_rounded;
      case ZagSnackbarType.ERROR:
        return Icons.error_outline_rounded;
      case ZagSnackbarType.INFO:
        return Icons.info_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

Future<void> showZagSnackBar({
  required String title,
  required ZagSnackbarType type,
  required String message,
  Duration? duration,
  FlashPosition position = FlashPosition.bottom,
  bool showButton = false,
  String buttonText = 'view',
  Function? buttonOnPressed,
  String? posterUrl,
}) async {
  // Check if in-app toasts are enabled
  if (!ZagreusDatabase.ENABLE_IN_APP_TOASTS.read()) {
    return;
  }

  final ctx = ZagRouter.navigator.currentContext;
  if (ctx == null || !ctx.mounted) return;

  showFlash(
    context: ctx,
    duration: duration ?? Duration(seconds: showButton ? 4 : 2),
    transitionDuration: const Duration(milliseconds: ZagUI.ANIMATION_SPEED),
    reverseTransitionDuration:
        const Duration(milliseconds: ZagUI.ANIMATION_SPEED),
    builder: (context, controller) => FlashBar(
      controller: controller,
      backgroundColor: Theme.of(context).primaryColor,
      behavior: FlashBehavior.floating,
      margin: ZagUI.MARGIN_DEFAULT,
      position: position,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color:
              ZagUI.shouldUseBorder ? ZagColours.white10 : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
      ),
      title: ZagText.title(
        text: title,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
      ),
      content: ZagText.subtitle(
        text: message,
        maxLines: 8,
        overflow: TextOverflow.ellipsis,
        color: Theme.of(context).brightness == Brightness.dark
            ? ZagColours.grey
            : Colors.black54,
      ),
      shouldIconPulse: false,
      icon: Padding(
        padding: const EdgeInsets.only(
          left: ZagUI.DEFAULT_MARGIN_SIZE / 2,
        ),
        child: posterUrl != null && posterUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  posterUrl,
                  width: 36,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ZagIconButton(
                    icon: type.icon,
                    color: type.color,
                  ),
                ),
              )
            : ZagIconButton(
                icon: type.icon,
                color: type.color,
              ),
      ),
      primaryAction: showButton
          ? TextButton(
              child: Text(
                buttonText.toUpperCase(),
                style: TextStyle(
                  fontWeight: ZagUI.FONT_WEIGHT_BOLD,
                  color: ZagColours.currentAccent,
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.dismiss();
                buttonOnPressed!();
              },
            )
          : null,
    ),
  );
}
