import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/database.dart';
import 'package:zagreus/api/radarr/radarr.dart';
import 'package:zagreus/api/sonarr/sonarr.dart';
import 'package:zagreus/modules/radarr/core/webhook_manager.dart';
import 'package:zagreus/modules/sonarr/core/webhook_manager.dart';
import 'package:zagreus/modules/lidarr/core/webhook_manager.dart';
import 'package:zagreus/system/webhooks.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String _lidarrStatus = '';
  bool _notificationsAuthorized = false;

  @override
  void initState() {
    super.initState();
    // Only sync webhooks if notifications are enabled
    if (ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.read()) {
      _syncWebhooksInBackground();
    }
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
          _lidarrStatus = 'Not configured';
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
          _lidarrStatus = 'Sign in or enable Single Device Mode';
        });
        return;
      }

      ZagLogger().debug('=== WEBHOOK SYNC TRIGGERED (Notifications Page) ===');

      // Sync Radarr if configured
      final radarrHost = profile.effectiveRadarrHost();
      if (profile.radarrEnabled &&
          radarrHost.isNotEmpty &&
          profile.radarrKey.isNotEmpty) {
        setState(() {
          _radarrStatus = 'Syncing...';
        });

        try {
          final api = RadarrAPI(
            host: radarrHost,
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
      final sonarrHost = profile.effectiveSonarrHost();
      if (profile.sonarrEnabled &&
          sonarrHost.isNotEmpty &&
          profile.sonarrKey.isNotEmpty) {
        setState(() {
          _sonarrStatus = 'Syncing...';
        });

        try {
          final api = SonarrAPI(
            host: sonarrHost,
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

      // Sync Lidarr if configured
      final lidarrHost = profile.effectiveLidarrHost();
      if (profile.lidarrEnabled &&
          lidarrHost.isNotEmpty &&
          profile.lidarrKey.isNotEmpty) {
        setState(() {
          _lidarrStatus = 'Syncing...';
        });

        try {
          final client = Dio(
            BaseOptions(
              baseUrl: lidarrHost.endsWith('/')
                  ? '${lidarrHost}api/v1/'
                  : '$lidarrHost/api/v1/',
              queryParameters: {
                'apikey': profile.lidarrKey,
              },
              headers: Map<String, dynamic>.from(profile.lidarrHeaders),
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
              followRedirects: true,
              maxRedirects: 5,
            ),
          );
          final success = await LidarrWebhookManager.syncWebhook(client);
          setState(() {
            _lidarrStatus = 'SUCCESS';
          });
        } catch (e) {
          setState(() {
            // Extract just the error message without the stack trace
            String errorMsg = e.toString();
            if (errorMsg.startsWith('Exception: ')) {
              errorMsg = errorMsg.substring(11);
            }
            _lidarrStatus = 'FAILED: $errorMsg';
          });
        }
      } else {
        setState(() {
          _lidarrStatus = 'Not configured';
        });
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to sync notification webhooks', e, stack);
      if (!mounted) return;
      setState(() {
        if (_radarrStatus.isEmpty) _radarrStatus = 'Error syncing webhooks';
        if (_sonarrStatus.isEmpty) _sonarrStatus = 'Error syncing webhooks';
        if (_lidarrStatus.isEmpty) _lidarrStatus = 'Error syncing webhooks';
      });
    }
  }

  void _removeWebhooksInBackground() async {
    try {
      final profileName = ZagreusDatabase.ENABLED_PROFILE.read();
      final profile = ZagBox.profiles.read(profileName);

      if (profile == null) {
        return;
      }

      ZagLogger().debug('=== REMOVING WEBHOOKS (Notifications Disabled) ===');

      // Remove Radarr webhook if configured
      if (profile.radarrEnabled &&
          profile.radarrHost.isNotEmpty &&
          profile.radarrKey.isNotEmpty) {
        setState(() {
          _radarrStatus = 'Removing webhook...';
        });

        try {
          final api = RadarrAPI(
            host: profile.radarrHost,
            apiKey: profile.radarrKey,
            headers: Map<String, dynamic>.from(profile.radarrHeaders),
          );
          await RadarrWebhookManager.removeWebhook(api);
          setState(() {
            _radarrStatus = 'Webhook removed';
          });
        } catch (e) {
          setState(() {
            _radarrStatus = 'Failed to remove webhook';
          });
        }
      }

      // Remove Sonarr webhook if configured
      if (profile.sonarrEnabled &&
          profile.sonarrHost.isNotEmpty &&
          profile.sonarrKey.isNotEmpty) {
        setState(() {
          _sonarrStatus = 'Removing webhook...';
        });

        try {
          final api = SonarrAPI(
            host: profile.sonarrHost,
            apiKey: profile.sonarrKey,
            headers: Map<String, dynamic>.from(profile.sonarrHeaders),
          );
          await SonarrWebhookManager.removeWebhook(api);
          setState(() {
            _sonarrStatus = 'Webhook removed';
          });
        } catch (e) {
          setState(() {
            _sonarrStatus = 'Failed to remove webhook';
          });
        }
      }

      // Remove Lidarr webhook if configured
      if (profile.lidarrEnabled &&
          profile.lidarrHost.isNotEmpty &&
          profile.lidarrKey.isNotEmpty) {
        setState(() {
          _lidarrStatus = 'Removing webhook...';
        });

        try {
          final client = Dio(
            BaseOptions(
              baseUrl: profile.lidarrHost.endsWith('/')
                  ? '${profile.lidarrHost}api/v1/'
                  : '${profile.lidarrHost}/api/v1/',
              queryParameters: {
                'apikey': profile.lidarrKey,
              },
              headers: Map<String, dynamic>.from(profile.lidarrHeaders),
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
              followRedirects: true,
              maxRedirects: 5,
            ),
          );
          await LidarrWebhookManager.removeWebhook(client);
          setState(() {
            _lidarrStatus = 'Webhook removed';
          });
        } catch (e) {
          setState(() {
            _lidarrStatus = 'Failed to remove webhook';
          });
        }
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to remove webhooks', e, stack);
    }
  }

  Future<bool> _registerDeviceTokenIfNeeded() async {
    try {
      final isAnonymous = ZagreusDatabase.NOTIFICATION_ANONYMOUS_MODE.read();

      if (!isAnonymous) {
        // For synced mode, check if user is authenticated
        final user = ZagSupabase.client.auth.currentUser;
        if (user == null) {
          ZagLogger()
              .warning('No authenticated user, cannot register device token');
          return false;
        }
        ZagLogger().debug(
            'User authenticated, registering device token for user: ${user.id}');
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

            return GestureDetector(
              onTap: () async {
                if (Platform.isIOS) {
                  final uri = Uri.parse('app-settings:');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                }
              },
              child: ZagBanner(
                headerText: 'settings.NotAuthorized'.tr(),
                bodyText: 'settings.NotAuthorizedMessage'.tr(),
                icon: Icons.error_outline_rounded,
                iconColor: ZagColours.red,
              ),
            );
          },
        ),
        _enableNotifications(),
        _enableInAppToasts(),
        _multiDeviceSyncToggle(),
        ZagDivider(),
        _statusBlock('Radarr Status', _radarrStatus),
        _statusBlock('Sonarr Status', _sonarrStatus),
        _statusBlock('Lidarr Status', _lidarrStatus),
        ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.listenableBuilder(
          builder: (context, _) {
            if (!ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.read()) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                ZagDivider(),
                _radarrEventsButton(),
                _sonarrEventsButton(),
                _lidarrEventsButton(),
              ],
            );
          },
        ),
        ZagDivider(),
        _seerrWebhookSection(),
        ZagDivider(),
        _tautulliWebhookSection(),
      ],
    );
  }

  Widget _statusBlock(String title, String status) {
    final isSuccess = status == 'SUCCESS';
    final isFailed = status.startsWith('FAILED:');
    final errorMessage = isFailed ? status.substring(8).trim() : '';

    return ZagBlock(
      title: title,
      body: [],
      trailing: status.isEmpty
          ? Icon(
              Icons.remove_circle_outline,
              color: ZagColours.grey,
              size: 24,
            )
          : isSuccess
              ? Icon(
                  Icons.check_circle,
                  color: ZagColours.accentColor(context),
                  size: 24,
                )
              : isFailed
                  ? GestureDetector(
                      onTap: () => _showErrorDialog(title, errorMessage),
                      child: Icon(
                        Icons.error,
                        color: ZagColours.red,
                        size: 24,
                      ),
                    )
                  : Icon(
                      Icons.hourglass_empty,
                      color: ZagColours.grey,
                      size: 24,
                    ),
    );
  }

  void _showErrorDialog(String title, String errorMessage) {
    ZagDialog.dialog(
      context: context,
      title: '$title Error',
      content: [
        ZagDialog.textContent(
          text: errorMessage,
          textAlign: TextAlign.left,
        ),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
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
              // When disabling notifications, remove webhooks
              _removeWebhooksInBackground();
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
          value: !db
              .read(), // Inverted - when anonymous mode is OFF, multi-device is ON
          onChanged: !isSignedIn
              ? null // Disabled when not signed in
              : (value) async {
                  // value = true means user wants multi-device (so anonymous = false)
                  // value = false means user wants single device (so anonymous = true)
                  final newAnonymousMode = !value;

                  // Show confirmation dialog
                  bool confirmed = false;
                  await ZagDialog.dialog(
                    context: context,
                    title: value
                        ? 'Enable Multi-Device Sync?'
                        : 'Disable Multi-Device Sync?',
                    content: [
                      ZagDialog.textContent(
                        text: value
                            ? 'Notifications will sync across all devices with this account.'
                            : 'Notifications will only work on this device.',
                      ),
                    ],
                    contentPadding: ZagDialog.textDialogContentPadding(),
                    buttons: [
                      ZagDialog.button(
                        text: 'Continue',
                        textColor: ZagColours.accentColor(context),
                        onPressed: () {
                          confirmed = true;
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
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

  Widget _enableInAppToasts() {
    const db = ZagreusDatabase.ENABLE_IN_APP_TOASTS;

    return ZagBlock(
      title: 'Enable In-App Toasts',
      body: [TextSpan(text: 'Show toast notifications in-app')],
      trailing: ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.listenableBuilder(
        builder: (context, _) {
          final notificationsEnabled =
              ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.read();
          return db.listenableBuilder(
            builder: (context, _) => ZagSwitch(
              value: db.read(),
              onChanged: notificationsEnabled
                  ? (value) {
                      db.update(value);
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _radarrEventsButton() {
    return ZagBlock(
      title: 'Radarr Events',
      body: [TextSpan(text: 'Configure push and toast notification events')],
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: ZagColours.grey,
      ),
      onTap: () => _showCombinedEventsPage(
        title: 'Radarr Events',
        pushEvents: [
          _EventConfig('On Grab', ZagreusDatabase.RADARR_WEBHOOK_ON_GRAB),
          _EventConfig('On Import', ZagreusDatabase.RADARR_WEBHOOK_ON_DOWNLOAD),
          _EventConfig('On Upgrade', ZagreusDatabase.RADARR_WEBHOOK_ON_UPGRADE),
          _EventConfig('On Add', ZagreusDatabase.RADARR_WEBHOOK_ON_MOVIE_ADDED),
          _EventConfig('On Manual Interaction', ZagreusDatabase.RADARR_WEBHOOK_ON_MANUAL_INTERACTION),
        ],
        toastEvents: [
          _EventConfig('On Grab', ZagreusDatabase.RADARR_TOAST_ON_GRAB),
          _EventConfig('On Import', ZagreusDatabase.RADARR_TOAST_ON_DOWNLOAD),
          _EventConfig('On Upgrade', ZagreusDatabase.RADARR_TOAST_ON_UPGRADE),
          _EventConfig('On Add', ZagreusDatabase.RADARR_TOAST_ON_MOVIE_ADDED),
          _EventConfig('On Manual Interaction', ZagreusDatabase.RADARR_TOAST_ON_MANUAL_INTERACTION),
        ],
      ),
    );
  }

  Widget _sonarrEventsButton() {
    return ZagBlock(
      title: 'Sonarr Events',
      body: [TextSpan(text: 'Configure push and toast notification events')],
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: ZagColours.grey,
      ),
      onTap: () => _showCombinedEventsPage(
        title: 'Sonarr Events',
        pushEvents: [
          _EventConfig('On Grab', ZagreusDatabase.SONARR_WEBHOOK_ON_GRAB),
          _EventConfig('On Import', ZagreusDatabase.SONARR_WEBHOOK_ON_DOWNLOAD),
          _EventConfig('On Upgrade', ZagreusDatabase.SONARR_WEBHOOK_ON_UPGRADE),
          _EventConfig('On Series Added', ZagreusDatabase.SONARR_WEBHOOK_ON_SERIES_ADD),
          _EventConfig('On Manual Interaction', ZagreusDatabase.SONARR_WEBHOOK_ON_MANUAL_INTERACTION),
        ],
        toastEvents: [
          _EventConfig('On Grab', ZagreusDatabase.SONARR_TOAST_ON_GRAB),
          _EventConfig('On Import', ZagreusDatabase.SONARR_TOAST_ON_DOWNLOAD),
          _EventConfig('On Upgrade', ZagreusDatabase.SONARR_TOAST_ON_UPGRADE),
          _EventConfig('On Series Added', ZagreusDatabase.SONARR_TOAST_ON_SERIES_ADD),
          _EventConfig('On Manual Interaction', ZagreusDatabase.SONARR_TOAST_ON_MANUAL_INTERACTION),
        ],
      ),
    );
  }

  Widget _lidarrEventsButton() {
    return ZagBlock(
      title: 'Lidarr Events',
      body: [TextSpan(text: 'Configure push and toast notification events')],
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: ZagColours.grey,
      ),
      onTap: () => _showCombinedEventsPage(
        title: 'Lidarr Events',
        pushEvents: [
          _EventConfig('On Grab', ZagreusDatabase.LIDARR_WEBHOOK_ON_GRAB),
          _EventConfig('On Import', ZagreusDatabase.LIDARR_WEBHOOK_ON_DOWNLOAD),
          _EventConfig('On Upgrade', ZagreusDatabase.LIDARR_WEBHOOK_ON_UPGRADE),
          _EventConfig('On Artist Added', ZagreusDatabase.LIDARR_WEBHOOK_ON_ARTIST_ADD),
        ],
        toastEvents: [
          _EventConfig('On Grab', ZagreusDatabase.LIDARR_TOAST_ON_GRAB),
          _EventConfig('On Import', ZagreusDatabase.LIDARR_TOAST_ON_DOWNLOAD),
          _EventConfig('On Upgrade', ZagreusDatabase.LIDARR_TOAST_ON_UPGRADE),
          _EventConfig('On Artist Added', ZagreusDatabase.LIDARR_TOAST_ON_ARTIST_ADD),
        ],
      ),
    );
  }

  void _showCombinedEventsPage({
    required String title,
    required List<_EventConfig> pushEvents,
    required List<_EventConfig> toastEvents,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _CombinedEventsPage(
          title: title,
          pushEvents: pushEvents,
          toastEvents: toastEvents,
          onSync: _syncWebhooksInBackground,
        ),
      ),
    );
  }

  Widget _seerrWebhookSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(ZagUI.DEFAULT_MARGIN_SIZE),
          child: Text(
            'Seerr Webhook URL',
            style: TextStyle(
              fontSize: ZagUI.FONT_SIZE_H2,
              fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            ),
          ),
        ),
        ZagBlock(
          title: 'Enable Seerr Notifications',
          body: [],
          trailing: ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.listenableBuilder(
            builder: (context, _) {
              final notificationsEnabled =
                  ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.read();
              return ZagreusDatabase.SEERR_NOTIFICATIONS_ENABLED.listenableBuilder(
                builder: (context, _) => ZagSwitch(
                  value: ZagreusDatabase.SEERR_NOTIFICATIONS_ENABLED.read(),
                  onChanged: notificationsEnabled
                      ? (value) async {
                          // Update local preference first
                          ZagreusDatabase.SEERR_NOTIFICATIONS_ENABLED.update(value);

                          // Update backend preference
                          try {
                            final webhookID = ZagreusDatabase.NOTIFICATION_WEBHOOK_ID.read();
                            if (webhookID.isEmpty) {
                              ZagLogger().warning('No webhook ID found, skipping backend update');
                              return;
                            }

                            final response = await http.post(
                              Uri.parse('https://zagreus-notifications.fly.dev/v1/preferences/seerr'),
                              headers: {'Content-Type': 'application/json'},
                              body: json.encode({
                                'webhook_id': webhookID,
                                'enabled': value,
                              }),
                            );

                            if (response.statusCode == 200) {
                              ZagLogger().debug('Seerr preference updated: enabled=$value');
                            } else {
                              ZagLogger().warning('Failed to update Seerr preference: ${response.statusCode}');
                            }
                          } catch (e, stackTrace) {
                            ZagLogger().error('Failed to update Seerr preference', e, stackTrace);
                          }
                        }
                      : null,
                ),
              );
            },
          ),
        ),
        ZagBlock(
          title: 'Copy Webhook URL',
          body: [
            TextSpan(
              text: 'Paste into Seerr webhook settings',
            ),
          ],
          trailing: Icon(
            Icons.copy_rounded,
            color: ZagColours.accentColor(context),
          ),
          onTap: () async {
            try {
              // Get or create webhook ID (same system as Radarr/Sonarr)
              final deviceToken = await ZagSupabaseMessaging.instance.getToken();
              if (deviceToken == null) {
                showZagErrorSnackBar(
                  title: 'Error',
                  message: 'Device token not available',
                );
                return;
              }

              // Check if we're in anonymous mode
              final isAnonymous = ZagreusDatabase.NOTIFICATION_ANONYMOUS_MODE.read();
              final user = ZagSupabase.client.auth.currentUser;
              final userID = (!isAnonymous && user != null) ? user.id : null;

              // Call backend to get/create webhook ID
              final response = await http.post(
                Uri.parse('https://zagreus-notifications.fly.dev/v1/auth/register'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'user_id': userID,
                  'device_token': deviceToken,
                  'device_type': 'ios',
                  'anonymous': isAnonymous,
                }),
              );

              if (response.statusCode == 200) {
                final data = json.decode(response.body);
                final webhookID = data['webhook_id'] as String?;

                if (webhookID == null) {
                  throw Exception('No webhook ID returned');
                }

                final webhookUrl = 'https://zagreus-notifications.fly.dev/v1/seerr/webhook/$webhookID';
                await Clipboard.setData(ClipboardData(text: webhookUrl));
                showZagInfoSnackBar(
                  title: 'Copied',
                  message: 'Webhook URL copied to clipboard',
                );
              } else {
                throw Exception('Failed to get webhook ID: ${response.statusCode}');
              }
            } catch (e, stackTrace) {
              ZagLogger().error('Failed to copy Seerr webhook URL', e, stackTrace);
              showZagErrorSnackBar(
                title: 'Error',
                message: 'Failed to generate webhook URL',
              );
            }
          },
        ),
      ],
    );
  }

  Widget _tautulliWebhookSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(ZagUI.DEFAULT_MARGIN_SIZE),
          child: Text(
            'Tautulli Webhook URL',
            style: TextStyle(
              fontSize: ZagUI.FONT_SIZE_H2,
              fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            ),
          ),
        ),
        ZagBlock(
          title: 'Enable Tautulli Notifications',
          body: [],
          trailing: ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.listenableBuilder(
            builder: (context, _) {
              final notificationsEnabled =
                  ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS.read();
              return ZagreusDatabase.TAUTULLI_NOTIFICATIONS_ENABLED.listenableBuilder(
                builder: (context, _) => ZagSwitch(
                  value: ZagreusDatabase.TAUTULLI_NOTIFICATIONS_ENABLED.read(),
                  onChanged: notificationsEnabled
                      ? (value) async {
                          // Update local preference first
                          ZagreusDatabase.TAUTULLI_NOTIFICATIONS_ENABLED.update(value);

                          // Update backend preference
                          try {
                            final webhookID = ZagreusDatabase.NOTIFICATION_WEBHOOK_ID.read();
                            if (webhookID.isEmpty) {
                              ZagLogger().warning('No webhook ID found, skipping backend update');
                              return;
                            }

                            final response = await http.post(
                              Uri.parse('https://zagreus-notifications.fly.dev/v1/preferences/tautulli'),
                              headers: {'Content-Type': 'application/json'},
                              body: json.encode({
                                'webhook_id': webhookID,
                                'enabled': value,
                              }),
                            );

                            if (response.statusCode == 200) {
                              ZagLogger().debug('Tautulli preference updated: enabled=$value');
                            } else {
                              ZagLogger().warning('Failed to update Tautulli preference: ${response.statusCode}');
                            }
                          } catch (e, stackTrace) {
                            ZagLogger().error('Failed to update Tautulli preference', e, stackTrace);
                          }
                        }
                      : null,
                ),
              );
            },
          ),
        ),
        ZagBlock(
          title: 'Copy Webhook URL',
          body: [
            TextSpan(
              text: 'Paste into Tautulli notification agent settings',
            ),
          ],
          trailing: Icon(
            Icons.copy_rounded,
            color: ZagColours.accentColor(context),
          ),
          onTap: () async {
            try {
              // Get or create webhook ID (same system as other services)
              final deviceToken = await ZagSupabaseMessaging.instance.getToken();
              if (deviceToken == null) {
                showZagErrorSnackBar(
                  title: 'Error',
                  message: 'Device token not available',
                );
                return;
              }

              // Check if we're in anonymous mode
              final isAnonymous = ZagreusDatabase.NOTIFICATION_ANONYMOUS_MODE.read();
              final user = ZagSupabase.client.auth.currentUser;
              final userID = (!isAnonymous && user != null) ? user.id : null;

              // Call backend to get/create webhook ID
              final response = await http.post(
                Uri.parse('https://zagreus-notifications.fly.dev/v1/auth/register'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'user_id': userID,
                  'device_token': deviceToken,
                  'device_type': 'ios',
                  'anonymous': isAnonymous,
                }),
              );

              if (response.statusCode == 200) {
                final data = json.decode(response.body);
                final webhookID = data['webhook_id'] as String?;

                if (webhookID == null) {
                  throw Exception('No webhook ID returned');
                }

                final webhookUrl = 'https://zagreus-notifications.fly.dev/v1/tautulli/webhook/$webhookID';
                await Clipboard.setData(ClipboardData(text: webhookUrl));
                showZagInfoSnackBar(
                  title: 'Copied',
                  message: 'Webhook URL copied to clipboard',
                );
              } else {
                throw Exception('Failed to get webhook ID: ${response.statusCode}');
              }
            } catch (e, stackTrace) {
              ZagLogger().error('Failed to copy Tautulli webhook URL', e, stackTrace);
              showZagErrorSnackBar(
                title: 'Error',
                message: 'Failed to generate webhook URL',
              );
            }
          },
        ),
      ],
    );
  }
}

/// Helper class to hold event configuration data
class _EventConfig {
  final String title;
  final ZagreusDatabase<bool> database;

  _EventConfig(this.title, this.database);
}

/// Combined events page showing both push and toast events with headers
class _CombinedEventsPage extends StatefulWidget {
  final String title;
  final List<_EventConfig> pushEvents;
  final List<_EventConfig> toastEvents;
  final VoidCallback? onSync;

  const _CombinedEventsPage({
    required this.title,
    required this.pushEvents,
    required this.toastEvents,
    this.onSync,
  });

  @override
  State<_CombinedEventsPage> createState() => _CombinedEventsPageState();
}

class _CombinedEventsPageState extends State<_CombinedEventsPage> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: ZagAppBar(
        title: widget.title,
        scrollControllers: [scrollController],
      ),
      body: ZagListView(
        controller: scrollController,
        children: [
          // Push Notifications Section
          _buildSectionHeader('Push Notifications'),
          for (final event in widget.pushEvents)
            _buildPushEventToggle(context, event),
          
          // In-App Toasts Section
          ZagDivider(),
          _buildSectionHeader('In-App Toasts'),
          for (final event in widget.toastEvents)
            _buildToastEventToggle(context, event),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.all(ZagUI.DEFAULT_MARGIN_SIZE),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ZagUI.FONT_SIZE_H2,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      ),
    );
  }

  Widget _buildPushEventToggle(BuildContext context, _EventConfig event) {
    return ZagBlock(
      title: event.title,
      body: [],
      trailing: event.database.listenableBuilder(
        builder: (context, _) => ZagSwitch(
          value: event.database.read(),
          onChanged: (value) async {
            event.database.update(value);
            // Trigger webhook sync after changing push notification settings
            if (widget.onSync != null) {
              widget.onSync!();
            }
          },
        ),
      ),
    );
  }

  Widget _buildToastEventToggle(BuildContext context, _EventConfig event) {
    return ZagBlock(
      title: event.title,
      body: [],
      trailing: ZagreusDatabase.ENABLE_IN_APP_TOASTS.listenableBuilder(
        builder: (context, _) {
          final toastsEnabled = ZagreusDatabase.ENABLE_IN_APP_TOASTS.read();
          return event.database.listenableBuilder(
            builder: (context, _) => ZagSwitch(
              value: event.database.read(),
              onChanged: toastsEnabled
                  ? (value) {
                      event.database.update(value);
                    }
                  : null, // Disabled when toasts are off
            ),
          );
        },
      ),
    );
  }
}
