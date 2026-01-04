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
import 'package:zagreus/modules/prowlarr/core/webhook_manager.dart';
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

  _WebhookStatus _radarrStatus =
      const _WebhookStatus(_WebhookStatusType.idle);
  _WebhookStatus _sonarrStatus =
      const _WebhookStatus(_WebhookStatusType.idle);
  _WebhookStatus _lidarrStatus =
      const _WebhookStatus(_WebhookStatusType.idle);
  _WebhookStatus _prowlarrStatus =
      const _WebhookStatus(_WebhookStatusType.idle);
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
          _radarrStatus = const _WebhookStatus(
            _WebhookStatusType.notConfigured,
          );
          _sonarrStatus = const _WebhookStatus(
            _WebhookStatusType.notConfigured,
          );
          _lidarrStatus = const _WebhookStatus(
            _WebhookStatusType.notConfigured,
          );
          _prowlarrStatus = const _WebhookStatus(
            _WebhookStatusType.notConfigured,
          );
        });
        return;
      }

      final user = ZagSupabase.client.auth.currentUser;
      final isAnonymous = ZagreusDatabase.NOTIFICATION_ANONYMOUS_MODE.read();

      // Check if we have a valid auth method
      if (!isAnonymous && (!ZagSupabase.isSupported || user == null)) {
        setState(() {
          _radarrStatus = const _WebhookStatus(
            _WebhookStatusType.signInRequired,
          );
          _sonarrStatus = const _WebhookStatus(
            _WebhookStatusType.signInRequired,
          );
          _lidarrStatus = const _WebhookStatus(
            _WebhookStatusType.signInRequired,
          );
          _prowlarrStatus = const _WebhookStatus(
            _WebhookStatusType.signInRequired,
          );
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
          _radarrStatus = const _WebhookStatus(_WebhookStatusType.syncing);
        });

        try {
          final api = RadarrAPI(
            host: radarrHost,
            apiKey: profile.radarrKey,
            headers: Map<String, dynamic>.from(profile.radarrHeaders),
          );
          final success = await RadarrWebhookManager.syncWebhook(api);
          setState(() {
            _radarrStatus = const _WebhookStatus(_WebhookStatusType.success);
          });
        } catch (e) {
          setState(() {
            // Extract just the error message without the stack trace
            String errorMsg = e.toString();
            if (errorMsg.startsWith('Exception: ')) {
              errorMsg = errorMsg.substring(11);
            }
            _radarrStatus = _WebhookStatus(
              _WebhookStatusType.failed,
              message: errorMsg,
            );
          });
        }
      } else {
        setState(() {
          _radarrStatus = const _WebhookStatus(
            _WebhookStatusType.notConfigured,
          );
        });
      }

      // Sync Sonarr if configured
      final sonarrHost = profile.effectiveSonarrHost();
      if (profile.sonarrEnabled &&
          sonarrHost.isNotEmpty &&
          profile.sonarrKey.isNotEmpty) {
        setState(() {
          _sonarrStatus = const _WebhookStatus(_WebhookStatusType.syncing);
        });

        try {
          final api = SonarrAPI(
            host: sonarrHost,
            apiKey: profile.sonarrKey,
            headers: Map<String, dynamic>.from(profile.sonarrHeaders),
          );
          final success = await SonarrWebhookManager.syncWebhook(api);
          setState(() {
            _sonarrStatus = const _WebhookStatus(_WebhookStatusType.success);
          });
        } catch (e) {
          setState(() {
            // Extract just the error message without the stack trace
            String errorMsg = e.toString();
            if (errorMsg.startsWith('Exception: ')) {
              errorMsg = errorMsg.substring(11);
            }
            _sonarrStatus = _WebhookStatus(
              _WebhookStatusType.failed,
              message: errorMsg,
            );
          });
        }
      } else {
        setState(() {
          _sonarrStatus = const _WebhookStatus(
            _WebhookStatusType.notConfigured,
          );
        });
      }

      // Sync Lidarr if configured
      final lidarrHost = profile.effectiveLidarrHost();
      if (profile.lidarrEnabled &&
          lidarrHost.isNotEmpty &&
          profile.lidarrKey.isNotEmpty) {
        setState(() {
          _lidarrStatus = const _WebhookStatus(_WebhookStatusType.syncing);
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
            _lidarrStatus = const _WebhookStatus(_WebhookStatusType.success);
          });
        } catch (e) {
          setState(() {
            // Extract just the error message without the stack trace
            String errorMsg = e.toString();
            if (errorMsg.startsWith('Exception: ')) {
              errorMsg = errorMsg.substring(11);
            }
            _lidarrStatus = _WebhookStatus(
              _WebhookStatusType.failed,
              message: errorMsg,
            );
          });
        }
      } else {
        setState(() {
          _lidarrStatus = const _WebhookStatus(
            _WebhookStatusType.notConfigured,
          );
        });
      }

      // Sync Prowlarr if configured (stored in indexers, not profile)
      final prowlarrIndexers = ZagBox.indexers.data.where((i) => i.isProwlarr).toList();
      if (prowlarrIndexers.isNotEmpty) {
        setState(() {
          _prowlarrStatus = const _WebhookStatus(_WebhookStatusType.syncing);
        });

        try {
          // Sync the first Prowlarr instance (most users have just one)
          final indexer = prowlarrIndexers.first;
          final client = Dio(
            BaseOptions(
              baseUrl: indexer.host.endsWith('/')
                  ? '${indexer.host}api/v1/'
                  : '${indexer.host}/api/v1/',
              headers: {
                'X-Api-Key': indexer.apiKey,
                ...indexer.headers,
              },
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
              followRedirects: true,
              maxRedirects: 5,
            ),
          );
          final success = await ProwlarrWebhookManager.syncWebhook(client);
          setState(() {
            _prowlarrStatus = const _WebhookStatus(_WebhookStatusType.success);
          });
        } catch (e) {
          setState(() {
            String errorMsg = e.toString();
            if (errorMsg.startsWith('Exception: ')) {
              errorMsg = errorMsg.substring(11);
            }
            _prowlarrStatus = _WebhookStatus(
              _WebhookStatusType.failed,
              message: errorMsg,
            );
          });
        }
      } else {
        setState(() {
          _prowlarrStatus = const _WebhookStatus(
            _WebhookStatusType.notConfigured,
          );
        });
      }
    } catch (e, stack) {
      ZagLogger().error('Failed to sync notification webhooks', e, stack);
      if (!mounted) return;
      setState(() {
        if (_radarrStatus.type == _WebhookStatusType.idle) {
          _radarrStatus = const _WebhookStatus(_WebhookStatusType.error);
        }
        if (_sonarrStatus.type == _WebhookStatusType.idle) {
          _sonarrStatus = const _WebhookStatus(_WebhookStatusType.error);
        }
        if (_lidarrStatus.type == _WebhookStatusType.idle) {
          _lidarrStatus = const _WebhookStatus(_WebhookStatusType.error);
        }
        if (_prowlarrStatus.type == _WebhookStatusType.idle) {
          _prowlarrStatus = const _WebhookStatus(_WebhookStatusType.error);
        }
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
          _radarrStatus = const _WebhookStatus(_WebhookStatusType.removing);
        });

        try {
          final api = RadarrAPI(
            host: profile.radarrHost,
            apiKey: profile.radarrKey,
            headers: Map<String, dynamic>.from(profile.radarrHeaders),
          );
          await RadarrWebhookManager.removeWebhook(api);
          setState(() {
            _radarrStatus = const _WebhookStatus(_WebhookStatusType.removed);
          });
        } catch (e) {
          setState(() {
            _radarrStatus =
                const _WebhookStatus(_WebhookStatusType.removeFailed);
          });
        }
      }

      // Remove Sonarr webhook if configured
      if (profile.sonarrEnabled &&
          profile.sonarrHost.isNotEmpty &&
          profile.sonarrKey.isNotEmpty) {
        setState(() {
          _sonarrStatus = const _WebhookStatus(_WebhookStatusType.removing);
        });

        try {
          final api = SonarrAPI(
            host: profile.sonarrHost,
            apiKey: profile.sonarrKey,
            headers: Map<String, dynamic>.from(profile.sonarrHeaders),
          );
          await SonarrWebhookManager.removeWebhook(api);
          setState(() {
            _sonarrStatus = const _WebhookStatus(_WebhookStatusType.removed);
          });
        } catch (e) {
          setState(() {
            _sonarrStatus =
                const _WebhookStatus(_WebhookStatusType.removeFailed);
          });
        }
      }

      // Remove Lidarr webhook if configured
      if (profile.lidarrEnabled &&
          profile.lidarrHost.isNotEmpty &&
          profile.lidarrKey.isNotEmpty) {
        setState(() {
          _lidarrStatus = const _WebhookStatus(_WebhookStatusType.removing);
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
            _lidarrStatus = const _WebhookStatus(_WebhookStatusType.removed);
          });
        } catch (e) {
          setState(() {
            _lidarrStatus =
                const _WebhookStatus(_WebhookStatusType.removeFailed);
          });
        }
      }

      // Remove Prowlarr webhook if configured
      final prowlarrIndexers = ZagBox.indexers.data.where((i) => i.isProwlarr).toList();
      if (prowlarrIndexers.isNotEmpty) {
        setState(() {
          _prowlarrStatus = const _WebhookStatus(_WebhookStatusType.removing);
        });

        try {
          final indexer = prowlarrIndexers.first;
          final client = Dio(
            BaseOptions(
              baseUrl: indexer.host.endsWith('/')
                  ? '${indexer.host}api/v1/'
                  : '${indexer.host}/api/v1/',
              headers: {
                'X-Api-Key': indexer.apiKey,
                ...indexer.headers,
              },
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
              followRedirects: true,
              maxRedirects: 5,
            ),
          );
          await ProwlarrWebhookManager.removeWebhook(client);
          setState(() {
            _prowlarrStatus = const _WebhookStatus(_WebhookStatusType.removed);
          });
        } catch (e) {
          setState(() {
            _prowlarrStatus =
                const _WebhookStatus(_WebhookStatusType.removeFailed);
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
        _statusBlock('settings.RadarrStatus'.tr(), _radarrStatus),
        _statusBlock('settings.SonarrStatus'.tr(), _sonarrStatus),
        _statusBlock('settings.LidarrStatus'.tr(), _lidarrStatus),
        _statusBlock('settings.ProwlarrStatus'.tr(), _prowlarrStatus),
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
                _prowlarrEventsButton(),
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

  Widget _statusBlock(String title, _WebhookStatus status) {
    final isSuccess = status.type == _WebhookStatusType.success;
    final isFailed = status.type == _WebhookStatusType.failed ||
        status.type == _WebhookStatusType.removeFailed ||
        status.type == _WebhookStatusType.error;
    final statusLabel = _statusLabel(status);
    final errorMessage = status.message ?? statusLabel;

    return ZagBlock(
      title: title,
      body: statusLabel.isEmpty ? [] : [TextSpan(text: statusLabel)],
      trailing: status.type == _WebhookStatusType.idle
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
      title: 'settings.NotificationStatusErrorTitle'.tr(args: [title]),
      content: [
        ZagDialog.textContent(
          text: errorMessage,
          textAlign: TextAlign.left,
        ),
      ],
      contentPadding: ZagDialog.textDialogContentPadding(),
    );
  }

  String _statusLabel(_WebhookStatus status) {
    switch (status.type) {
      case _WebhookStatusType.idle:
        return '';
      case _WebhookStatusType.notConfigured:
        return 'settings.NotificationStatusNotConfigured'.tr();
      case _WebhookStatusType.signInRequired:
        return 'settings.NotificationStatusSignInRequired'.tr();
      case _WebhookStatusType.syncing:
        return 'settings.NotificationStatusSyncing'.tr();
      case _WebhookStatusType.success:
        return 'settings.NotificationStatusSuccess'.tr();
      case _WebhookStatusType.failed:
        return 'settings.NotificationStatusFailed'.tr();
      case _WebhookStatusType.removing:
        return 'settings.NotificationStatusRemoving'.tr();
      case _WebhookStatusType.removed:
        return 'settings.NotificationStatusRemoved'.tr();
      case _WebhookStatusType.removeFailed:
        return 'settings.NotificationStatusRemoveFailed'.tr();
      case _WebhookStatusType.error:
        return 'settings.NotificationStatusError'.tr();
    }
  }

  Widget _enableNotifications() {
    const db = ZagreusDatabase.ENABLE_IN_APP_NOTIFICATIONS;

    return ZagBlock(
      title: 'settings.EnableNotifications'.tr(),
      body: [
        TextSpan(text: 'settings.EnableNotificationsDescription'.tr()),
      ],
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
                  title: 'settings.NotificationPermissionDeniedTitle'.tr(),
                  message: 'settings.NotificationPermissionDeniedMessage'.tr(),
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
      title: 'settings.MultiDeviceSync'.tr(),
      body: [
        TextSpan(
          text: isSignedIn
              ? 'settings.MultiDeviceSyncDescriptionSignedIn'.tr()
              : 'settings.MultiDeviceSyncDescriptionSignedOut'.tr(),
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
                        ? 'settings.EnableMultiDeviceSyncTitle'.tr()
                        : 'settings.DisableMultiDeviceSyncTitle'.tr(),
                    content: [
                      ZagDialog.textContent(
                        text: value
                            ? 'settings.EnableMultiDeviceSyncMessage'.tr()
                            : 'settings.DisableMultiDeviceSyncMessage'.tr(),
                      ),
                    ],
                    contentPadding: ZagDialog.textDialogContentPadding(),
                    buttons: [
                      ZagDialog.button(
                        text: 'settings.ContinueAction'.tr(),
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
                            title: 'settings.SuccessTitle'.tr(),
                            message: value
                                ? 'settings.MultiDeviceSyncEnabledMessage'.tr()
                                : 'settings.MultiDeviceSyncDisabledMessage'
                                    .tr(),
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
                          title: 'settings.ErrorTitle'.tr(),
                          message: 'settings.NotificationModeUpdateFailed'
                              .tr(),
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
      title: 'settings.EnableInAppToasts'.tr(),
      body: [TextSpan(text: 'settings.EnableInAppToastsDescription'.tr())],
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
      title: 'settings.RadarrEvents'.tr(),
      body: [
        TextSpan(text: 'settings.NotificationEventsDescription'.tr()),
      ],
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: ZagColours.grey,
      ),
      onTap: () => _showCombinedEventsPage(
        title: 'settings.RadarrEvents'.tr(),
        pushEvents: [
          _EventConfig(
            'settings.NotificationEventOnGrab',
            ZagreusDatabase.RADARR_WEBHOOK_ON_GRAB,
          ),
          _EventConfig(
            'settings.NotificationEventOnImport',
            ZagreusDatabase.RADARR_WEBHOOK_ON_DOWNLOAD,
          ),
          _EventConfig(
            'settings.NotificationEventOnUpgrade',
            ZagreusDatabase.RADARR_WEBHOOK_ON_UPGRADE,
          ),
          _EventConfig(
            'settings.NotificationEventOnAdd',
            ZagreusDatabase.RADARR_WEBHOOK_ON_MOVIE_ADDED,
          ),
          _EventConfig(
            'settings.NotificationEventOnManualInteraction',
            ZagreusDatabase.RADARR_WEBHOOK_ON_MANUAL_INTERACTION,
          ),
        ],
        toastEvents: [
          _EventConfig(
            'settings.NotificationEventOnGrab',
            ZagreusDatabase.RADARR_TOAST_ON_GRAB,
          ),
          _EventConfig(
            'settings.NotificationEventOnImport',
            ZagreusDatabase.RADARR_TOAST_ON_DOWNLOAD,
          ),
          _EventConfig(
            'settings.NotificationEventOnUpgrade',
            ZagreusDatabase.RADARR_TOAST_ON_UPGRADE,
          ),
          _EventConfig(
            'settings.NotificationEventOnAdd',
            ZagreusDatabase.RADARR_TOAST_ON_MOVIE_ADDED,
          ),
          _EventConfig(
            'settings.NotificationEventOnManualInteraction',
            ZagreusDatabase.RADARR_TOAST_ON_MANUAL_INTERACTION,
          ),
        ],
      ),
    );
  }

  Widget _sonarrEventsButton() {
    return ZagBlock(
      title: 'settings.SonarrEvents'.tr(),
      body: [
        TextSpan(text: 'settings.NotificationEventsDescription'.tr()),
      ],
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: ZagColours.grey,
      ),
      onTap: () => _showCombinedEventsPage(
        title: 'settings.SonarrEvents'.tr(),
        pushEvents: [
          _EventConfig(
            'settings.NotificationEventOnGrab',
            ZagreusDatabase.SONARR_WEBHOOK_ON_GRAB,
          ),
          _EventConfig(
            'settings.NotificationEventOnImport',
            ZagreusDatabase.SONARR_WEBHOOK_ON_DOWNLOAD,
          ),
          _EventConfig(
            'settings.NotificationEventOnUpgrade',
            ZagreusDatabase.SONARR_WEBHOOK_ON_UPGRADE,
          ),
          _EventConfig(
            'settings.NotificationEventOnSeriesAdded',
            ZagreusDatabase.SONARR_WEBHOOK_ON_SERIES_ADD,
          ),
          _EventConfig(
            'settings.NotificationEventOnManualInteraction',
            ZagreusDatabase.SONARR_WEBHOOK_ON_MANUAL_INTERACTION,
          ),
        ],
        toastEvents: [
          _EventConfig(
            'settings.NotificationEventOnGrab',
            ZagreusDatabase.SONARR_TOAST_ON_GRAB,
          ),
          _EventConfig(
            'settings.NotificationEventOnImport',
            ZagreusDatabase.SONARR_TOAST_ON_DOWNLOAD,
          ),
          _EventConfig(
            'settings.NotificationEventOnUpgrade',
            ZagreusDatabase.SONARR_TOAST_ON_UPGRADE,
          ),
          _EventConfig(
            'settings.NotificationEventOnSeriesAdded',
            ZagreusDatabase.SONARR_TOAST_ON_SERIES_ADD,
          ),
          _EventConfig(
            'settings.NotificationEventOnManualInteraction',
            ZagreusDatabase.SONARR_TOAST_ON_MANUAL_INTERACTION,
          ),
        ],
      ),
    );
  }

  Widget _lidarrEventsButton() {
    return ZagBlock(
      title: 'settings.LidarrEvents'.tr(),
      body: [
        TextSpan(text: 'settings.NotificationEventsDescription'.tr()),
      ],
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: ZagColours.grey,
      ),
      onTap: () => _showCombinedEventsPage(
        title: 'settings.LidarrEvents'.tr(),
        pushEvents: [
          _EventConfig(
            'settings.NotificationEventOnGrab',
            ZagreusDatabase.LIDARR_WEBHOOK_ON_GRAB,
          ),
          _EventConfig(
            'settings.NotificationEventOnImport',
            ZagreusDatabase.LIDARR_WEBHOOK_ON_DOWNLOAD,
          ),
          _EventConfig(
            'settings.NotificationEventOnUpgrade',
            ZagreusDatabase.LIDARR_WEBHOOK_ON_UPGRADE,
          ),
          _EventConfig(
            'settings.NotificationEventOnArtistAdded',
            ZagreusDatabase.LIDARR_WEBHOOK_ON_ARTIST_ADD,
          ),
        ],
        toastEvents: [
          _EventConfig(
            'settings.NotificationEventOnGrab',
            ZagreusDatabase.LIDARR_TOAST_ON_GRAB,
          ),
          _EventConfig(
            'settings.NotificationEventOnImport',
            ZagreusDatabase.LIDARR_TOAST_ON_DOWNLOAD,
          ),
          _EventConfig(
            'settings.NotificationEventOnUpgrade',
            ZagreusDatabase.LIDARR_TOAST_ON_UPGRADE,
          ),
          _EventConfig(
            'settings.NotificationEventOnArtistAdded',
            ZagreusDatabase.LIDARR_TOAST_ON_ARTIST_ADD,
          ),
        ],
      ),
    );
  }

  Widget _prowlarrEventsButton() {
    return ZagBlock(
      title: 'settings.ProwlarrEvents'.tr(),
      body: [
        TextSpan(text: 'settings.NotificationEventsDescription'.tr()),
      ],
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: ZagColours.grey,
      ),
      onTap: () => _showProwlarrEventsPage(),
    );
  }

  void _showProwlarrEventsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ProwlarrEventsPage(
          onSync: _syncWebhooksInBackground,
        ),
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
        ZagBlock(
          title: 'settings.EnableSeerrNotifications'.tr(),
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

                          try {
                            final oldWebhookID = ZagreusDatabase.NOTIFICATION_WEBHOOK_ID.read();

                            // If turning OFF and we have a webhook, delete it (invalidate old URL)
                            if (!value && oldWebhookID.isNotEmpty) {
                              // Delete old webhook mapping
                              await http.delete(
                                Uri.parse('https://zagreus-notifications.fly.dev/v1/webhook'),
                                headers: {'Content-Type': 'application/json'},
                                body: json.encode({'webhook_id': oldWebhookID}),
                              );
                              // Clear local webhook ID so a new one is generated when re-enabled
                              ZagreusDatabase.NOTIFICATION_WEBHOOK_ID.update('');
                              ZagreusDatabase.NOTIFICATION_WEBHOOK_SIGNATURE.update('');
                              ZagLogger().debug('Seerr webhook deleted, new URL will be generated when re-enabled');
                            }
                            // When turning ON, a new webhook will be generated on next "Copy URL" tap
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
          title: 'settings.CopyWebhookUrl'.tr(),
          body: [
            TextSpan(
              text: 'settings.SeerrWebhookPasteHint'.tr(),
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
                  title: 'settings.ErrorTitle'.tr(),
                  message: 'settings.DeviceTokenUnavailableMessage'.tr(),
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
                  title: 'settings.CopiedTitle'.tr(),
                  message: 'settings.WebhookUrlCopiedMessage'.tr(),
                );
              } else {
                throw Exception('Failed to get webhook ID: ${response.statusCode}');
              }
            } catch (e, stackTrace) {
              ZagLogger().error('Failed to copy Seerr webhook URL', e, stackTrace);
              showZagErrorSnackBar(
                title: 'settings.ErrorTitle'.tr(),
                message: 'settings.WebhookUrlGenerationFailedMessage'.tr(),
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
        ZagBlock(
          title: 'settings.EnableTautulliNotifications'.tr(),
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

                          try {
                            final oldWebhookID = ZagreusDatabase.NOTIFICATION_WEBHOOK_ID.read();

                            // If turning OFF and we have a webhook, delete it (invalidate old URL)
                            if (!value && oldWebhookID.isNotEmpty) {
                              // Delete old webhook mapping
                              await http.delete(
                                Uri.parse('https://zagreus-notifications.fly.dev/v1/webhook'),
                                headers: {'Content-Type': 'application/json'},
                                body: json.encode({'webhook_id': oldWebhookID}),
                              );
                              // Clear local webhook ID so a new one is generated when re-enabled
                              ZagreusDatabase.NOTIFICATION_WEBHOOK_ID.update('');
                              ZagreusDatabase.NOTIFICATION_WEBHOOK_SIGNATURE.update('');
                              ZagLogger().debug('Tautulli webhook deleted, new URL will be generated when re-enabled');
                            }
                            // When turning ON, a new webhook will be generated on next "Copy URL" tap
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
          title: 'settings.CopyWebhookUrl'.tr(),
          body: [
            TextSpan(
              text: 'settings.TautulliWebhookPasteHint'.tr(),
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
                  title: 'settings.ErrorTitle'.tr(),
                  message: 'settings.DeviceTokenUnavailableMessage'.tr(),
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
                  title: 'settings.CopiedTitle'.tr(),
                  message: 'settings.WebhookUrlCopiedMessage'.tr(),
                );
              } else {
                throw Exception('Failed to get webhook ID: ${response.statusCode}');
              }
            } catch (e, stackTrace) {
              ZagLogger().error('Failed to copy Tautulli webhook URL', e, stackTrace);
              showZagErrorSnackBar(
                title: 'settings.ErrorTitle'.tr(),
                message: 'settings.WebhookUrlGenerationFailedMessage'.tr(),
              );
            }
          },
        ),
      ],
    );
  }
}

enum _WebhookStatusType {
  idle,
  notConfigured,
  signInRequired,
  syncing,
  success,
  failed,
  removing,
  removed,
  removeFailed,
  error,
}

class _WebhookStatus {
  final _WebhookStatusType type;
  final String? message;

  const _WebhookStatus(this.type, {this.message});
}

/// Helper class to hold event configuration data
class _EventConfig {
  final String titleKey;
  final ZagreusDatabase<bool> database;

  _EventConfig(this.titleKey, this.database);
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
          _buildSectionHeader('settings.NotificationsPushSectionTitle'),
          for (final event in widget.pushEvents)
            _buildPushEventToggle(context, event),

          // In-App Toasts Section
          ZagDivider(),
          _buildSectionHeader('settings.NotificationsToastsSectionTitle'),
          for (final event in widget.toastEvents)
            _buildToastEventToggle(context, event),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String titleKey) {
    return Padding(
      padding: EdgeInsets.all(ZagUI.DEFAULT_MARGIN_SIZE),
      child: Text(
        titleKey.tr(),
        style: TextStyle(
          fontSize: ZagUI.FONT_SIZE_H2,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      ),
    );
  }

  Widget _buildPushEventToggle(BuildContext context, _EventConfig event) {
    return ZagBlock(
      title: event.titleKey.tr(),
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
      title: event.titleKey.tr(),
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

/// Prowlarr events page (push notifications only, no toasts since it's not media)
class _ProwlarrEventsPage extends StatefulWidget {
  final VoidCallback? onSync;

  const _ProwlarrEventsPage({this.onSync});

  @override
  State<_ProwlarrEventsPage> createState() => _ProwlarrEventsPageState();
}

class _ProwlarrEventsPageState extends State<_ProwlarrEventsPage> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: ZagAppBar(
        title: 'settings.ProwlarrEvents'.tr(),
        scrollControllers: [scrollController],
      ),
      body: ZagListView(
        controller: scrollController,
        children: [
          _buildSectionHeader('settings.NotificationsPushSectionTitle'),
          _buildEventToggle(
            'settings.NotificationEventOnGrab',
            ZagreusDatabase.PROWLARR_WEBHOOK_ON_GRAB,
          ),
          _buildEventToggle(
            'settings.NotificationEventOnHealthIssue',
            ZagreusDatabase.PROWLARR_WEBHOOK_ON_HEALTH_ISSUE,
          ),
          _buildEventToggle(
            'settings.NotificationEventOnApplicationUpdate',
            ZagreusDatabase.PROWLARR_WEBHOOK_ON_APPLICATION_UPDATE,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String titleKey) {
    return Padding(
      padding: EdgeInsets.all(ZagUI.DEFAULT_MARGIN_SIZE),
      child: Text(
        titleKey.tr(),
        style: TextStyle(
          fontSize: ZagUI.FONT_SIZE_H2,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      ),
    );
  }

  Widget _buildEventToggle(String titleKey, ZagreusDatabase<bool> database) {
    return ZagBlock(
      title: titleKey.tr(),
      body: [],
      trailing: database.listenableBuilder(
        builder: (context, _) => ZagSwitch(
          value: database.read(),
          onChanged: (value) async {
            database.update(value);
            if (widget.onSync != null) {
              widget.onSync!();
            }
          },
        ),
      ),
    );
  }
}
