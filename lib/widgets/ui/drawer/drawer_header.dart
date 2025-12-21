import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/services/settings_lock_service.dart';

class ZagDrawerHeader extends StatelessWidget {
  final String page;

  const ZagDrawerHeader({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) {
        final visibleProfiles = ZagProfile.visibleList;
        return Container(
          child: ZagAppBar.dropdown(
            backgroundColor: Colors.transparent,
            hideLeading: true,
            useDrawer: false,
            title: visibleProfiles.length == 1
                ? 'Zagreus'
                : ZagreusDatabase.ENABLED_PROFILE.read(),
            profiles: visibleProfiles,
            actions: [
              ZagIconButton(
                icon: ZagIcons.SETTINGS,
                onPressed: () async {
                  if (page == ZagModule.SETTINGS.key) {
                    Navigator.of(context).pop();
                    return;
                  }

                  final unlocked =
                      await SettingsLockService.instance.ensureUnlocked(context);
                  if (unlocked) {
                    ZagModule.SETTINGS.launch(restore: false);
                  }
                },
                onLongPress: () {
                  // Toggle between light and dark mode
                  final currentMode = ZagreusDatabase.THEME_MODE.read();
                  ZagreusDatabase.THEME_MODE
                      .update(currentMode == 'light' ? 'dark' : 'light');
                  ZagTheme().initialize();
                  ZagState.reset(context);

                  // Show feedback
                  showZagSuccessSnackBar(
                    title: currentMode == 'light'
                        ? 'Dark Mode Enabled'
                        : 'Light Mode Enabled',
                    message: 'Long press to toggle again',
                  );
                },
              )
            ],
          ),
          decoration: BoxDecoration(
            color: ZagColours.accentColor(context),
            image: DecorationImage(
              image: const AssetImage(ZagAssets.brandingLogo),
              colorFilter: ColorFilter.mode(
                ZagColours.primary.withOpacity(0.15),
                BlendMode.dstATop,
              ),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
