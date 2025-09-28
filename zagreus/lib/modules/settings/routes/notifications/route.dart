import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/database.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/modules/radarr/core/webhook_manager.dart';
import 'package:zagreus/modules/sonarr/core/webhook_manager.dart';

class NotificationsRoute extends StatefulWidget {
  const NotificationsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<NotificationsRoute> createState() => _State();
}

class _State extends State<NotificationsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _radarrStatus = '';
  String _sonarrStatus = '';
  bool _notificationsAuthorized = false;

  @override
  void initState() {
    super.initState();
    _syncWebhooksInBackground();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final authorized =
        await ZagSupabaseMessaging.instance.areNotificationsAllowed();
    if (mounted) {
      setState(() {
        _notificationsAuthorized = authorized;
      });
    }
  }

  void _syncWebhooksInBackground() async {
    try {
      final profileName = ZagreusDatabase.ENABLED_PROFILE.read();
      final profile = ZagBox.profiles.read(profileName);

      if (profile == null) {
        setState(() {
          _radarrStatus = 'Not configured';
          _sonarrStatus = 'Not configured';
        });
        return;
      }

      final user = ZagSupabase.client.auth.currentUser;
      final isAnonymous = ZagreusDatabase.NOTIFICATION_ANONYMOUS_MODE.read();

      // Check if we have a valid auth method
      if (!isAnonymous && (!ZagSupabase.isSupported || user == null)) {
        setState(() {
          _radarrStatus = 'Sign in or enable Single Device Mode';
          _sonarrStatus = 'Sign in or enable Single Device Mode';
        });
        return;
      }

      ZagLogger().debug('=== WEBHOOK SYNC TRIGGERED (Notifications Page) ===');

      // Sync Radarr if configured
      if (profile.radarrEnabled &&
          profile.radarrHost.isNotEmpty &&
          profile.radarrKey.isNotEmpty) {
        setState(() {
          _radarrStatus = 'Syncing...';
        });

        try {
          final api = RadarrAPI(
            host: profile.radarrHost,
            apiKey: profile.radarrKey,
            headers: Map<String, dynamic>.from(profile.radarrHeaders),
          );
          final success = await RadarrWebhookManager.syncWebhook(api);
          setState(() {
            _radarrStatus = 'SUCCESS';
          });
        } catch (e) {
          setState(() {
            // Extract just the error message without the stack trace
            String errorMsg = e.toString();
            if (errorMsg.startsWith('Exception: ')) {
              errorMsg = errorMsg.substring(11);
            }
            _radarrStatus = 'FAILED: $errorMsg';
          });
        }
      } else {
        setState(() {
          _radarrStatus = 'Not configured';
        });
      }

      // Sync Sonarr if configured
      if (profile.sonarrEnabled &&
          profile.sonarrHost.isNotEmpty &&
          profile.sonarrKey.isNotEmpty) {
        setState(() {
          _sonarrStatus = 'Syncing...';
        });

        try {
          final api = SonarrAPI(
            host: profile.sonarrHost,
            apiKey: profile.sonarrKey,
            headers: Map<String, dynamic>.from(profile.sonarrHeaders),
          );
          final success = await SonarrWebhookManager.syncWebhook(api);
          setState(() {
            _sonarrStatus = 'SUCCESS';
          });
        } catch (e) {
          setState(() {
            // Extract just the error message without the stack trace
            String errorMsg = e.toString();
            if (errorMsg.startsWith('Exception: ')) {
              errorMsg = errorMsg.substring(11);
            }
            _sonarrStatus = 'FAILED: $errorMsg';
          });
        }
      } else {
        setState(() {
          _sonarrStatus = 'Not configured';
        });
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to sync notification webhooks', e, stack);
      if (!mounted) return;
      setState(() {
        if (_radarrStatus.isEmpty) _radarrStatus = 'Error syncing webhooks';
        if (_sonarrStatus.isEmpty) _sonarrStatus = 'Error syncing webhooks';
      });
    }
  }

  Future<bool> _registerDeviceTokenIfNeeded() async {
    try {
      final isAnonymous = ZagreusDatabase.NOTIFICATION_ANONYMOUS_MODE.read();

      if (!isAnonymous) {
        // For synced mode, check if user is authenticated
        final user = ZagSupabase.client.auth.currentUser;
        if (user == null) {
          ZagLogger().warning('No authenticated user, cannot register device token');
          return false;
        }
        ZagLogger().debug('User authenticated, registering device token for user: ${user.id}');
      } else {
        ZagLogger().debug('Registering anonymous device token');
      }

      final success = await ZagSupabaseMessaging.instance
          .registerDeviceToken(anonymous: isAnonymous);
      ZagLogger().debug('Device token registration result: $success');
      return success;
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to register device token', e, stackTrace);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'settings.Notifications'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    final user = ZagSupabase.client.auth.currentUser;
    final isSignedIn = ZagSupabase.isSupported && user != null;

    return ZagListView(
      controller: scrollController,
      children: [
        ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.listenableBuilder(
          builder: (context, _) {
            // Only show banner if notifications are enabled but not authorized
            if (!ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.read() ||
                _notificationsAuthorized) {
              return const SizedBox(height: 0.0, width: double.infinity);
            }

            return ZagBanner(
              headerText: 'settings.NotAuthorized'.tr(),
              bodyText: 'settings.NotAuthorizedMessage'.tr(),
              icon: Icons.error_outline_rounded,
              iconColor: ZagColours.red,
            );
          },
        ),
        _enableNotifications(),
        _multiDeviceSyncToggle(),
        ZagDivider(),
        _statusBlock('Radarr Status', _radarrStatus),
        _statusBlock('Sonarr Status', _sonarrStatus),
      ],
    );
  }

  Widget _statusBlock(String title, String status) {
    final displayText = status.isEmpty ? 'Not checked' : status;
    return ZagBlock(
      title: title,
      body: [TextSpan(text: displayText)],
    );
  }

  Widget _enableNotifications() {
    const db = ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS;

    return ZagBlock(
      title: 'Enable Notifications',
      body: [TextSpan(text: 'Receive push notifications for media events')],
      trailing: db.listenableBuilder(
        builder: (context, _) => ZagSwitch(
          value: db.read(),
          onChanged: (value) async {
                  ZagLogger().debug('Notification toggle changed to: $value');

                  if (value) {
                    // Request notification permissions when enabling
                    ZagLogger().debug('Requesting notification permissions...');
                    bool granted = await ZagSupabaseMessaging.instance
                        .requestNotificationPermissions();
                    ZagLogger().debug('Permissions granted: $granted');

                    if (!granted) {
                      // If permissions denied, don't enable the toggle
                      showZagErrorSnackBar(
                        title: 'Permission Denied',
                        message: 'Please enable notifications in Settings',
                      );
                      return;
                    }

                    // Update authorization status
                    setState(() {
                      _notificationsAuthorized = true;
                    });
                  }

                  // Update the toggle immediately
                  db.update(value);

                  // Do the heavy work in the background AFTER updating UI
                  if (value) {
                    // Clear any cached token first
                    ZagSupabaseMessaging.instance.clearCachedToken();

                    // Register device token in background
                    Future.delayed(Duration.zero, () async {
                      try {
                        ZagLogger().debug('Attempting to register device token...');
                        final registered = await _registerDeviceTokenIfNeeded();
                        ZagLogger().debug('Device registration complete');

                        // Trigger webhook sync after registration
                        _syncWebhooksInBackground();
                      } catch (e) {
                        ZagLogger().error('Failed to register device', e, null);
                      }
                    });
                  } else {
                    // When disabling notifications, update webhook status
                    _syncWebhooksInBackground();
                  }
                },
        ),
      ),
    );
  }


  Widget _multiDeviceSyncToggle() {
    const db = ZagreusDatabase.NOTIFICATION_ANONYMOUS_MODE;
    final user = ZagSupabase.client.auth.currentUser;
    final isSignedIn = ZagSupabase.isSupported && user != null;

    return ZagBlock(
      title: 'Multi-Device Sync',
      body: [
        TextSpan(
          text: isSignedIn
              ? 'Sync notifications across all your devices'
              : 'Sign in to enable multi-device sync',
        ),
      ],
      trailing: db.listenableBuilder(
        builder: (context, _) => ZagSwitch(
          value: !db.read(), // Inverted - when anonymous mode is OFF, multi-device is ON
          onChanged: !isSignedIn
              ? null // Disabled when not signed in
              : (value) async {
                  // value = true means user wants multi-device (so anonymous = false)
                  // value = false means user wants single device (so anonymous = true)
                  final newAnonymousMode = !value;

                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(value
                          ? 'Enable Multi-Device Sync?'
                          : 'Disable Multi-Device Sync?'),
                      content: Text(
                        value
                            ? 'Notifications will sync across all devices with this account.'
                            : 'Notifications will only work on this device.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            'Continue',
                            style: TextStyle(color: ZagColours.accentLight),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    // Update the preference
                    db.update(newAnonymousMode);

                    // Clear cached token to force re-registration
                    ZagSupabaseMessaging.instance.clearCachedToken();

                    // Re-register with new mode
                    if (ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.read()) {
                      try {
                        final success = await ZagSupabaseMessaging.instance
                            .registerDeviceToken(anonymous: newAnonymousMode);

                        if (success) {
                          showZagSuccessSnackBar(
                            title: 'Success',
                            message: value
                                ? 'Switched to multi-device sync'
                                : 'Switched to single device mode',
                          );

                          // Refresh webhook sync
                          _syncWebhooksInBackground();
                        } else {
                          throw Exception('Registration failed');
                        }
                      } catch (e) {
                        // Revert on failure
                        db.update(!newAnonymousMode);
                        showZagErrorSnackBar(
                          title: 'Error',
                          message: 'Failed to update notification mode',
                        );
                      }
                    }
                  }
                },
        ),
      ),
    );
  }
}
