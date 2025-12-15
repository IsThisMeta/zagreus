import 'package:flutter/material.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/router/routes/dashboard.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';

class ZagMessage extends StatelessWidget {
  final String text;
  final Color? textColor;
  final String? buttonText;
  final Function? onTap;
  final bool useSafeArea;

  const ZagMessage({
    Key? key,
    required this.text,
    this.textColor,
    this.buttonText,
    this.onTap,
    this.useSafeArea = true,
  }) : super(key: key);

  /// Return a message that is meant to be shown within a [ListView].
  factory ZagMessage.inList({
    Key? key,
    required String text,
    bool useSafeArea = false,
  }) {
    return ZagMessage(
      key: key,
      text: text,
      useSafeArea: useSafeArea,
    );
  }

  /// Returns a centered message with a simple message, with a button to pop out of the route.
  factory ZagMessage.goBack({
    Key? key,
    required String text,
    required BuildContext context,
    bool useSafeArea = true,
  }) {
    return ZagMessage(
      key: key,
      text: text,
      buttonText: 'zagreus.GoBack'.tr(),
      onTap: () {
        if (ZagRouter.router.canPop()) {
          ZagRouter.router.pop();
        } else {
          ZagRouter.router.pushReplacement(DashboardRoutes.HOME.path);
        }
      },
      useSafeArea: useSafeArea,
    );
  }

  /// Return a pre-structured "An Error Has Occurred" message, with a "Try Again" button shown.
  factory ZagMessage.error({
    Key? key,
    required Function onTap,
    bool useSafeArea = true,
  }) {
    return ZagMessage(
      key: key,
      text: 'zagreus.AnErrorHasOccurred'.tr(),
      buttonText: 'zagreus.TryAgain'.tr(),
      onTap: onTap,
      useSafeArea: useSafeArea,
    );
  }

  /// Return a pre-structured "<module> Is Not Enabled" message, with a "Return to Dashboard" button shown.
  factory ZagMessage.moduleNotEnabled({
    Key? key,
    required BuildContext context,
    required String module,
    bool useSafeArea = true,
  }) {
    return ZagMessage(
      key: key,
      text: 'zagreus.ModuleIsNotEnabled'.tr(args: [module]),
      buttonText: 'zagreus.ReturnToDashboard'.tr(),
      onTap: ZagModule.DASHBOARD.launch,
      useSafeArea: useSafeArea,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: useSafeArea,
      left: useSafeArea,
      right: useSafeArea,
      bottom: useSafeArea,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            margin: ZagUI.MARGIN_H_DEFAULT_V_HALF,
            elevation: ZagUI.ELEVATION,
            shape: ZagUI.shapeBorder,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor ?? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87),
                        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
                        fontSize: ZagUI.FONT_SIZE_MESSAGES,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 24.0, horizontal: 12.0),
                  ),
                ),
              ],
            ),
          ),
          if (buttonText != null)
            ZagButtonContainer(
              children: [
                ZagButton.text(
                  text: buttonText!,
                  icon: null,
                  onTap: onTap,
                  color: Colors.white,
                  backgroundColor: ZagColours.currentAccent,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
