import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:device_preview/device_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/database.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/system/cache/image/image_cache.dart';
import 'package:zagreus/system/cache/memory/memory_store.dart';
import 'package:zagreus/system/network/network.dart';
import 'package:zagreus/system/network/local_switching_service.dart';
import 'package:zagreus/system/recovery_mode/main.dart';
import 'package:zagreus/system/window_manager/window_manager.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/modules/services/webhook_sync_service.dart';
import 'package:zagreus/services/hmac_encryption_service.dart';
import 'package:zagreus/services/revenuecat_service.dart';
import 'package:zagreus/services/z_assistant_service.dart';
import 'package:zagreus/services/upcoming_widget_service.dart';
import 'package:zagreus/services/subscription_service.dart';

StreamSubscription<User?>? _aiAuthLinkSubscription;

void _initializeAiAccountLinking() {
  if (!ZagSupabase.isSupported) return;
  if (_aiAuthLinkSubscription != null) return;

  _aiAuthLinkSubscription = ZagSupabaseAuth.authStateChanges().listen((user) {
    final hmacService = HmacEncryptionService();

    if (user == null) {
      hmacService.resetRegistration();
      return;
    }

    final currentUserId = user.id;
    final registeredUserId = hmacService.registeredUserId;
    if (registeredUserId != null && registeredUserId != currentUserId) {
      hmacService.resetRegistration();
    }

    // Kick a forced sync so the backend/device linkage reflects the active account.
    // This is intentionally fire-and-forget.
    unawaited(ZAssistantService().syncSubscriptionIfNeeded(force: true));
  });
}

/// Zagreus Entry Point: Bootstrap & Run Application
///
/// Runs app in guarded zone to attempt to capture fatal (crashing) errors
Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        await bootstrap();
        runApp(const ZagBIOS());
      } catch (error) {
        runApp(const ZagRecoveryMode());
      }
    },
    (error, stack) => ZagLogger().critical(error, stack),
  );
}

/// Bootstrap the core
///
Future<void> bootstrap() async {
  await ZagDatabase().initialize();
  ZagLogger().initialize();
  ZagTheme().initialize();
  if (ZagWindowManager.isSupported) await ZagWindowManager().initialize();
  if (ZagNetwork.isSupported) ZagNetwork().initialize();
  if (ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read()) {
    await ZagLocalConnectionService().refreshSsid();
  }
  if (ZagPlatform.isIOS) {
    _configureLocalNetworkChannel();
  }
  if (ZagImageCache.isSupported) ZagImageCache().initialize();
  // Initialize Supabase for auth and storage
  if (ZagSupabase.isSupported) {
    await ZagSupabase().initialize();
    // Skip anonymous auth for now - will use shared backend with Zebrra later
    // SK2 provides expiry dates directly, so server validation is optional
  }
  ZagRouter().initialize();
  await ZagMemoryStore().initialize();
  // Initialize webhook sync service for 24-hour checks
  WebhookSyncService.initialize();
  // Initialize command processor for zero-knowledge backend requests
  // CommandProcessorService().startPolling(); // DISABLED: Not using polling, trigger manually instead
  // Initialize RevenueCat for in-app purchases (iOS & macOS support)
  if (ZagPlatform.isIOS || ZagPlatform.isMacOS) {
    await RevenueCatService().initialize();
    // Bitcoin miner started
  }
  // Initialize subscription cache and shared access checks after Supabase init.
  SubscriptionService().initialize();
  // Wire auth-change listener after RevenueCat is configured (prevents Purchases crash).
  _initializeAiAccountLinking();
  // Initialize home screen widget
  if (ZagPlatform.isIOS) await UpcomingWidgetService.initialize();
}

class ZagBIOS extends StatefulWidget {
  const ZagBIOS({
    super.key,
  });

  @override
  State<ZagBIOS> createState() => _ZagBIOSState();
}

const MethodChannel _localNetworkChannel =
    MethodChannel('app.zagreus/local_network');

void _configureLocalNetworkChannel() {
  _localNetworkChannel.setMethodCallHandler((call) async {
    if (call.method == 'ssidChanged') {
      final ssid = call.arguments as String?;
      ZagLocalConnectionService().updateSsidFromNative(ssid);
    }
  });
}

