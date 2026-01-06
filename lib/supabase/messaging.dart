import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/profile_tools.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/radarr/core/webhook_manager.dart';
import 'package:zagreus/modules/sonarr/core/webhook_manager.dart';
import 'package:dio/dio.dart';

class ZagSupabaseMessaging {
  // Method channel for native iOS communication
  static const MethodChannel _channel = MethodChannel('app.zagreus/notifications');
  
  // Singleton instance
  static final ZagSupabaseMessaging _instance = ZagSupabaseMessaging._internal();
  factory ZagSupabaseMessaging() => _instance;
  ZagSupabaseMessaging._internal() {
    _setupMethodCallHandler();
  }
  
  // Store the current APNS token
  String? _apnsToken;
  
  // Force clear cached token
  void clearCachedToken() {
    ZagLogger().debug('Clearing cached token');
    _apnsToken = null;
  }
  final _tokenController = StreamController<String>.broadcast();
  Stream<String> get onTokenRefresh => _tokenController.stream;
  
  static bool get isSupported {
    if (ZagSupabase.isSupported && Platform.isIOS) return true;
    return false;
  }

  /// Returns an instance to handle APNS.
  static ZagSupabaseMessaging get instance => _instance;

  /// Returns a stream controller for handling messages
  final StreamController<RemoteMessage> _messageController = 
      StreamController<RemoteMessage>.broadcast();

  /// Returns a [Stream] to handle any new messages that are received while the application is in the open and in foreground.
  Stream<RemoteMessage> get onMessage => _messageController.stream;

  /// Returns a [Stream] to handle any notifications that are tapped while the application is in the background (not terminated).
  Stream<RemoteMessage> get onMessageOpenedApp => _messageController.stream;

  /// Set up method call handler to receive messages from iOS
  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onToken':
          final String token = call.arguments as String;
          _apnsToken = token;
          _tokenController.add(token);
          ZagLogger().debug('Received APNS token: $token');
          // Note: We no longer auto-register here to avoid race conditions
          // and duplicate registrations. Registration happens explicitly
          // when the user enables notifications via registerDeviceToken().
          break;
        case 'onMessage':
          // Handle foreground notification from iOS
          final Map<dynamic, dynamic> data = call.arguments as Map<dynamic, dynamic>;
          ZagLogger().debug('Received foreground notification: $data');

          // Create RemoteMessage from iOS data
          final message = RemoteMessage(
            notification: RemoteNotification(
              title: data['title'] as String?,
              body: data['body'] as String?,
            ),
            data: Map<String, dynamic>.from(data),
          );

          // Add to message stream for toast display
          _messageController.add(message);
          break;
        case 'onMessageOpenedApp':
          // Handle notification tap when app is in background
          final Map<dynamic, dynamic> data = call.arguments as Map<dynamic, dynamic>;
          ZagLogger().debug('Notification tapped: $data');

          final message = RemoteMessage(
            data: Map<String, dynamic>.from(data),
          );

