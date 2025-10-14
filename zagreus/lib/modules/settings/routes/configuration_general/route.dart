import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/bios.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/system/network/network.dart';
import 'package:zagreus/system/platform.dart';

class ConfigurationGeneralRoute extends StatefulWidget {
  const ConfigurationGeneralRoute({
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _State();
}

class _State extends State<ConfigurationGeneralRoute>
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
      title: 'settings.General'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ..._appearance(),
        ..._localization(),
        ..._modules(),
        if (ZagNetwork.isSupported) ..._network(),
        ..._platform(),
      ],
    );
  }

  List<Widget> _appearance() {
    return [
      ZagHeader(text: 'settings.Appearance'.tr()),
      _themeMode(),
      _imageBackgroundOpacity(),
      _useLunaseaColors(),
      _amoledTheme(),
      _amoledThemeBorders(),
      _lightThemeBorders(),
    ];
  }

  List<Widget> _localization() {
    return [
      ZagHeader(text: 'settings.Localization'.tr()),
      _use24HourTime(),
    ];
  }

  List<Widget> _modules() {
    return [
      ZagHeader(text: 'dashboard.Modules'.tr()),
      _bootModule(),
    ];
  }

  List<Widget> _network() {
    return [
      ZagHeader(text: 'settings.Network'.tr()),
      _useTLSValidation(),
    ];
  }

  List<Widget> _platform() {
    if (ZagPlatform.isAndroid) {
      return [
        ZagHeader(text: 'settings.Platform'.tr()),
        _openDrawerOnBackAction(),
      ];
    }

    return [];
  }

  Widget _openDrawerOnBackAction() {
    const _db = ZagreusDatabase.ANDROID_BACK_OPENS_DRAWER;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.OpenDrawerOnBackAction'.tr(),
        body: [
          TextSpan(text: 'settings.OpenDrawerOnBackActionDescription'.tr()),
        ],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }

  Widget _amoledTheme() {
    const _db = ZagreusDatabase.THEME_AMOLED;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.AmoledTheme'.tr(),
        body: [
          TextSpan(text: 'settings.AmoledThemeDescription'.tr()),
        ],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: (value) {
            _db.update(value);
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
          body: [
            TextSpan(text: 'Add subtle borders to cards in light theme'),
          ],
          trailing: ZagSwitch(
            value: ZagreusDatabase.THEME_LIGHT_BORDER.read(),
            onChanged: isLightMode
                ? ZagreusDatabase.THEME_LIGHT_BORDER.update
                : null,
          ),
        );
      },
    );
  }

  Widget _imageBackgroundOpacity() {
    const _db = ZagreusDatabase.THEME_IMAGE_BACKGROUND_OPACITY;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.BackgroundImageOpacity'.tr(),
        body: [
          TextSpan(
            text: _db.read() == 0 ? 'zagreus.Disabled'.tr() : '${_db.read()}%',
          ),
        ],
        trailing: const ZagIconButton.arrow(),
        onTap: () async {
          Tuple2<bool, int> result =
              await SettingsDialogs().changeBackgroundImageOpacity(context);
          if (result.item1) _db.update(result.item2);
        },
      ),
    );
  }

  Widget _useTLSValidation() {
    const _db = ZagreusDatabase.NETWORKING_TLS_VALIDATION;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.TLSCertificateValidation'.tr(),
        body: [
          TextSpan(text: 'settings.TLSCertificateValidationDescription'.tr()),
        ],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: (data) {
            _db.update(data);
            if (ZagNetwork.isSupported) ZagNetwork().initialize();
          },
        ),
      ),
    );
  }

  Widget _use24HourTime() {
    const _db = ZagreusDatabase.USE_24_HOUR_TIME;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.Use24HourTime'.tr(),
        body: [TextSpan(text: 'settings.Use24HourTimeDescription'.tr())],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }

  Widget _bootModule() {
    const _db = BIOSDatabase.BOOT_MODULE;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.BootModule'.tr(),
        body: [TextSpan(text: _db.read().title)],
        trailing: ZagIconButton(icon: _db.read().icon),
        onTap: () async {
          final result = await SettingsDialogs().selectBootModule();
          if (result.item1) {
            BIOSDatabase.BOOT_MODULE.update(result.item2!);
          }
        },
      ),
    );
  }

  Widget _useLunaseaColors() {
    const _db = ZagreusDatabase.THEME_USE_LUNASEA_COLORS;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'Use Original Colors',
        body: [
          TextSpan(text: 'Enable legacy teal color scheme'),
        ],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: (value) {
            _db.update(value);
            // Update background opacity based on theme
            // LunaSea: 20%, Zagreus: 25%
            ZagreusDatabase.THEME_IMAGE_BACKGROUND_OPACITY.update(value ? 20 : 25);
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
                TextSpan(text: isFollowingSystem ? 'Following system preference' : 'Manual theme control'),
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
            if (!isFollowingSystem) ZagBlock(
              title: 'Theme Mode',
              body: [
                TextSpan(text: currentMode == 'light' ? 'Light theme enabled' : 'Dark theme enabled'),
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
}
