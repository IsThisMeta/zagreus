import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/bios.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/system/network/network.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/system/network/local_switching_service.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/services/biometric_service.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/widgets/ui/snackbar/snackbar_info.dart';

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
  bool _biometricSupported = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSupport();
  }

  Future<void> _loadBiometricSupport() async {
    final supported = await BiometricService.instance.isSupported();
    if (!mounted) return;
    setState(() {
      _biometricSupported = supported;
    });
  }

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
        ..._localization(),
        ..._modules(),
        ..._security(),
        if (ZagNetwork.isSupported) ..._network(),
        ..._platform(),
      ],
    );
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

  Widget _settingsLockToggle({
    required bool supabaseAvailable,
    required bool isSignedIn,
  }) {
    const db = ZagreusDatabase.SETTINGS_LOCK_ENABLED;
    return ZagBox.zagreus.listenableBuilder(
      selectItems: [
        ZagreusDatabase.SETTINGS_LOCK_ENABLED,
      ],
      builder: (context, _) {
        final enabled = db.read();
        final isPro = ZagreusPro.isEnabled;
        final canToggle = supabaseAvailable && isSignedIn && isPro;

        VoidCallback? onTap;
        if (!isPro) {
          onTap = () => _showProUpgradeToast('settings.LockSettings'.tr());
        } else if (!supabaseAvailable) {
          onTap = () => showZagInfoSnackBar(
                title: 'settings.SettingsLockUnavailableTitle'.tr(),
                message: 'settings.SettingsLockUnavailableMessage'.tr(),
              );
        } else if (!isSignedIn) {
          onTap = () {
            showZagInfoSnackBar(
              title: 'settings.SignInRequiredTitle'.tr(),
              message: 'settings.SignInRequiredMessage'.tr(
                args: ['settings.LockSettings'.tr()],
              ),
            );
            SettingsRoutes.ACCOUNT.go();
          };
        }

        return ZagBlock(
          title: 'settings.LockSettings'.tr(),
          body: [
            TextSpan(text: 'settings.LockSettingsDescription'.tr()),
          ],
          trailing: ZagSwitch(
            value: enabled,
            onChanged: canToggle
                ? (value) {
                    db.update(value);
                    if (!value) {
                      ZagreusDatabase.SETTINGS_LOCK_USE_BIOMETRIC.update(false);
                    }
                  }
                : null,
          ),
          onTap: onTap,
        );
      },
    );
  }

  Widget _settingsLockBiometricToggle({required bool isSignedIn}) {
    const db = ZagreusDatabase.SETTINGS_LOCK_USE_BIOMETRIC;
    return ZagBox.zagreus.listenableBuilder(
      selectItems: [
        ZagreusDatabase.SETTINGS_LOCK_ENABLED,
        ZagreusDatabase.SETTINGS_LOCK_USE_BIOMETRIC,
      ],
      builder: (context, _) {
        final isPro = ZagreusPro.isEnabled;
        final lockEnabled =
            isPro && ZagreusDatabase.SETTINGS_LOCK_ENABLED.read();
        final biometricEnabled = db.read();
        final canToggle = lockEnabled && isSignedIn;

        VoidCallback? onTap;
        if (!isPro) {
          onTap = () => _showProUpgradeToast('settings.FaceIdUnlock'.tr());
        } else if (!lockEnabled) {
          onTap = () => showZagInfoSnackBar(
                title: 'settings.EnableLockSettingsTitle'.tr(),
                message: 'settings.EnableLockSettingsMessage'.tr(),
              );
        } else if (!isSignedIn) {
          onTap = () {
            showZagInfoSnackBar(
              title: 'settings.SignInRequiredTitle'.tr(),
              message: 'settings.SignInRequiredMessage'.tr(
                args: ['settings.FaceIdUnlock'.tr()],
              ),
            );
            SettingsRoutes.ACCOUNT.go();
          };
        }

        return ZagBlock(
          title: 'settings.UseFaceId'.tr(),
          body: [
            TextSpan(text: 'settings.UseFaceIdDescription'.tr()),
          ],
          trailing: ZagSwitch(
            value: biometricEnabled && lockEnabled,
            onChanged: canToggle ? db.update : null,
          ),
          onTap: onTap,
        );
      },
    );
  }

  List<Widget> _security() {
    final supabaseAvailable = ZagSupabase.isSupported;
    final auth = ZagSupabaseAuth();
    final isSignedIn = supabaseAvailable && auth.isSignedIn;

    final widgets = <Widget>[
      ZagHeader(text: 'settings.Security'.tr()),
      _settingsLockToggle(
        supabaseAvailable: supabaseAvailable,
        isSignedIn: isSignedIn,
      ),
    ];

    if (_biometricSupported) {
      widgets.add(
        _settingsLockBiometricToggle(
          isSignedIn: isSignedIn,
        ),
      );
    }


    return widgets;
  }

  List<Widget> _network() {
    final widgets = <Widget>[
      ZagHeader(text: 'settings.Network'.tr()),
      _useTLSValidation(),
      _advancedLocalSwitching(),
      _slowServerMode(),
    ];

    return widgets;
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

  Widget _advancedLocalSwitching() {
    const db = ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED;
    return db.listenableBuilder(
      builder: (context, _) {
        final isPro = ZagreusPro.isEnabled;
        return ZagBlock(
          title: 'settings.AdvancedLocalSwitching'.tr(),
          body: [
            TextSpan(
              text: 'settings.AdvancedLocalSwitchingDescription'.tr(),
            ),
          ],
          trailing: ZagSwitch(
            value: db.read(),
            onChanged: isPro
                ? (value) async {
                    db.update(value);
                    await ZagLocalConnectionService()
                        .handleAdvancedToggle(value);
                  }
                : null,
          ),
          onTap: isPro
              ? null
              : () => _showProUpgradeToast(
                    'settings.AdvancedLocalSwitching'.tr(),
                  ),
        );
      },
    );
  }

  Widget _slowServerMode() {
    const db = ZagreusDatabase.NETWORKING_SLOW_SERVER_MODE;
    return db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.SlowServerMode'.tr(),
        body: [
          TextSpan(text: 'settings.SlowServerModeDescription'.tr()),
        ],
        trailing: ZagSwitch(
          value: db.read(),
          onChanged: (value) {
            db.update(value);
            final radarrState = ZagModule.RADARR.state(context);
            final sonarrState = ZagModule.SONARR.state(context);
            radarrState?.reset();
            sonarrState?.reset();
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
            // Also save as user preference so it persists through subscription changes
            ZagreusDatabase.USER_BOOT_MODULE.update(result.item2!.key);
          }
        },
      ),
    );
  }


  void _showProUpgradeToast(String featureName) {
    showZagInfoSnackBar(
      title: 'settings.ZagreusProRequiredTitle'.tr(),
      message: 'settings.ZagreusProRequiredMessage'.tr(
        args: [featureName],
      ),
    );
  }

}
