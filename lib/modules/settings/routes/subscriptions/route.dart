import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_supreme.dart';
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
  void initState() {
    super.initState();
  }

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
    final bool isUltra = ZagreusUltra.isEnabled;
    final bool isSupreme = ZagreusSupreme.isEnabled;
    final String proPlanType = ZagreusPro.subscriptionType;
    final String? proPlanLabel =
        isPro ? 'Active • ${_formatPlanName(proPlanType)} plan' : null;
    final String ultraPlanType = ZagreusUltra.subscriptionType;
    final String? ultraPlanLabel =
        isUltra ? 'Active • ${_formatPlanName(ultraPlanType)} plan' : null;
    final String supremePlanType = ZagreusSupreme.subscriptionType;
    final String? supremePlanLabel =
        isSupreme ? 'Active • ${_formatPlanName(supremePlanType)} plan' : null;

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
                          : 'Unlock all modules & power features',
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
              text: isSupreme
                  ? 'Included with Supreme'
                  : isUltra
                      ? ultraPlanLabel!
                      : 'Use powerful models for AI features',
            ),
          ],
          trailing: ZagIconButton(
            icon: (isSupreme || isUltra) ? Icons.star_rounded : Icons.star_border_rounded,
            color: ZagColours.purple,
          ),
          onTap: () => _showUltraDialog(context),
        ),

        // Zagreus Supreme Section (only for Ultra+ users)
        if (isUltra || isSupreme)
          ZagBlock(
            title: 'Zagreus Supreme',
            body: [
              TextSpan(
                text: isSupreme
                    ? supremePlanLabel!
                    : 'Use world leading models for AI features',
              ),
            ],
            trailing: ZagIconButton(
              icon: isSupreme ? Icons.star_rounded : Icons.star_border_rounded,
              color: ZagColours.gold,
            ),
            onTap: () => _showSupremeDialog(context),
          ),

        // Subscription Sharing (for Mega/Ultra/Supreme users or shared Pro users)
        if (ZagSupabaseAuth().isSignedIn && (isMega || isUltra || isSupreme || _hasSharedPro()))
          ZagBlock(
            title: 'Subscription Sharing',
            body: [
              TextSpan(
                text: isSupreme
                    ? 'Manage your 10 Pro shares'
                    : isUltra
                        ? 'Manage your 5 Pro shares'
                        : isMega
                            ? 'Manage your 1 Pro share'
                            : 'View shared access',
              ),
            ],
            trailing: ZagIconButton(
              icon: Icons.supervisor_account_rounded,
              color: isSupreme
                  ? ZagColours.gold
                  : isUltra
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
        !ZagreusUltra.isEnabled &&
        !ZagreusSupreme.isEnabled;
  }

  void _showProDialog(BuildContext context) {
    final bool isPro = ZagreusPro.isEnabled;
    final bool isMega = ZagreusMega.isEnabled;
    final bool isUltra = ZagreusUltra.isEnabled;
    final bool isSupreme = ZagreusSupreme.isEnabled;
    String introText;
    if (isSupreme) {
      introText =
          'Supreme already includes every Pro feature.\n\nWant to downgrade? Pick a Pro plan below.';
    } else if (isUltra) {
      introText =
          'Ultra already includes every Pro feature.\n\nWant to downgrade? Pick a Pro plan below.';
    } else if (isMega) {
      introText =
          'Mega already includes every Pro feature.\n\nWant to downgrade? Pick a Pro plan below.';
    } else if (isPro) {
      introText =
          "You're on the ${_formatPlanName(ZagreusPro.subscriptionType)} plan.\n\nEnjoy Dashboard upgrades and premium features!";
    } else {
      introText = 'Zagreus Pro unlocks:\n'
          '• Premium Dashboard\n'
          '• Unraid\n'
          '• Overseerr\n'
          '• Prowlarr\n'
          '• Enhanced Cast & Crew\n'
          '• Ratings & Links\n'
          '• And more\n\n'
          'Choose a plan to get started.';
    }

    ZagDialog.dialog(
      context: context,
      title: 'Zagreus Pro',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              introText,
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          if (isPro &&
              ZagreusPro.subscriptionType.toLowerCase().contains('month')) ...[
            const SizedBox(height: 12),
            ZagDialog.tile(
              icon: Icons.autorenew_rounded,
              iconColor: ZagColours.currentAccent,
              text: 'Switch to Yearly • \$4.99/year',
              subtitle: RichText(
                text: TextSpan(
                  text: 'Lock in savings vs monthly billing',
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
          ],
          if (!isPro || isMega || isUltra || isSupreme) ...[
            ZagDialog.tile(
              icon: Icons.rocket_launch_rounded,
              iconColor: ZagColours.currentAccent,
              text: 'Monthly • \$0.99/month',
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
                _purchasePro(true);
              },
            ),
            ZagDialog.tile(
              icon: Icons.stars_rounded,
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
    final bool isSupreme = ZagreusSupreme.isEnabled;

    if (isSupreme) {
      ZagDialog.dialog(
        context: context,
        title: 'Zagreus Mega',
        customContent: ZagDialog.content(
          children: [
            Padding(
              padding: ZagDialog.textDialogContentPadding(),
              child: Text(
                'Supreme already includes every Mega feature.',
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

    String megaIntro;
    if (isSupreme) {
      megaIntro =
          'Supreme already includes every Mega feature.\n\nWant to downgrade? Pick a Mega plan below.';
    } else if (isUltra) {
      megaIntro =
          'Ultra already includes every Mega feature.\n\nWant to downgrade? Pick a Mega plan below.';
    } else if (isMega) {
      megaIntro =
          "You have an active Mega subscription.\n\nEnjoy the fully unlocked AI agent with Dashboard recommendations and Ask Z powered by GPT-5 mini (15 messages every 12 hours).";
    } else {
      megaIntro = 'Zagreus Mega unlocks:\n'
          '• Fully unlocked AI agent and Dashboard recommendations\n'
          '• Ask Z powered by GPT-5 mini (15 messages every 12 hours)\n'
          '• All Pro features';
    }

    ZagDialog.dialog(
      context: context,
      title: 'Zagreus Mega',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              megaIntro,
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          if (isMega &&
              ZagreusMega.subscriptionType.toLowerCase().contains('month')) ...[
            const SizedBox(height: 12),
            ZagDialog.tile(
              icon: Icons.autorenew_rounded,
              iconColor: ZagColours.orange,
              text: 'Switch to Yearly • \$14.99/year',
              subtitle: RichText(
                text: TextSpan(
                  text: 'Best value • save vs monthly',
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
                _purchaseMega(false);
              },
            ),
          ],
          if (!isMega || isUltra || isSupreme) ...[
            ZagDialog.tile(
              icon: Icons.flash_on_rounded,
              iconColor: ZagColours.orange,
              text: 'Monthly • \$1.99/month',
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
                _purchaseMega(true);
              },
            ),
            ZagDialog.tile(
              icon: Icons.stars_rounded,
              iconColor: ZagColours.orange,
              text: 'Yearly • \$14.99/year',
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
                _purchaseMega(false);
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

  void _purchaseUltra(bool isMonthly) async {
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

    final bool success = await iapService.purchaseUltra(isMonthly);

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
    final bool isSupreme = ZagreusSupreme.isEnabled;

    final String introText = isSupreme
        ? 'Supreme already includes every Ultra feature.\n\nWant to downgrade? Pick an Ultra plan below.'
        : isUltra
            ? "You have an active Ultra subscription.\n\nEnjoy GPT-5.1 Ask Z responses, GPT-5.1 Dashboard results, and every Mega perk."
            : 'Zagreus Ultra unlocks:\n'
                '• GPT-5.1 responses for Ask Z and Dashboard\n'
                '• All Pro and Mega features';

    ZagDialog.dialog(
      context: context,
      title: 'Zagreus Ultra',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              introText,
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          if (isUltra &&
              ZagreusUltra.subscriptionType.toLowerCase().contains('month')) ...[
            const SizedBox(height: 12),
            ZagDialog.tile(
              icon: Icons.autorenew_rounded,
              iconColor: ZagColours.purple,
              text: 'Switch to Yearly • \$34.99/year',
              subtitle: RichText(
                text: TextSpan(
                  text: 'Best value • save over monthly',
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
                _purchaseUltra(false);
              },
            ),
          ],
          if (!isUltra || isSupreme) ...[
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
                _purchaseUltra(true);
              },
            ),
            ZagDialog.tile(
              icon: Icons.stars_rounded,
              iconColor: ZagColours.purple,
              text: 'Yearly • \$34.99/year',
              subtitle: RichText(
                text: TextSpan(
                  text: 'Best value • save over 25%',
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
                _purchaseUltra(false);
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

  void _showSupremeDialog(BuildContext context) {
    final bool isSupreme = ZagreusSupreme.isEnabled;

    ZagDialog.dialog(
      context: context,
      title: 'Zagreus Supreme',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              isSupreme
                  ? "You have an active Supreme subscription.\n\nEnjoy world leading AI models for Z Assistant and recommendations, plus all Ultra, Mega, and Pro features."
                  : 'Zagreus Supreme unlocks:\n'
                      '• World leading AI models for Z Assistant\n'
                      '• All Ultra, Mega, and Pro features',
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          if (!isSupreme) ...[
            ZagDialog.tile(
              icon: Icons.auto_awesome_rounded,
              iconColor: ZagColours.gold,
              text: 'Monthly • \$14.99/month',
              subtitle: RichText(
                text: TextSpan(
                  text: 'Includes all Ultra + Mega + Pro features',
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
                _purchaseSupreme(true);
              },
            ),
            ZagDialog.tile(
              icon: Icons.stars_rounded,
              iconColor: ZagColours.gold,
              text: 'Yearly • \$149.99/year',
              subtitle: RichText(
                text: TextSpan(
                  text: 'Best value • save over 15%',
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
                _purchaseSupreme(false);
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

  void _purchaseSupreme(bool isMonthly) async {
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

    final bool success = await iapService.purchaseSupreme(isMonthly);

    if (success) {
      setState(() {});
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
              style: TextStyle(color: ZagColours.currentAccentLight),
            ),
          ),
        ],
      ),
    );
  }
}
