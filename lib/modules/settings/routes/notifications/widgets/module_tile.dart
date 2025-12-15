import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/system/webhooks.dart';

class SettingsNotificationsModuleTile extends StatelessWidget {
  final ZagModule module;

  const SettingsNotificationsModuleTile({
    Key? key,
    required this.module,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBanner(
      headerText: module.title,
      icon: module.icon,
      iconColor: module.color,
      bodyText: module.information,
      buttons: [
        ZagButton.text(
          text: 'settings.Device'.tr(),
          icon: Icons.devices_rounded,
          onTap: () async {
            String deviceId = (await ZagSupabaseMessaging.instance.getToken())!;
            await Clipboard.setData(ClipboardData(
                text: ZagWebhooks.buildDeviceTokenURL(deviceId, module)));
            showZagInfoSnackBar(
              title: 'settings.CopiedURLFor'.tr(args: [module.title]),
              message: 'settings.CopiedDeviceURL'.tr(),
            );
          },
        ),
        if (ZagSupabaseAuth().isSignedIn)
          ZagButton.text(
            text: 'settings.User'.tr(),
            icon: Icons.person_rounded,
            onTap: () async {
              if (!ZagSupabaseAuth().isSignedIn) return;
              String userId = ZagSupabaseAuth().uid!;
              await Clipboard.setData(ClipboardData(
                  text: ZagWebhooks.buildUserTokenURL(userId, module)));
              showZagInfoSnackBar(
                title: 'settings.CopiedURLFor'.tr(args: [module.title]),
                message: 'settings.CopiedUserURL'.tr(),
              );
            },
          ),
        ZagButton.text(
          text: 'settings.Documentation'.tr(),
          icon: ZagIcons.DOCUMENTATION,
          color: ZagColours.blue,
          onTap: module.webhookDocs!.openLink,
        ),
      ],
    );
  }
}
