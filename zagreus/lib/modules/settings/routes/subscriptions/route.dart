import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/services/revenuecat_service.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/database/tables/bios.dart';
import 'package:zagreus/modules.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/system/network/local_switching_service.dart';
import 'package:zagreus/modules/settings/routes/subscriptions/shares_route.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/supabase/subscription_shares.dart';
import 'package:zagreus/services/subscription_service.dart';

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
    final bool isMega = ZagreusMega.isEnabled;
    final bool isUltra = ZagreusUltra.isEnabled;
    final bool canShare = isMega || isUltra;

    return ZagAppBar(
      title: 'Subscriptions',
      scrollControllers: [scrollController],
      actions: [
        // Only show redeem button for non-Mega/Ultra users
        if (ZagSupabaseAuth().isSignedIn && !canShare)
          IconButton(
            icon: Icon(
              Icons.redeem_rounded,
              color: ZagColours.currentAccent,
            ),
            onPressed: _showEnterShareCodeDialog,
          ),
      ],
    );
  }

  Widget _body() {
    final bool isPro = ZagreusPro.isEnabled;
    final bool isMega = ZagreusMega.isEnabled;
    final bool isUltra = ZagreusUltra.isEnabled;
    final String proPlanType = ZagreusPro.subscriptionType;
    final String? proPlanLabel =
        isPro ? 'Active • ${_formatPlanName(proPlanType)} plan' : null;
    final String ultraPlanType = ZagreusUltra.subscriptionType;
    final String? ultraPlanLabel =
        isUltra ? 'Active • ${_formatPlanName(ultraPlanType)} plan' : null;

    return ZagListView(
      controller: scrollController,
      children: [
        // Zagreus Pro Section
        ZagBlock(
          title: 'Zagreus Pro',
          body: [
            TextSpan(
              text: isUltra
                  ? 'Included with Ultra'
                  : isMega
                      ? 'Included with Mega'
                      : isPro
                          ? proPlanLabel!
                          : 'Unlock advanced modules and features',
            )
          ],
          trailing: GestureDetector(
            onLongPressStart: (_) {
              if (isPro && !isMega) {
                _startRevokeTimer();
              }
            },
            onLongPressEnd: (_) => _cancelRevokeTimer(),
            child: ZagIconButton(
              icon: (isUltra || isMega || isPro)
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: ZagColours.currentAccent,
            ),
          ),
          onTap: () => _showProDialog(context),
        ),

        // Zagreus Mega Section
        ZagBlock(
          title: 'Zagreus Mega',
          body: [
            TextSpan(
                text: isUltra
                    ? 'Included with Ultra'
                    : isMega
                        ? 'Active • Mega plan'
                        : 'Add AI agent and recommendations')
          ],
          trailing: ZagIconButton(
            icon: (isUltra || isMega)
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: ZagColours.orange,
          ),
          onTap: () => _showMegaDialog(context),
        ),

        // Zagreus Ultra Section (preview)
        ZagBlock(
          title: 'Zagreus Ultra',
          body: [
            TextSpan(
              text: isUltra
                  ? ultraPlanLabel!
                  : 'Use flagship models for AI features',
            ),
          ],
          trailing: ZagIconButton(
            icon: isUltra ? Icons.star_rounded : Icons.star_border_rounded,
            color: ZagColours.purple,
          ),
          onTap: () => _showUltraDialog(context),
        ),

        // Subscription Sharing (for Mega/Ultra users or shared Pro users)
        if (ZagSupabaseAuth().isSignedIn && (isMega || isUltra || _hasSharedPro()))
          ZagBlock(
            title: 'Subscription Sharing',
            body: [
              TextSpan(
                text: isUltra
                    ? 'Manage your 5 Pro shares'
                    : isMega
                        ? 'Manage your 1 Pro share'
                        : 'View shared access',
              ),
            ],
            trailing: ZagIconButton(
              icon: Icons.supervisor_account_rounded,
              color: isUltra
                  ? ZagColours.purple
                  : isMega
                      ? ZagColours.orange
                      : ZagColours.currentAccent,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SharesManagementRoute(),
              ),
            ),
          ),
      ],
    );
  }

  bool _hasSharedPro() {
    // Check if user has shared Pro access (no direct subscription but has Pro enabled)
    return ZagreusPro.isEnabled &&
        !ZagreusDatabase.ZAGREUS_PRO_ENABLED.read() &&
        !ZagreusMega.isEnabled &&
        !ZagreusUltra.isEnabled;
  }

  void _showProDialog(BuildContext context) {
    final bool isPro = ZagreusPro.isEnabled;
    final bool isMega = ZagreusMega.isEnabled;
    final bool isUltra = ZagreusUltra.isEnabled;

    if (isUltra) {
      ZagDialog.dialog(
        context: context,
        title: 'Zagreus Pro',
        customContent: ZagDialog.content(
          children: [
            Padding(
              padding: ZagDialog.textDialogContentPadding(),
              child: Text(
                'Ultra already includes every Pro feature.',
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

    // If user has Mega, show that Pro is included
    if (isMega) {
      ZagDialog.dialog(
        context: context,
        title: 'Zagreus Pro',
        customContent: ZagDialog.content(
          children: [
            Padding(
              padding: ZagDialog.textDialogContentPadding(),
              child: Text(
                'Mega already includes every Pro feature.',
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

    ZagDialog.dialog(
      context: context,
      title: 'Zagreus Pro',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              isPro
                  ? "You're on the ${_formatPlanName(ZagreusPro.subscriptionType)} plan.\n\nEnjoy Dashboard upgrades, the Server module, Unraid integrations, and more!"
                  : 'Zagreus Pro unlocks:\n'
                      '• Dashboard enhancements\n'
                      '• Unraid, Overseerr, and Search modules\n'
                      '• And more!\n\n'
                      'Choose a plan to get started.',
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          if (!isPro) ...[
            ZagDialog.tile(
              icon: Icons.calendar_month_rounded,
              iconColor: ZagColours.currentAccent,
              text: 'Monthly • \$0.99/month',
              subtitle: RichText(
                text: TextSpan(
                  text: '7-day free trial',
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
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
              iconColor: ZagColours.currentAccent,
              text: 'Yearly • \$4.99/year',
              subtitle: RichText(
                text: TextSpan(
                  text: '1 month free trial',
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
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
                            color: ZagColours.currentAccentLight,
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
                            color: ZagColours.currentAccentLight,
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
                    color: ZagColours.currentAccentLight,
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
    final bool isUltra = ZagreusUltra.isEnabled;

    if (isUltra) {
      ZagDialog.dialog(
        context: context,
        title: 'Zagreus Mega',
        customContent: ZagDialog.content(
          children: [
            Padding(
              padding: ZagDialog.textDialogContentPadding(),
              child: Text(
                'Ultra already includes every Mega feature.',
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

    ZagDialog.dialog(
      context: context,
      title: 'Zagreus Mega',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              isMega
                  ? "You have an active Mega subscription.\n\nEnjoy the fully unlocked AI agent with Dashboard recommendations and Ask Z powered by GPT-5 mini (15 messages every 12 hours)."
                  : 'Zagreus Mega unlocks:\n'
                      '• Fully unlocked AI agent and Dashboard recommendations\n'
                      '• Ask Z powered by GPT-5 mini (15 messages every 12 hours)\n'
                      '• All Pro features',
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          if (!isMega) ...[
            ZagDialog.tile(
              icon: Icons.rocket_launch_rounded,
              iconColor: ZagColours.orange,
              text: 'Monthly • \$1.79/month',
              subtitle: RichText(
                text: TextSpan(
                  text: '7-day free trial',
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
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
                            color: ZagColours.currentAccentLight,
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
                            color: ZagColours.currentAccentLight,
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
                    color: ZagColours.currentAccentLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  String _formatPlanName(String raw) {
    if (raw.isEmpty) return 'Pro';
    final lower = raw.toLowerCase();
    if (lower.contains('year')) return 'Yearly';
    if (lower.contains('month')) return 'Monthly';
    return raw[0].toUpperCase() + raw.substring(1);
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
      setState(() {});
    }
  }

  void _purchaseUltra() async {
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

    final bool success = await iapService.purchaseUltra();

    if (success) {
      setState(() {});
    }
  }

  void _cancelPro() async {
    // Restore user's previous boot module before revoking Pro
    final currentModule = BIOSDatabase.BOOT_MODULE.read();
    if (currentModule == ZagModule.DISCOVER) {
      // User is currently on Dashboard, restore their previous choice
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
    await ZagLocalConnectionService().disableAdvancedSwitching();

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

  void _showUltraDialog(BuildContext context) {
    final bool isUltra = ZagreusUltra.isEnabled;

    ZagDialog.dialog(
      context: context,
      title: 'Zagreus Ultra',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              isUltra
                  ? "You have an active Ultra subscription.\n\nEnjoy GPT-5.1 Ask Z responses, GPT-5.1 Dashboard results, and every Mega perk."
                  : 'Zagreus Ultra unlocks:\n'
                      '• GPT-5.1 responses for Ask Z and Dashboard\n'
                      '• All Pro and Mega features',
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          if (!isUltra) ...[
            ZagDialog.tile(
              icon: Icons.auto_awesome_rounded,
              iconColor: ZagColours.purple,
              text: 'Monthly • \$3.99/month',
              subtitle: RichText(
                text: TextSpan(
                  text: 'Includes all Mega + Pro features',
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _purchaseUltra();
              },
            ),
            const SizedBox(height: 16),
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
                            color: ZagColours.currentAccentLight,
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
                            color: ZagColours.currentAccentLight,
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
                    color: ZagColours.currentAccentLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  void _restorePurchases() async {
    // Don't show toast here - RevenueCatService will show the result
    final iapService = RevenueCatService();
    await iapService.restorePurchases();

    // Refresh the UI to show updated Pro status
    setState(() {});
  }

  void _showEnterShareCodeDialog() {
    final TextEditingController codeController = TextEditingController();

    ZagDialog.dialog(
      context: context,
      title: 'Enter Share Code',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter the share code you received:',
                  style: const TextStyle(fontSize: ZagUI.FONT_SIZE_H2),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Share Code',
                    hintText: 'ABC123XY',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ZagDialog.tile(
            icon: Icons.check_rounded,
            iconColor: ZagColours.currentAccent,
            text: 'Redeem',
            onTap: () {
              Navigator.of(context).pop();
              _redeemShareCode(codeController.text.trim().toUpperCase());
            },
          ),
        ],
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  Future<void> _redeemShareCode(String code) async {
    if (code.isEmpty) {
      showZagInfoSnackBar(
        title: 'Invalid Code',
        message: 'Please enter a share code',
      );
      return;
    }

    showZagInfoSnackBar(
      title: 'Redeeming',
      message: 'Checking share code...',
    );

    final result = await ZagSupabaseShares().redeemShareCode(code);

    if (result.success) {
      showZagInfoSnackBar(
        title: 'Success',
        message: 'Pro access activated!',
      );

      // Refresh subscription status
      SubscriptionService().refresh();

      setState(() {});
    } else {
      showZagInfoSnackBar(
        title: 'Failed',
        message: result.error ?? 'Invalid or expired share code',
      );
    }
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
              style: TextStyle(color: ZagColours.currentAccentLight),
            ),
          ),
        ],
      ),
    );
  }
}
