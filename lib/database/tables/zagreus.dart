import 'package:zagreus/database/models/external_module.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/database/models/log.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/types/indexer_icon.dart';
import 'package:zagreus/types/list_view_option.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/database/table.dart';
import 'package:zagreus/types/log_type.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/ui.dart';

enum ZagreusDatabase<T> with ZagTableMixin<T> {
  ANDROID_BACK_OPENS_DRAWER<bool>(true),
  DRAWER_AUTOMATIC_MANAGE<bool>(true),
  DRAWER_MANUAL_ORDER<List>([]),
  ENABLED_PROFILE<String>(ZagProfile.DEFAULT_PROFILE),
  DOWNLOADS_DRAWER_ENABLED<bool>(true),
  SPEED_CUBE_ENABLED<bool>(false),
  MODULE_TAB_MEMORY_ENABLED<bool>(true),
  NETWORKING_TLS_VALIDATION<bool>(false),
  NETWORKING_LOCAL_SWITCHING_ENABLED<bool>(false),
  NAVIGATION_DISABLE_HORIZONTAL_SWIPE<bool>(false),
  NETWORKING_SLOW_SERVER_MODE<bool>(false),
  THEME_AMOLED<bool>(false),
  THEME_AMOLED_BORDER<bool>(false),
  THEME_LIGHT_BORDER<bool>(true),
  THEME_IMAGE_BACKGROUND_OPACITY<int>(20),
  THEME_MODE<String>('dark'),
  THEME_FOLLOW_SYSTEM<bool>(false),
  THEME_USE_LUNASEA_COLORS<bool>(false),
  APPEARANCE_HIDE_RATINGS<bool>(false),
  APPEARANCE_HIDE_STREAMING_PROVIDERS<bool>(false),
  QUICK_ACTIONS_LIDARR<bool>(false),
  QUICK_ACTIONS_RADARR<bool>(false),
  QUICK_ACTIONS_SONARR<bool>(false),
  QUICK_ACTIONS_NZBGET<bool>(false),
  QUICK_ACTIONS_SABNZBD<bool>(false),
  QUICK_ACTIONS_OVERSEERR<bool>(false),
  QUICK_ACTIONS_TAUTULLI<bool>(false),
  QUICK_ACTIONS_SEARCH<bool>(false),
  USE_24_HOUR_TIME<bool>(false),
  ENABLE_IN_APP_NOTIFICATIONS<bool>(false),
  ENABLE_IN_APP_TOASTS<bool>(true),
  SETTINGS_LOCK_ENABLED<bool>(false),
  SETTINGS_LOCK_USE_BIOMETRIC<bool>(false),
  CHANGELOG_LAST_BUILD_VERSION<int>(0),
  ZAGREUS_PRO_ENABLED<bool>(false),
  ZAGREUS_PRO_EXPIRY<String>(''),
  ZAGREUS_PRO_SUBSCRIPTION_TYPE<String>(''),
  ZAGREUS_PRO_FIRST_ACTIVATION_COMPLETE<bool>(false),
  ZAGREUS_MEGA_ENABLED<bool>(false),
  ZAGREUS_MEGA_EXPIRY<String>(''),
  ZAGREUS_MEGA_SUBSCRIPTION_TYPE<String>(''),
  ZAGREUS_ULTRA_ENABLED<bool>(false),
  ZAGREUS_ULTRA_EXPIRY<String>(''),
  ZAGREUS_ULTRA_SUBSCRIPTION_TYPE<String>(''),
  ZAGREUS_SUPREME_ENABLED<bool>(false),
  ZAGREUS_SUPREME_EXPIRY<String>(''),
  ZAGREUS_SUPREME_SUBSCRIPTION_TYPE<String>(''),
  LAST_SUBSCRIPTION_VERIFY<String>(''),
  USER_BOOT_MODULE<String>(''),
  DEVICE_ID<String>(''),
  DEVICE_HMAC_KEY<String>(''),
  DEVICE_REGISTERED<bool>(false),
  DEVICE_REGISTERED_USER_ID<String>(''),
  NOTIFICATION_WEBHOOK_ID<String>(''),
  NOTIFICATION_WEBHOOK_SIGNATURE<String>(''),
  NOTIFICATION_ANONYMOUS_MODE<bool>(true),
  // Radarr webhook events
  RADARR_WEBHOOK_ON_GRAB<bool>(true),
  RADARR_WEBHOOK_ON_DOWNLOAD<bool>(true),
  RADARR_WEBHOOK_ON_UPGRADE<bool>(true),
  RADARR_WEBHOOK_ON_MOVIE_ADDED<bool>(true),
  RADARR_WEBHOOK_ON_MANUAL_INTERACTION<bool>(true),
  // Sonarr webhook events
  SONARR_WEBHOOK_ON_GRAB<bool>(true),
  SONARR_WEBHOOK_ON_DOWNLOAD<bool>(true),
  SONARR_WEBHOOK_ON_UPGRADE<bool>(true),
  SONARR_WEBHOOK_ON_SERIES_ADD<bool>(true),
  SONARR_WEBHOOK_ON_MANUAL_INTERACTION<bool>(true),
  // Overseerr notifications
  OVERSEERR_NOTIFICATIONS_ENABLED<bool>(true),
  // Notification prompt (one-time)
  SHOULD_SHOW_NOTIFICATION_PROMPT<bool>(false),
  HAS_SHOWN_NOTIFICATION_PROMPT<bool>(false),
  // Radarr toast events
  RADARR_TOAST_ON_GRAB<bool>(true),
  RADARR_TOAST_ON_DOWNLOAD<bool>(true),
  RADARR_TOAST_ON_UPGRADE<bool>(true),
  RADARR_TOAST_ON_MOVIE_ADDED<bool>(true),
  RADARR_TOAST_ON_MANUAL_INTERACTION<bool>(true),
  // Sonarr toast events
  SONARR_TOAST_ON_GRAB<bool>(true),
  SONARR_TOAST_ON_DOWNLOAD<bool>(true),
  SONARR_TOAST_ON_UPGRADE<bool>(true),
  SONARR_TOAST_ON_SERIES_ADD<bool>(true),
  SONARR_TOAST_ON_MANUAL_INTERACTION<bool>(true),
  // Discover module section order
  DISCOVER_MOVIES_SECTION_ORDER<List>([]),
  DISCOVER_TV_SECTION_ORDER<List>([]),
  // Discover section order migration guards (prevents re-adding deleted sections)
  DISCOVER_MOVIES_SECTION_ORDER_MIGRATED<bool>(false),
  DISCOVER_TV_SECTION_ORDER_MIGRATED<bool>(false),
  // Z Assistant settings
  Z_ASSISTANT_LIBRARY_CACHE_ENABLED<bool>(false),
  Z_ASSISTANT_WATCH_HISTORY_CACHE_ENABLED<bool>(false),
  Z_ASSISTANT_SELECTED_USER_ALIAS<String?>(null),
  // Z Assistant multi-add settings
  Z_ASSISTANT_RADARR_QUALITY_PROFILE_ID<int?>(null),
  Z_ASSISTANT_RADARR_QUALITY_PROFILE_NAME<String?>(null),
  Z_ASSISTANT_RADARR_ROOT_FOLDER<String?>(null),
  Z_ASSISTANT_RADARR_SEARCH_FOR_MISSING<bool>(true),
  Z_ASSISTANT_SONARR_QUALITY_PROFILE_ID<int?>(null),
  Z_ASSISTANT_SONARR_QUALITY_PROFILE_NAME<String?>(null),
  Z_ASSISTANT_SONARR_ROOT_FOLDER<String?>(null),
  Z_ASSISTANT_SONARR_MONITOR_TYPE<String?>('all'),
  Z_ASSISTANT_SONARR_SERIES_TYPE<String?>('standard'),
  Z_ASSISTANT_SONARR_SEARCH_FOR_MISSING<bool>(true),
  Z_ASSISTANT_SONARR_SEARCH_FOR_CUTOFF_UNMET<bool>(false),
  Z_ASSISTANT_SUPABASE_CHAT_SYNC<bool>(false),
  Z_ASSISTANT_PERSIST_CHAT_HISTORY<bool>(true),
  Z_ASSISTANT_DASHBOARD_CHAT_HISTORY<List>([]),
  Z_ASSISTANT_CHAT_CONVERSATIONS<List>([]),
  DISCOVER_POSTER_HEIGHT<double>(200.0),
  DISCOVER_COLUMNS_PER_ROW<int>(3),
  DISCOVER_HERO_HEIGHT<double>(370.0),
  DISCOVER_SHOW_TITLES<bool>(true),
  DISCOVER_MONOCHROME_RATINGS<bool>(false),
  DISCOVER_TRENDING_TIME_WINDOW<String>('day'),
  DISCOVER_SHOW_HERO_CAROUSEL<bool>(true),
  DISCOVER_FILTER_HERO_BY_TAB<bool>(true),
  DISCOVER_HIDE_IN_LIBRARY_FROM_HERO<bool>(false),
  DISCOVER_DEFAULT_TAB<String>('movies'),
  // iPad-specific Discover settings (used when screen is tablet-sized)
  DISCOVER_IPAD_COLUMNS_PER_ROW<int>(4), // Range: 2-6
  DISCOVER_IPAD_HERO_HEIGHT<double>(550.0),
  DISCOVER_IPAD_POSTER_HEIGHT<double>(250.0), // Range: 150-350
  DASHBOARD_SHOW_MODULES_TAB<bool>(true),
  DISCOVER_SHOW_MODULES_TAB<bool>(false),
  SHOW_CALENDAR_TAB<bool>(true),
  SHOW_AGENT_TAB<bool>(true),
  UNRAID_CONFIRM_ACTIONS<bool>(true),
  // Multi-instance support: maps parent profile -> list of shadow profile keys
  // e.g. {"default": ["__radarr__4k__default", "__sonarr__kids__default"]}
  PROFILE_INSTANCES<Map>({}),
  // Calendar instance filter: list of instance keys to show (null = all, empty = none selected shows all)
  // e.g. [null, "__radarr__4k__default"] means show main + 4k radarr
  CALENDAR_INSTANCE_FILTER<List>([]),
  // Custom Sections: user-defined AI recommendation categories (Mega/Ultra only)
  // Stores list of section configs with id, title, description, mediaType
  CUSTOM_SECTIONS<List>([]);

