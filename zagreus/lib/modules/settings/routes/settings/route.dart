import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/messaging.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/database/tables/bios.dart';
import 'package:zagreus/services/revenuecat_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/modules.dart';

class SettingsRoute extends StatefulWidget {
  const SettingsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsRoute> createState() => _State();
}

class _State extends State<SettingsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _revokeTimer;

  @override
  void initState() {
    super.initState();
    _checkAndSetProBootModule();
  }

  void _checkAndSetProBootModule() {
    // When Pro is activated, automatically set boot module to Discover
    final isPro = ZagreusPro.isEnabled;
    if (isPro) {
      final currentModule = BIOSDatabase.BOOT_MODULE.read();
      // Only set to Discover if it's the first Pro activation
      if (currentModule != ZagModule.DISCOVER &&
          ZagreusDatabase.USER_BOOT_MODULE.read().isEmpty) {
        // Save current module as user preference
        ZagreusDatabase.USER_BOOT_MODULE.update(currentModule.key);
        // Set to Discover
        BIOSDatabase.BOOT_MODULE.update(ZagModule.DISCOVER);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      drawer: _drawer(),
      body: _body(),
    );
  }

  Widget _drawer() => ZagDrawer(page: ZagModule.SETTINGS.key);

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      useDrawer: true,
      scrollControllers: [scrollController],
      title: ZagModule.SETTINGS.title,
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagBlock(
          title: 'settings.Account'.tr(),
          body: [TextSpan(text: 'settings.AccountDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.account_circle_rounded),
          onTap: SettingsRoutes.ACCOUNT.go,
        ),
        ZagBlock(
          title: 'settings.Configuration'.tr(),
          body: [TextSpan(text: 'settings.ConfigurationDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.device_hub_rounded),
          onTap: SettingsRoutes.CONFIGURATION.go,
        ),
        if (ZagSupabaseMessaging.isSupported)
          ZagBlock(
            title: 'settings.Notifications'.tr(),
            body: [TextSpan(text: 'settings.NotificationsDescription'.tr())],
            trailing: const ZagIconButton(icon: Icons.notifications_rounded),
            onTap: SettingsRoutes.NOTIFICATIONS.go,
          ),
        ZagBlock(
          title: 'settings.Profiles'.tr(),
          body: [TextSpan(text: 'settings.ProfilesDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.switch_account_rounded),
          onTap: SettingsRoutes.PROFILES.go,
        ),
        ZagDivider(),
        ZagBlock(
          title: 'settings.Resources'.tr(),
          body: [TextSpan(text: 'settings.ResourcesDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.help_outline_rounded),
          onTap: SettingsRoutes.RESOURCES.go,
        ),
        ZagBlock(
          title: 'settings.System'.tr(),
          body: [TextSpan(text: 'settings.SystemDescription'.tr())],
          trailing: const ZagIconButton(icon: Icons.settings_rounded),
          onTap: SettingsRoutes.SYSTEM.go,
        ),
        ZagDivider(),
        _buildProButton(),
        _buildBootModuleToggle(),
      ],
    );
  }

  Widget _buildBootModuleToggle() {
    final bool isPro = ZagreusPro.isEnabled;

    // Show if user has Pro
    if (!isPro) return const SizedBox.shrink();

    return BIOSDatabase.BOOT_MODULE.listenableBuilder(builder: (context, _) {
      final currentModule = BIOSDatabase.BOOT_MODULE.read();
      final isDiscoverMode = currentModule == ZagModule.DISCOVER;
      final userModule = _getUserBootModule();

      return ZagBlock(
        title: 'Start with Discover',
        body: [
          TextSpan(
              text: isDiscoverMode
                  ? 'Opens Discover on launch'
                  : 'Opens ${userModule.title} on launch')
        ],
        trailing: ZagSwitch(
          value: isDiscoverMode,
          onChanged: (value) {
            if (value) {
              // Save current module as user preference if not already Discover
              if (currentModule != ZagModule.DISCOVER) {
                ZagreusDatabase.USER_BOOT_MODULE.update(currentModule.key);
              }
              // Set to Discover
              BIOSDatabase.BOOT_MODULE.update(ZagModule.DISCOVER);
            } else {
              // Restore user's previous module
              final userModuleKey = ZagreusDatabase.USER_BOOT_MODULE.read();
              final userModule =
                  ZagModule.fromKey(userModuleKey) ?? ZagModule.DASHBOARD;
              BIOSDatabase.BOOT_MODULE.update(userModule);
            }
          },
        ),
      );
    });
  }

  ZagModule _getUserBootModule() {
    final userModuleKey = ZagreusDatabase.USER_BOOT_MODULE.read();
    return ZagModule.fromKey(userModuleKey) ?? ZagModule.DASHBOARD;
  }

Widget _buildProButton() {
    final bool isPro = ZagreusPro.isEnabled;

    return ZagBlock(
      title: 'Zagreus Pro',
      body: [
        TextSpan(
            text: isPro
                ? 'Active • Monthly subscription'
                : 'Unlock premium features')
      ],
      trailing: GestureDetector(
        onLongPressStart: (_) {
          if (isPro) {
            _startRevokeTimer();
          }
        },
        onLongPressEnd: (_) => _cancelRevokeTimer(),
        child: ZagIconButton(
          icon: isPro ? Icons.star_rounded : Icons.lock_open_rounded,
          color: isPro ? ZagColours.orange : ZagColours.accent,
        ),
      ),
      onTap: () => _showProDialog(context),
    );
  }

  void _showProDialog(BuildContext context) {
    final bool isPro = ZagreusPro.isEnabled;

    ZagDialog.dialog(
      context: context,
      title: 'Zagreus Pro',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              isPro
                  ? 'You have an active ${ZagreusPro.subscriptionType} subscription.\n\n'
                      'Thank you for supporting Zagreus!'
                  : 'Unlock the Discover module and support continued development!',
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          if (!isPro) ...[
            ZagDialog.tile(
              icon: Icons.calendar_month_rounded,
              iconColor: ZagColours.accent,
              text: 'Monthly • \$0.79/month',
              subtitle: RichText(
                text: TextSpan(
                  text: '7-day free trial',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _purchasePro(true);
              },
            ),
            ZagDialog.tile(
              icon: Icons.star_rounded,
              iconColor: ZagColours.orange,
              text: 'Yearly • \$3.99/year',
              subtitle: RichText(
                text: TextSpan(
                  text: '1 month free trial',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _purchasePro(false);
              },
            ),
            const SizedBox(height: 16),
            // Legal links required by Apple
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'By subscribing, you agree to our',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => _openUrl(
                            'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontSize: 12,
                            color: ZagColours.accentLight,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        ' and ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      InkWell(
                        onTap: () => _openUrl('https://zagreus.app/privacy'),
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 12,
                            color: ZagColours.accentLight,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Restore Purchases button at bottom with Zagreus accent color
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _restorePurchases();
                },
                child: Text(
                  'Restore Purchases',
                  style: TextStyle(
                    fontSize: 16,
                    color: ZagColours.accentLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
          // Debug only - cancel subscription button
          if (isPro && const bool.fromEnvironment('dart.vm.product') == false)
            ZagDialog.tile(
              icon: Icons.cancel_rounded,
              iconColor: ZagColours.red,
              text: '[DEBUG] Cancel Subscription',
              onTap: () {
                Navigator.of(context).pop();
                _cancelPro();
              },
            ),
        ],
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  void _purchasePro(bool isMonthly) async {
    final iapService = RevenueCatService();

    // Check if IAP is available
    if (!iapService.isAvailable) {
      // Disabled debug fallback - was causing Pro to auto-enable
      // if (const bool.fromEnvironment('dart.vm.product') == false) {
      //   ZagreusPro.enablePro(isMonthly: isMonthly);
      //   setState(() {});
      //   showZagInfoSnackBar(
      //     title: '[DEBUG] Welcome to Zagreus Pro!',
      //     message: 'Premium features are now unlocked (Test Mode)',
      //   );
      // } else {
      showZagInfoSnackBar(
        title: 'Unavailable',
        message: 'In-app purchases are not available',
      );
      // }
      return;
    }

    // Attempt real purchase
    showZagInfoSnackBar(
      title: 'Processing',
      message: 'Connecting to App Store...',
    );

    final bool success = isMonthly
        ? await iapService.purchaseMonthly()
        : await iapService.purchaseYearly();

    if (success) {
      setState(() {});
    }
  }

  void _cancelPro() async {
    // Restore user's previous boot module before revoking Pro
    final currentModule = BIOSDatabase.BOOT_MODULE.read();
    if (currentModule == ZagModule.DISCOVER) {
      // User is currently on Discover, restore their previous choice
      final previousModule = ZagreusDatabase.USER_BOOT_MODULE.read();
      if (previousModule.isNotEmpty && previousModule != 'discover') {
        final module = ZagModule.fromKey(previousModule) ?? ZagModule.DASHBOARD;
        BIOSDatabase.BOOT_MODULE.update(module);
      } else {
        // Fallback to dashboard if no previous module saved
        BIOSDatabase.BOOT_MODULE.update(ZagModule.DASHBOARD);
      }
    }

    // Debug only - reset Pro status locally
    ZagreusPro.disable();

    // Also clear from Supabase if signed in
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('subscriptions').delete().eq('user_id', user.id);
      }
    } catch (e) {
      print('Error clearing cloud subscription: $e');
    }

    setState(() {});

    showZagInfoSnackBar(
      title: 'Pro Status Revoked',
      message:
          'Boot module restored to ${BIOSDatabase.BOOT_MODULE.read().name}',
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showZagInfoSnackBar(
        title: 'Error',
        message: 'Could not open link',
      );
    }
  }

  void _restorePurchases() async {
    showZagInfoSnackBar(
      title: 'Restoring',
      message: 'Checking for previous purchases...',
    );

    final iapService = RevenueCatService();
    await iapService.restorePurchases();

    // Refresh the UI to show updated Pro status
    setState(() {});
  }

  @override
  void dispose() {
    _cancelRevokeTimer();
    super.dispose();
  }

  void _startRevokeTimer() {
    _cancelRevokeTimer();
    _revokeTimer = Timer(const Duration(seconds: 5), _showSecretRevokeDialog);
  }

  void _cancelRevokeTimer() {
    _revokeTimer?.cancel();
    _revokeTimer = null;
  }

  void _showSecretRevokeDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🤫 Secret Debug Menu'),
        content: const Text(
          'Revoke Zagreus Pro subscription?\n\n'
          'This clears local status for debugging. Use "Restore Purchases" to re-sync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelPro();
            },
            child: Text(
              'Revoke',
              style: TextStyle(color: ZagColours.red),
            ),
          ),
        ],
      ),
    );
  }

  bool _isTestFlight() {
    // Check if running in TestFlight by looking for sandbox receipt
    // In production builds, the receipt is at /StoreKit/receipt
    // In TestFlight, it's at /StoreKit/sandboxReceipt
    return !const bool.fromEnvironment('dart.vm.product') ||
           Platform.isIOS; // For now, show on iOS to allow TestFlight users to enable it
  }

}
