import 'package:zagreus/core.dart';

Future<void> showZagErrorSnackBar({
  required String title,
  dynamic error,
  String? message,
  bool showButton = false,
  String buttonText = 'view',
  Function? buttonOnPressed,
}) async =>
    showZagSnackBar(
      title: title,
      message: message ?? ZagLogger.checkLogsMessage,
      type: ZagSnackbarType.ERROR,
      showButton: error != null || showButton,
      buttonText: buttonText,
      buttonOnPressed: () async {
        if (error != null) {
          ZagDialogs().textPreview(
            ZagState.context,
            'Error',
            error.toString(),
          );
        } else if (buttonOnPressed != null) {
          buttonOnPressed();
        }
      },
    );
