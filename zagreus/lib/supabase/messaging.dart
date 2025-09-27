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
          // Automatically register with server when we get a new token
          await _registerDeviceWithServer(token, anonymous: false);
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
      if (!ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.read()) return;

      ZagModule? module = ZagModule.fromKey(message.data['module']);
      showZagSnackBar(
        title: message.notification?.title ?? 'Unknown Content',
        message: message.notification?.body ?? ZagUI.TEXT_EMDASH,
        type: ZagSnackbarType.INFO,
        position: FlashPosition.top,
        duration: const Duration(seconds: 6, milliseconds: 750),
        showButton: module != null,
        buttonOnPressed: () async => _handleWebhook(message),
      );
    });
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