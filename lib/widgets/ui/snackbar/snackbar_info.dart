import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/core.dart';

Future<void> showZagInfoSnackBar({
  required String title,
  required String? message,
  bool showButton = false,
  String buttonText = 'view',
  Function? buttonOnPressed,
}) async =>
    showZagSnackBar(
      title: title,
      message: message.uiSafe(),
      type: ZagSnackbarType.INFO,
      showButton: showButton,
      buttonText: buttonText,
      buttonOnPressed: buttonOnPressed,
    );
