import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/services/revenuecat_service.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/database/tables/bios.dart';
import 'package:zagreus/modules.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionsRoute extends StatefulWidget {
  const SubscriptionsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SubscriptionsRoute> createState() => _State();
}

class _State extends State<SubscriptionsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _revokeTimer;

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
      title: 'Subscriptions',
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    final bool isPro = ZagreusPro.isEnabled;
    final bool isMega = ZagreusMega.isEnabled;

    return ZagListView(
      controller: scrollController,
      children: [
        // Zagreus Pro Section
        ZagBlock(
          title: 'Zagreus Pro',
          body: [
            TextSpan(
              text: isPro
                  ? 'Active • ${ZagreusPro.subscriptionType} subscription'
                  : 'Unlock the Discover module',
            )
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
        ),

        // Zagreus Mega Section
        ZagBlock(
          title: 'Zagreus Mega',
          body: [
            TextSpan(
              text: isMega
                  ? 'Active • mega subscription'
                  : 'Unlock Z Assistant features • \$1.79/month'
            )
          ],
          trailing: ZagIconButton(
            icon: isMega ? Icons.star_rounded : Icons.star_border_rounded,
            color: ZagColours.purple,
          ),
          onTap: () => _showMegaDialog(context),
        ),
      ],
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

  void _showMegaDialog(BuildContext context) {
    final bool isMega = ZagreusMega.isEnabled;

    // If already have Mega, show status instead of purchase
    if (isMega) {
      ZagDialog.dialog(
        context: context,
        title: 'Zagreus Mega',
        customContent: ZagDialog.content(
          children: [
            Padding(
              padding: ZagDialog.textDialogContentPadding(),
              child: Text(
                'Your Mega subscription is active!\n\n'
                'You have full access to Z Assistant and all AI features.',
                style: const TextStyle(
                  fontSize: ZagUI.FONT_SIZE_H2,
                ),
              ),
            ),
          ],
        ),
        contentPadding: ZagDialog.listDialogContentPadding(),
      );
      return;
    }

    // Show purchase dialog only if NOT subscribed
    ZagDialog.dialog(
      context: context,
      title: 'Zagreus Mega',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              'Unlock Z Assistant features!\n\n'
              'Get AI-powered recommendations with Ask Z and more exclusive features.',
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          ZagDialog.tile(
            icon: Icons.rocket_launch_rounded,
            iconColor: ZagColours.purple,
            text: 'Monthly • \$1.79/month',
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
              _purchaseMega(true);
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
          // Restore Purchases button
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
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  void _purchasePro(bool isMonthly) async {
    final iapService = RevenueCatService();

    // Check if IAP is available
    if (!iapService.isAvailable) {
      showZagInfoSnackBar(
        title: 'Unavailable',
        message: 'In-app purchases are not available',
      );
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

  void _purchaseMega(bool isMonthly) async {
    final iapService = RevenueCatService();

    if (!iapService.isAvailable) {
      showZagInfoSnackBar(
        title: 'Unavailable',
        message: 'In-app purchases are not available',
      );
      return;
    }

    showZagInfoSnackBar(
      title: 'Processing',
      message: 'Connecting to App Store...',
    );

    // Purchase Mega subscription
    final bool success = await iapService.purchaseMega(isMonthly);

    if (success) {
      // Sync to Supabase
      await _syncMegaToSupabase();
      setState(() {});
    }
  }

  Future<void> _syncMegaToSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        final expiryString = ZagreusDatabase.ZAGREUS_MEGA_EXPIRY.read();
        if (expiryString.isNotEmpty) {
          final expiry = DateTime.parse(expiryString);
          final productId = ZagreusDatabase.ZAGREUS_MEGA_SUBSCRIPTION_TYPE.read();

          await supabase.rpc('upsert_subscription', params: {
            'p_user_id': user.id,
            'p_product_id': 'zagreus_mega_$productId',
            'p_subscription_type': 'mega',
            'p_expires_at': expiry.toUtc().toIso8601String(),
          });

          print('✅ Synced Mega subscription to Supabase');
        }
      }
    } catch (e) {
      print('⚠️ Failed to sync Mega subscription: $e');
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
    // Don't show toast here - RevenueCatService will show the result
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
          'Long press (5 seconds) on the Zagreus Pro star icon to revoke Pro status for testing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: TextStyle(color: ZagColours.accentLight),
            ),
          ),
        ],
      ),
    );
  }
}
