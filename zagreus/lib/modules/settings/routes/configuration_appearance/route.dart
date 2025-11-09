import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/modules/settings.dart';

class ConfigurationAppearanceRoute extends StatefulWidget {
  const ConfigurationAppearanceRoute({super.key});

  @override
  State<ConfigurationAppearanceRoute> createState() => _State();
}

class _State extends State<ConfigurationAppearanceRoute>
    with ZagScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'settings.Appearance'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagHeader(text: 'settings.Appearance'.tr()),
        _themeMode(),
        _imageBackgroundOpacity(),
        _useLunaseaColors(),
        _amoledTheme(),
        _amoledThemeBorders(),
        _lightThemeBorders(),
        _moduleSwitcherFAB(),
      ],
    );
  }

  Widget _themeMode() {
    return ZagBox.zagreus.listenableBuilder(
      selectItems: [
        ZagreusDatabase.THEME_MODE,
        ZagreusDatabase.THEME_FOLLOW_SYSTEM,
      ],
      builder: (context, _) {
        final isFollowingSystem = ZagreusDatabase.THEME_FOLLOW_SYSTEM.read();
        final currentMode = ZagreusDatabase.THEME_MODE.read();

        return Column(
          children: [
            ZagBlock(
              title: 'Follow System Theme',
              body: [
                TextSpan(
                  text: isFollowingSystem
                      ? 'Following system preference'
                      : 'Manual theme control',
                ),
              ],
              trailing: ZagSwitch(
                value: isFollowingSystem,
                onChanged: (value) {
                  ZagreusDatabase.THEME_FOLLOW_SYSTEM.update(value);
                  ZagTheme().initialize();
                  ZagState.reset(context);
                },
              ),
            ),
            if (!isFollowingSystem)
              ZagBlock(
                title: 'Theme Mode',
                body: [
                  TextSpan(
                    text: currentMode == 'light'
                        ? 'Light theme enabled'
                        : 'Dark theme enabled',
                  ),
                ],
                trailing: ZagSwitch(
                  value: currentMode == 'light',
                  onChanged: (value) {
                    ZagreusDatabase.THEME_MODE.update(value ? 'light' : 'dark');
                    ZagTheme().initialize();
                    ZagState.reset(context);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _imageBackgroundOpacity() {
    const db = ZagreusDatabase.THEME_IMAGE_BACKGROUND_OPACITY;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.BackgroundImageOpacity'.tr(),
        body: [
          TextSpan(
            text: db.read() == 0 ? 'zagreus.Disabled'.tr() : '${db.read()}%',
          ),
        ],
        trailing: const ZagIconButton.arrow(),
        onTap: () async {
          final result =
              await SettingsDialogs().changeBackgroundImageOpacity(context);
          if (result.item1) db.update(result.item2);
        },
      ),
    );
  }

  Widget _useLunaseaColors() {
    const db = ZagreusDatabase.THEME_USE_LUNASEA_COLORS;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'Use Original Colors',
        body: const [
          TextSpan(text: 'Enable legacy teal color scheme'),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: (value) {
            db.update(value);
            ZagreusDatabase.THEME_IMAGE_BACKGROUND_OPACITY
                .update(value ? 20 : 25);
            ZagTheme().initialize();
            ZagState.reset(context);
            showZagSnackBar(
              title: 'Theme Changed',
              message: 'Restart the app to fully apply color changes',
              type: ZagSnackbarType.INFO,
            );
          },
        ),
      ),
    );
  }

  Widget _amoledTheme() {
    const db = ZagreusDatabase.THEME_AMOLED;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.AmoledTheme'.tr(),
        body: [
          TextSpan(text: 'settings.AmoledThemeDescription'.tr()),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: (value) {
            db.update(value);
            ZagTheme().initialize();
          },
        ),
      ),
    );
  }

  Widget _amoledThemeBorders() {
    return ZagBox.zagreus.listenableBuilder(
      selectItems: [
        ZagreusDatabase.THEME_AMOLED_BORDER,
        ZagreusDatabase.THEME_AMOLED,
      ],
      builder: (context, _) => ZagBlock(
        title: 'settings.AmoledThemeBorders'.tr(),
        body: [
          TextSpan(text: 'settings.AmoledThemeBordersDescription'.tr()),
        ],
        trailing: ZagSwitch(
          value: ZagreusDatabase.THEME_AMOLED_BORDER.read(),
          onChanged: ZagreusDatabase.THEME_AMOLED.read()
              ? ZagreusDatabase.THEME_AMOLED_BORDER.update
              : null,
        ),
      ),
    );
  }

  Widget _lightThemeBorders() {
    return ZagBox.zagreus.listenableBuilder(
      selectItems: [
        ZagreusDatabase.THEME_LIGHT_BORDER,
        ZagreusDatabase.THEME_MODE,
        ZagreusDatabase.THEME_FOLLOW_SYSTEM,
      ],
      builder: (context, _) {
        final isFollowingSystem = ZagreusDatabase.THEME_FOLLOW_SYSTEM.read();
        final currentMode = ZagreusDatabase.THEME_MODE.read();
        final isLightMode = !isFollowingSystem && currentMode == 'light';

        return ZagBlock(
          title: 'Light Theme Borders',
          body: const [
            TextSpan(text: 'Add subtle borders to cards in light theme'),
          ],
          trailing: ZagSwitch(
            value: ZagreusDatabase.THEME_LIGHT_BORDER.read(),
            onChanged:
                isLightMode ? ZagreusDatabase.THEME_LIGHT_BORDER.update : null,
          ),
        );
      },
    );
  }

  Widget _moduleSwitcherFAB() {
    const db = ZagreusDatabase.MODULE_SWITCHER_FAB_ENABLED;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'Module Switcher FAB',
        body: const [
          TextSpan(text: 'Show the floating module switcher button.'),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: db.update,
        ),
      ),
    );
  }
}
