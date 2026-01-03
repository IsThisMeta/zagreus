import 'package:zagreus/database/tables/zagreus.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

// ignore: always_use_package_imports
import '../quick_actions.dart';

bool isPlatformSupported() => ZagPlatform.isMobile;
ZagQuickActions getQuickActions() {
  if (isPlatformSupported()) return IO();
  throw UnsupportedError('ZagQuickActions unsupported');
}

class IO implements ZagQuickActions {
  final QuickActions _quickActions = const QuickActions();

  @override
  Future<void> initialize() async {
    _quickActions.initialize(actionHandler);
    setActionItems();
  }

  @override
  void actionHandler(String action) {
    ZagModule.fromKey(action)?.launch();
  }

  @override
  void setActionItems() {
    _quickActions.setShortcutItems(<ShortcutItem>[
      if (ZagreusDatabase.QUICK_ACTIONS_TAUTULLI.read())
        ZagModule.TAUTULLI.shortcutItem,
      if (ZagreusDatabase.QUICK_ACTIONS_SONARR.read())
        ZagModule.SONARR.shortcutItem,
      if (ZagreusDatabase.QUICK_ACTIONS_SEARCH.read())
        ZagModule.SEARCH.shortcutItem,
      if (ZagreusDatabase.QUICK_ACTIONS_SABNZBD.read())
        ZagModule.SABNZBD.shortcutItem,
      if (ZagreusDatabase.QUICK_ACTIONS_RADARR.read())
        ZagModule.RADARR.shortcutItem,
      if (ZagreusDatabase.QUICK_ACTIONS_SEERR.read() && ZagreusPro.isEnabled)
        ZagModule.SEERR.shortcutItem,
      if (ZagreusDatabase.QUICK_ACTIONS_NZBGET.read())
        ZagModule.NZBGET.shortcutItem,
      if (ZagreusDatabase.QUICK_ACTIONS_LIDARR.read())
        ZagModule.LIDARR.shortcutItem,
      ZagModule.SETTINGS.shortcutItem,
    ]);
  }
}