          // Handle the webhook navigation
          _handleWebhook(message);
          break;
        default:
          ZagLogger().warning('Unknown method call from iOS: ${call.method}');
      }
    });
  }

  /// Returns the APNS device token for this device.
  Future<String?> getToken() async {
    // If we already have a token, return it
    if (_apnsToken != null) {
      ZagLogger().debug('Returning cached token: $_apnsToken');
      return _apnsToken;
    }
    
    // Check if running on simulator
    try {
      final isSimulator = await _channel.invokeMethod<bool>('isSimulator') ?? false;
      if (isSimulator) {
        ZagLogger().warning('Running on simulator - push notifications not available');
        return null;
      }
    } catch (e) {
      // Method might not be implemented, continue anyway
    }
    
    // Otherwise, request permissions which will trigger token generation
    final bool granted = await requestNotificationPermissions();
    if (!granted) {
      ZagLogger().warning('Notification permissions not granted');
      return null;
    }
    
    // Wait for the token with a timeout
    int attempts = 0;
    while (_apnsToken == null && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    
    if (_apnsToken == null) {
      ZagLogger().warning('Failed to receive APNS token after ${attempts * 500}ms');
    }
    
    return _apnsToken;
  }

  /// Register the current device token with the notification server
  Future<bool> registerDeviceToken({bool anonymous = false}) async {
    final token = await getToken();
    if (token == null) {
      ZagLogger().warning('No token available to register');
      return false;
    }
    return _registerDeviceWithServer(token, anonymous: anonymous);
  }

  /// Register the device token with the notification server
  Future<bool> _registerDeviceWithServer(String token, {bool anonymous = false}) async {
    try {
      final dio = Dio();

      // For anonymous mode, skip user check
      String? userId;
      if (!anonymous) {
        final user = ZagSupabase.client.auth.currentUser;
        if (user == null) {
          ZagLogger().warning('No authenticated user, cannot register device');
          return false;
        }
        userId = user.id;
      }

      // Get device info matching Go service expectations
      final deviceInfo = {
        if (userId != null) 'user_id': userId,
        'device_token': token,
        'device_type': Platform.isIOS ? 'ios' : 'android',
        'anonymous': anonymous,
      };

      final response = await dio.post(
        'https://zagreus-notifications.fly.dev/v1/auth/register',
        data: deviceInfo,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Extract webhook ID and signature from response
        final responseData = response.data;
        if (responseData is Map && responseData['webhook_id'] != null) {
          final webhookId = responseData['webhook_id'] as String;
          final webhookSignature = responseData['webhook_signature'] as String?;

          // Store the webhook ID and signature locally
          await _storeWebhookCredentials(webhookId, webhookSignature ?? '');

          // Store anonymous mode preference
          ZagreusDatabase.NOTIFICATION_ANONYMOUS_MODE.update(anonymous);

          ZagLogger().debug('Successfully registered device with webhook ID: $webhookId');
        } else {
          ZagLogger().debug('Successfully registered device (no webhook ID returned)');
        }
        return true;
      } else {
        ZagLogger().error('Failed to register device: ${response.statusCode}', null, null);
        return false;
      }
    } catch (error, stack) {
      ZagLogger().error('Error registering device with server', error, stack);
      return false;
    }
  }

  /// Request for permission to send a user notifications.
  ///
  /// Returns true if permissions are allowed.
  /// Returns false if permissions are denied or not determined.
  Future<bool> requestNotificationPermissions() async {
    try {
      // Use method channel to request iOS notification permissions
      final bool granted = await _channel.invokeMethod('requestPermission');
      return granted;
    } catch (error, stack) {
      ZagLogger()
          .error('Failed to request notification permission', error, stack);
      return false;
    }
  }

  /// Return the current notification authorization status.
  Future<AuthorizationStatus> getAuthorizationStatus() async {
    try {
      final bool allowed = await _channel.invokeMethod('checkPermission');
      return allowed ? AuthorizationStatus.authorized : AuthorizationStatus.denied;
    } catch (error, stack) {
      ZagLogger().error('Failed to check notification permission', error, stack);
      return AuthorizationStatus.notDetermined;
    }
  }

  /// Returns true if permissions are allowed.
  /// Returns false on any other status (denied, not determined, null, etc.).
  Future<bool> areNotificationsAllowed() async {
    final status = await getAuthorizationStatus();
    return status == AuthorizationStatus.authorized ||
           status == AuthorizationStatus.provisional;
  }

  /// Return a [StreamSubscription] that will show a notification banner on a newly received notification.
  ///
  /// This listens on the message stream where the application must be open and in the foreground.
  StreamSubscription<RemoteMessage> registerOnMessageListener() {
    return onMessage.listen((message) {
      if (!ZagreusDatabase.ENABLE_IN_APP_TOASTS.read()) return;

      String? moduleKey = message.data['module'] as String?;
      String? eventType = message.data['event_type'] as String?;
      ZagModule? module = ZagModule.fromKey(moduleKey);

      // Check module-specific toast settings
      if (!_shouldShowToast(moduleKey, eventType)) return;

      // Show a cleaner toast notification
      showZagInfoSnackBar(
        title: message.notification?.title ?? 'Notification',
        message: message.notification?.body ?? 'New activity in your library',
        showButton: module != null,
        buttonText: 'View',
        buttonOnPressed: module != null
            ? () async => _handleWebhook(message)
            : null,
      );
    });
  }

  /// Check if toast should be shown based on module and event type settings
  bool _shouldShowToast(String? moduleKey, String? eventType) {
    if (moduleKey == null || eventType == null) return true; // Show unknown notifications

    switch (moduleKey) {
      case 'radarr':
        if (!ZagreusDatabase.RADARR_TOAST_ENABLED.read()) return false;
        return _checkRadarrToastEvent(eventType);
      case 'sonarr':
        if (!ZagreusDatabase.SONARR_TOAST_ENABLED.read()) return false;
        return _checkSonarrToastEvent(eventType);
      case 'lidarr':
        if (!ZagreusDatabase.LIDARR_TOAST_ENABLED.read()) return false;
        return _checkLidarrToastEvent(eventType);
      case 'prowlarr':
        if (!ZagreusDatabase.PROWLARR_TOAST_ENABLED.read()) return false;
        return _checkProwlarrToastEvent(eventType);
      default:
        return true; // Show toasts for modules without specific settings
    }
  }

  bool _checkRadarrToastEvent(String eventType) {
    switch (eventType) {
      case 'Grab':
        return ZagreusDatabase.RADARR_TOAST_ON_GRAB.read();
      case 'Download':
        return ZagreusDatabase.RADARR_TOAST_ON_DOWNLOAD.read();
      case 'Upgrade':
        return ZagreusDatabase.RADARR_TOAST_ON_UPGRADE.read();
      case 'MovieAdded':
        return ZagreusDatabase.RADARR_TOAST_ON_MOVIE_ADDED.read();
      case 'ManualInteractionRequired':
        return ZagreusDatabase.RADARR_TOAST_ON_MANUAL_INTERACTION.read();
      default:
        return true;
    }
  }

  bool _checkSonarrToastEvent(String eventType) {
    switch (eventType) {
      case 'Grab':
        return ZagreusDatabase.SONARR_TOAST_ON_GRAB.read();
      case 'Download':
        return ZagreusDatabase.SONARR_TOAST_ON_DOWNLOAD.read();
      case 'Upgrade':
        return ZagreusDatabase.SONARR_TOAST_ON_UPGRADE.read();
      case 'SeriesAdd':
        return ZagreusDatabase.SONARR_TOAST_ON_SERIES_ADD.read();
      case 'ManualInteractionRequired':
        return ZagreusDatabase.SONARR_TOAST_ON_MANUAL_INTERACTION.read();
      default:
        return true;
    }
  }

  bool _checkLidarrToastEvent(String eventType) {
    switch (eventType) {
      case 'Grab':
        return ZagreusDatabase.LIDARR_TOAST_ON_GRAB.read();
      case 'Download':
        return ZagreusDatabase.LIDARR_TOAST_ON_DOWNLOAD.read();
      case 'Upgrade':
        return ZagreusDatabase.LIDARR_TOAST_ON_UPGRADE.read();
      case 'ArtistAdded':
        return ZagreusDatabase.LIDARR_TOAST_ON_ARTIST_ADD.read();
      default:
        return true;
    }
  }

  bool _checkProwlarrToastEvent(String eventType) {
    switch (eventType) {
      case 'Grab':
        return ZagreusDatabase.PROWLARR_TOAST_ON_GRAB.read();
      case 'HealthIssue':
        return ZagreusDatabase.PROWLARR_TOAST_ON_HEALTH_ISSUE.read();
      case 'HealthRestored':
        return ZagreusDatabase.PROWLARR_TOAST_ON_HEALTH_RESTORED.read();
      case 'ApplicationUpdate':
        return ZagreusDatabase.PROWLARR_TOAST_ON_APPLICATION_UPDATE.read();
      default:
        return true;
    }
  }

  /// Returns a [StreamSubscription] that will handle messages/notifications that are opened while Zagreus is running in the background.
  ///
  /// This listens on the message stream where the application must be open but in the background.
  StreamSubscription<RemoteMessage> registerOnMessageOpenedAppListener() =>
      onMessageOpenedApp.listen(_handleWebhook);

  /// Check to see if there was an initial [RemoteMessage] available to be accessed.
  ///
  /// If so, handles the notification webhook.
  Future<void> checkAndHandleInitialMessage() async {
    // TODO: Implement check for initial message from APNS
    // This would typically check if the app was launched from a notification
  }

  /// Shared webhook handler.
  Future<void> _handleWebhook(RemoteMessage? message) async {
    if (message == null || message.data.isEmpty) return;
    // Extract module
    ZagModule? module = ZagModule.fromKey(message.data['module']);
    if (module == null) {
      ZagLogger().warning(
        'Unknown module found inside of RemoteMessage: ${message.data['module'] ?? 'null'}',
      );
      return;
    }
    String profile = message.data['profile'] ?? '';
    if (profile.isEmpty) {
      ZagLogger().warning(
        'Invalid profile received in webhook: ${message.data['profile'] ?? 'null'}',
      );
      return;
    }
    bool result = ZagProfileTools().changeTo(profile, popToRootRoute: true);
    if (result) {
      module.handleWebhook(message.data);
    } else {
      showZagErrorSnackBar(
        title: 'Unknown Profile',
        message: '"$profile" does not exist in Zagreus',
      );
    }
  }

  /// Simulate receiving a message (for testing purposes)
  void simulateMessage(RemoteMessage message) {
    _messageController.add(message);
  }

  /// Store webhook credentials for use by webhook managers
  Future<void> _storeWebhookCredentials(String webhookId, String signature) async {
    // Store in database for webhook managers to use
    ZagreusDatabase.NOTIFICATION_WEBHOOK_ID.update(webhookId);
    ZagreusDatabase.NOTIFICATION_WEBHOOK_SIGNATURE.update(signature);

    // Also update webhook managers directly if needed
    RadarrWebhookManager.storeWebhookId(webhookId);
    RadarrWebhookManager.storeWebhookSignature(signature);
    SonarrWebhookManager.storeWebhookId(webhookId);
    SonarrWebhookManager.storeWebhookSignature(signature);
  }
}

/// Authorization status enum to match Firebase's API
enum AuthorizationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
}

/// RemoteMessage class to match Firebase's API
class RemoteMessage {
  final RemoteNotification? notification;
  final Map<String, dynamic> data;
  
  RemoteMessage({this.notification, required this.data});
}

/// RemoteNotification class to match Firebase's API
class RemoteNotification {
  final String? title;
  final String? body;
  
  RemoteNotification({this.title, this.body});
}