  @override
  ZagTable get table => ZagTable.zagreus;

  @override
  final T fallback;

  const ZagreusDatabase(this.fallback);

  @override
  void register() {
    Hive.registerAdapter(ZagExternalModuleAdapter());
    Hive.registerAdapter(ZagIndexerAdapter());
    Hive.registerAdapter(ZagProfileAdapter());
    Hive.registerAdapter(ZagLogAdapter());
    Hive.registerAdapter(ZagIndexerIconAdapter());
    Hive.registerAdapter(ZagLogTypeAdapter());
    Hive.registerAdapter(ZagModuleAdapter());
    Hive.registerAdapter(ZagListViewOptionAdapter());
  }

  @override
  dynamic export() {
    ZagreusDatabase db = this;
    switch (db) {
      case ZagreusDatabase.DRAWER_MANUAL_ORDER:
        return ZagDrawer.moduleOrderedList()
            .map<String>((module) => module.key)
            .toList();
      default:
        return super.export();
    }
  }

  @override
  void import(dynamic value) {
    ZagreusDatabase db = this;
    dynamic result;

    switch (db) {
      case ZagreusDatabase.DRAWER_MANUAL_ORDER:
        print('[DEBUG] Importing DRAWER_MANUAL_ORDER: $value');
        List<ZagModule> item = [];
        (value as List).cast<String>().forEach((val) {
          ZagModule? module = ZagModule.fromKey(val);
          if (module != null) item.add(module);
        });
        result = item;
        print(
            '[DEBUG] Converted to modules: ${item.map((m) => m.key).toList()}');
        break;
      case ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE:
        print('[DEBUG] Importing DRAWER_AUTOMATIC_MANAGE: $value');
        result = value;
        break;
      default:
        result = value;
        break;
    }

    print(
        '[DEBUG] About to call super.import for ${db.name} with value: $result');
    return super.import(result);
  }
}