class _ZagBIOSState extends State<ZagBIOS> with WidgetsBindingObserver {
  StreamSubscription? _foregroundNotificationSubscription;
  StreamSubscription? _backgroundNotificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotificationListeners();
    _checkAndShowNotificationPrompt();
  }

  void _checkAndShowNotificationPrompt() {
    // Check if we should show the notification prompt
    final shouldShow = ZagreusDatabase.SHOULD_SHOW_NOTIFICATION_PROMPT.read();
    final hasShown = ZagreusDatabase.HAS_SHOWN_NOTIFICATION_PROMPT.read();

    print('🔔 Notification prompt check: shouldShow=$shouldShow, hasShown=$hasShown');

    if (shouldShow && !hasShown) {
      print('🔔 Scheduling notification prompt dialog');
      Future.delayed(const Duration(seconds: 3), () {
        print('🔔 Delayed callback executing after 3 seconds...');
        _showNotificationPromptDialog();
      });
    } else {
      print('🔔 Skipping notification prompt (shouldShow=$shouldShow, hasShown=$hasShown)');
    }
  }

  Future<void> _showNotificationPromptDialog() async {
    print('🔔 _showNotificationPromptDialog called');
    
    final context = ZagRouter.navigator.currentContext;
    if (context == null) {
      print('🔔 ERROR: Context is null, cannot show dialog');
      return;
    }

    print('🔔 Context found, showing dialog...');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Enable Notifications',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ZagDialog.HEADER_SIZE,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: ZagColours.textColor(context),
          ),
        ),
        content: Text(
          'Would you like to enable notifications for your services? They are free and one-click!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ZagColours.textColor(context).withOpacity(0.85),
            fontSize: ZagDialog.BODY_SIZE,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Yes',
              style: TextStyle(color: ZagColours.accentColor(context)),
            ),
          ),
        ],
        shape: ZagUI.shapeBorder,
      ),
    );

    print('🔔 Dialog closed, result: $result');

    // Mark as shown (regardless of choice)
    ZagreusDatabase.SHOULD_SHOW_NOTIFICATION_PROMPT.update(false);
    ZagreusDatabase.HAS_SHOWN_NOTIFICATION_PROMPT.update(true);
    print('🔔 Flags updated - prompt marked as shown');

    // Navigate to notifications settings if user said yes
    if (result == true) {
      print('🔔 User clicked Yes - attempting navigation...');
      print('🔔 Context mounted: ${context.mounted}');
      
      if (context.mounted) {
        print('🔔 Calling SettingsRoutes.NOTIFICATIONS.go()');
        SettingsRoutes.NOTIFICATIONS.go();
        print('🔔 Navigation command sent');
      } else {
        print('🔔 ERROR: Context not mounted, cannot navigate');
      }
    } else {
      print('🔔 User said No or dismissed dialog (result=$result)');
    }
  }

  void _initializeNotificationListeners() {
    if (ZagSupabaseMessaging.isSupported) {
      // Handle notifications when app is in foreground (show as toasts)
      _foregroundNotificationSubscription =
          ZagSupabaseMessaging.instance.registerOnMessageListener();

      // Handle notification taps when app is in background
      _backgroundNotificationSubscription =
          ZagSupabaseMessaging.instance.registerOnMessageOpenedAppListener();

      // Check for initial message (app opened from notification)
      ZagSupabaseMessaging.instance.checkAndHandleInitialMessage();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _foregroundNotificationSubscription?.cancel();
    _backgroundNotificationSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed &&
        ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read()) {
      ZagLocalConnectionService().refreshSsid();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ZagTheme();
    final router = ZagRouter.router;

    return ZagState.providers(
      child: _WidgetUpdateTrigger(
        child: DevicePreview(
          enabled: kDebugMode && ZagPlatform.isDesktop,
          builder: (context) => EasyLocalization(
            supportedLocales: [Locale('en')],
            path: 'assets/localization',
            fallbackLocale: Locale('en'),
            startLocale: Locale('en'),
            useFallbackTranslations: true,
            child: ZagBox.zagreus.listenableBuilder(
              selectItems: [
                ZagreusDatabase.THEME_AMOLED,
                ZagreusDatabase.THEME_AMOLED_BORDER,
                ZagreusDatabase.THEME_LIGHT_BORDER,
                ZagreusDatabase.THEME_MODE,
                ZagreusDatabase.THEME_FOLLOW_SYSTEM,
              ],
              builder: (context, _) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  builder: (context, child) {
                    return DevicePreview.appBuilder(context, child);
                  },
                  darkTheme:
                      theme.activeTheme(systemBrightness: Brightness.dark),
                  theme: theme.activeTheme(systemBrightness: Brightness.light),
                  themeMode: ZagreusDatabase.THEME_FOLLOW_SYSTEM.read()
                      ? ThemeMode.system
                      : (ZagreusDatabase.THEME_MODE.read() == 'light'
                          ? ThemeMode.light
                          : ThemeMode.dark),
                  title: 'Zagreus',
                  routeInformationProvider: router.routeInformationProvider,
                  routeInformationParser: router.routeInformationParser,
                  routerDelegate: router.routerDelegate,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget that triggers the home screen widget update after app launches
class _WidgetUpdateTrigger extends StatefulWidget {
  final Widget child;

  const _WidgetUpdateTrigger({required this.child});

  @override
  State<_WidgetUpdateTrigger> createState() => _WidgetUpdateTriggerState();
}

class _WidgetUpdateTriggerState extends State<_WidgetUpdateTrigger> {
  @override
  void initState() {
    super.initState();

    // Update widget after app initializes
    if (ZagPlatform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateWidget();
      });
    }
  }

  Future<void> _updateWidget() async {
    try {
      print('🏠 WidgetUpdateTrigger: Starting widget update from main...');
      // Wait for states to be available
      await Future.delayed(const Duration(seconds: 5));

      final radarrState = context.read<RadarrState>();
      final sonarrState = context.read<SonarrState>();

      print(
          '🏠 WidgetUpdateTrigger: Radarr enabled=${radarrState.enabled}, Sonarr enabled=${sonarrState.enabled}');

      await UpcomingWidgetService.updateWidget(
        radarrState: radarrState,
        sonarrState: sonarrState,
        skipIfAlreadyUpdated: true,
      );
    } catch (e, stack) {
      print('❌ WidgetUpdateTrigger: Widget update error: $e');
      print('Stack: $stack');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
