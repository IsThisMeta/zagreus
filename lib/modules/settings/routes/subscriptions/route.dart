import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_supreme.dart';
import 'package:zagreus/services/revenuecat_service.dart';
import 'package:zagreus/services/z_assistant_service.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/database/tables/bios.dart';
import 'package:zagreus/modules.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/system/network/local_switching_service.dart';
import 'package:zagreus/modules/settings/routes/subscriptions/shares_route.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/supabase/auth.dart';

class SubscriptionsRoute extends StatefulWidget {
  const SubscriptionsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SubscriptionsRoute> createState() => _State();
}

class _State extends State<SubscriptionsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<User?>? _authSubscription;
  bool _accountLinkLoaded = false;
  Map<String, dynamic>? _accountSubscription;
  bool get _isSignedIn => ZagSupabaseAuth().isSignedIn;

  @override
  void initState() {
    super.initState();
    _authSubscription = ZagSupabaseAuth.authStateChanges().listen((_) {
      _loadAccountSubscription();
    });
    _loadAccountSubscription();
  }

  Future<void> _loadAccountSubscription() async {
    if (!_isSignedIn) {
      if (!mounted) return;
      setState(() {
        _accountSubscription = null;
        _accountLinkLoaded = true;
      });
      return;
    }

    try {
      final row = await Supabase.instance.client
          .from('account_subscriptions')
          .select('rc_original_app_user_id,tier,expires_at,product_id,updated_at')
          .maybeSingle();
      if (!mounted) return;
      setState(() {
        _accountSubscription =
            row == null ? null : Map<String, dynamic>.from(row as Map);
        _accountLinkLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _accountSubscription = null;
        _accountLinkLoaded = true;
      });
    }
  }

  bool get _hasLinkedSubscription => _accountSubscription != null;

  void _promptSignInForSharing() {
    showZagInfoSnackBar(
      title: 'settings.SubscriptionsSignInRequiredTitle'.tr(),
      message: 'settings.SubscriptionsSignInRequiredMessage'.tr(),
    );
    SettingsRoutes.ACCOUNT.go();
  }

  Future<void> _linkThisAccount() async {
    if (!_isSignedIn) return;
    showZagInfoSnackBar(
      title: 'settings.SubscriptionsLinkingTitle'.tr(),
      message: 'settings.SubscriptionsLinkingMessage'.tr(),
    );
    try {
      await ZAssistantService().linkAccountToSubscription();
      await _loadAccountSubscription();
      showZagSuccessSnackBar(
        title: 'settings.SubscriptionsLinkedTitle'.tr(),
        message: 'settings.SubscriptionsLinkedMessage'.tr(),
      );
    } catch (e) {
      showZagErrorSnackBar(
        title: 'settings.SubscriptionsLinkFailedTitle'.tr(),
        message: e.toString(),
      );
    }
  }

  Future<void> _unlinkThisAccount() async {
    if (!_isSignedIn) return;
    showZagInfoSnackBar(
      title: 'settings.SubscriptionsUnlinkingTitle'.tr(),
      message: 'settings.SubscriptionsUnlinkingMessage'.tr(),
    );
    try {
      await ZAssistantService().unlinkAccountFromSubscription();
      await _loadAccountSubscription();
      showZagSuccessSnackBar(
        title: 'settings.SubscriptionsUnlinkedTitle'.tr(),
        message: 'settings.SubscriptionsUnlinkedMessage'.tr(),
      );
    } catch (e) {
      showZagErrorSnackBar(
        title: 'settings.SubscriptionsUnlinkFailedTitle'.tr(),
        message: e.toString(),
      );
    }
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
      title: 'settings.SubscriptionsTitle'.tr(),
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
        isPro
            ? 'settings.SubscriptionsActivePlan'
                .tr(args: [_formatPlanName(proPlanType)])
            : null;
    final String ultraPlanType = ZagreusUltra.subscriptionType;
    final String? ultraPlanLabel =
        isUltra
            ? 'settings.SubscriptionsActivePlan'
                .tr(args: [_formatPlanName(ultraPlanType)])
            : null;
    final String supremePlanType = ZagreusSupreme.subscriptionType;
    final String? supremePlanLabel =
        isSupreme
            ? 'settings.SubscriptionsActivePlan'
                .tr(args: [_formatPlanName(supremePlanType)])
            : null;

    return ZagListView(
      controller: scrollController,
      children: [
        // Zagreus Pro Section
        ZagBlock(
          title: 'settings.SubscriptionsZagreusProTitle'.tr(),
          body: [
            TextSpan(
              text: isUltra
                  ? 'settings.SubscriptionsIncludedWithUltra'.tr()
                  : isMega
                      ? 'settings.SubscriptionsIncludedWithMega'.tr()
                      : isPro
                          ? proPlanLabel!
                          : 'settings.SubscriptionsProUnlock'.tr(),
            )
          ],
          trailing: ZagIconButton(
            icon: (isUltra || isMega || isPro)
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: ZagColours.currentAccent,
          ),
          onTap: () => _showProDialog(context),
        ),

        // Zagreus Mega Section
        ZagBlock(
          title: 'settings.SubscriptionsZagreusMegaTitle'.tr(),
          body: [
            TextSpan(
                text: isUltra
                    ? 'settings.SubscriptionsIncludedWithUltra'.tr()
                    : isMega
                        ? 'settings.SubscriptionsMegaActive'.tr()
                        : 'settings.SubscriptionsMegaAddAi'.tr())
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
          title: 'settings.SubscriptionsZagreusUltraTitle'.tr(),
          body: [
            TextSpan(
              text: isSupreme
                  ? 'settings.SubscriptionsIncludedWithSupreme'.tr()
                  : isUltra
                      ? ultraPlanLabel!
                      : 'settings.SubscriptionsUltraUseModels'.tr(),
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
            title: 'settings.SubscriptionsZagreusSupremeTitle'.tr(),
            body: [
              TextSpan(
                text: isSupreme
                    ? supremePlanLabel!
                    : 'settings.SubscriptionsSupremeUseModels'.tr(),
              ),
            ],
            trailing: ZagIconButton(
              icon: isSupreme ? Icons.star_rounded : Icons.star_border_rounded,
              color: ZagColours.gold,
          ),
          onTap: () => _showSupremeDialog(context),
        ),

        if (isMega || isUltra || isSupreme)
          ZagBlock(
            title: 'settings.SubscriptionsAccountLinkTitle'.tr(),
            body: [
              TextSpan(
                text: !_isSignedIn
                    ? 'settings.SubscriptionsLinkToShare'.tr()
                    : _accountLinkLoaded
                        ? (_hasLinkedSubscription
                            ? 'settings.SubscriptionsLinked'
                                .tr(args: [(_accountSubscription?['tier'] as String?)?.toUpperCase() ?? ''])
                            : 'settings.SubscriptionsLinkToShare'.tr())
                        : 'settings.SubscriptionsCheckingLink'.tr(),
              ),
            ],
            trailing: ZagIconButton(
              icon: !_isSignedIn
                  ? Icons.login_rounded
                  : _hasLinkedSubscription
                      ? Icons.link_rounded
                      : Icons.link_off_rounded,
              color: _hasLinkedSubscription
                  ? ZagColours.purple
                  : ZagColours.currentAccent,
            ),
            onTap: () async {
              if (!_isSignedIn) {
                _promptSignInForSharing();
                return;
              }
              if (!_accountLinkLoaded) return;
              if (_hasLinkedSubscription) {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('settings.SubscriptionsUnlinkTitle'.tr()),
                    content: Text(
                      'settings.SubscriptionsUnlinkBody'.tr(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: ZagColours.white,
                        ),
                        child: Text('zagreus.Cancel'.tr()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: ZagColours.currentAccent,
                        ),
                        child: Text('settings.SubscriptionsUnlinkAction'.tr()),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await _unlinkThisAccount();
                }
                return;
              }
              await _linkThisAccount();
            },
          ),

        // Subscription Sharing (for Mega/Ultra/Supreme users or shared Pro users)
        if (ZagSupabaseAuth().isSignedIn &&
            ((isMega || isUltra || isSupreme) ? _hasLinkedSubscription : _hasSharedPro()))
          ZagBlock(
            title: 'settings.SubscriptionsSharingTitle'.tr(),
            body: [
              TextSpan(
                text: isSupreme
                    ? 'settings.SubscriptionsSharingManage'.tr(args: ['10'])
                    : isUltra
                        ? 'settings.SubscriptionsSharingManage'.tr(args: ['5'])
                        : isMega
                            ? 'settings.SubscriptionsSharingManage'.tr(args: ['1'])
                            : 'settings.SubscriptionsSharingView'.tr(),
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
          'settings.SubscriptionsProIncludedSupreme'.tr();
    } else if (isUltra) {
      introText =
          'settings.SubscriptionsProIncludedUltra'.tr();
    } else if (isMega) {
      introText =
          'settings.SubscriptionsProIncludedMega'.tr();
    } else if (isPro) {
      introText =
          'settings.SubscriptionsProActiveMessage'
              .tr(args: [_formatPlanName(ZagreusPro.subscriptionType)]);
    } else {
      introText = 'settings.SubscriptionsProUnlocks'.tr();
    }

    ZagDialog.dialog(
      context: context,
      title: 'settings.SubscriptionsZagreusProTitle'.tr(),
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              introText,
              style: TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
                color: ZagColours.textColor(context),
              ),
            ),
          ),
          // Show upgrade options for existing Pro subscribers (not lifetime)
          if (isPro &&
              !isMega &&
              !isUltra &&
              !isSupreme &&
              !ZagreusPro.subscriptionType.toLowerCase().contains('lifetime')) ...[
            const SizedBox(height: 12),
            // Show yearly option for monthly subscribers
            if (ZagreusPro.subscriptionType.toLowerCase().contains('month'))
              ZagDialog.tile(
                icon: Icons.autorenew_rounded,
                iconColor: ZagColours.currentAccent,
                text: 'settings.SubscriptionsSwitchToYearly'
                    .tr(args: ['\$4.99/year']),
                subtitle: RichText(
                  text: TextSpan(
                    text: 'settings.SubscriptionsLockInSavings'.tr(),
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
            // Show lifetime option for all non-lifetime subscribers
            ZagDialog.tile(
              icon: Icons.all_inclusive_rounded,
              iconColor: ZagColours.currentAccent,
              text: 'settings.SubscriptionsSwitchToLifetime'
                  .tr(args: ['\$19.99']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsLifetimeOneTime'.tr(),
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
                _purchaseProLifetime();
              },
            ),
          ],
          if (!isPro || isMega || isUltra || isSupreme) ...[
            ZagDialog.tile(
              icon: Icons.rocket_launch_rounded,
              iconColor: ZagColours.currentAccent,
              text: 'settings.SubscriptionsPlanMonthly'
                  .tr(args: ['\$0.99/month']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsTrialOneMonth'.tr(),
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
              text: 'settings.SubscriptionsPlanYearly'
                  .tr(args: ['\$4.99/year']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsTrialOneMonth'.tr(),
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
            ZagDialog.tile(
              icon: Icons.all_inclusive_rounded,
              iconColor: ZagColours.currentAccent,
              text: 'settings.SubscriptionsPlanLifetime'
                  .tr(args: ['\$19.99']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsLifetimeOneTime'.tr(),
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
                _purchaseProLifetime();
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
                    'settings.SubscriptionsLegalIntro'.tr(),
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
                          'settings.SubscriptionsTermsOfService'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: ZagColours.accentColor(context),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        'settings.SubscriptionsAnd'.tr(),
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
                          'settings.SubscriptionsPrivacyPolicy'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: ZagColours.accentColor(context),
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
                  'settings.SubscriptionsRestorePurchases'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: ZagColours.accentColor(context),
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
              text: 'settings.SubscriptionsDebugCancel'.tr(),
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
        title: 'settings.SubscriptionsZagreusMegaTitle'.tr(),
        customContent: ZagDialog.content(
          children: [
            Padding(
              padding: ZagDialog.textDialogContentPadding(),
              child: Text(
                'settings.SubscriptionsMegaIncludedSupreme'.tr(),
                style: TextStyle(
                  fontSize: ZagUI.FONT_SIZE_H2,
                  color: ZagColours.textColor(context),
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
          'settings.SubscriptionsMegaIncludedSupremeDowngrade'.tr();
    } else if (isUltra) {
      megaIntro =
          'settings.SubscriptionsMegaIncludedUltra'.tr();
    } else if (isMega) {
      megaIntro =
          'settings.SubscriptionsMegaActiveMessage'.tr();
    } else {
      megaIntro = 'settings.SubscriptionsMegaUnlocks'.tr();
    }

    ZagDialog.dialog(
      context: context,
      title: 'settings.SubscriptionsZagreusMegaTitle'.tr(),
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              megaIntro,
              style: TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
                color: ZagColours.textColor(context),
              ),
            ),
          ),
          if (isMega &&
              ZagreusMega.subscriptionType.toLowerCase().contains('month')) ...[
            const SizedBox(height: 12),
            ZagDialog.tile(
              icon: Icons.autorenew_rounded,
              iconColor: ZagColours.orange,
              text: 'settings.SubscriptionsSwitchToYearly'
                  .tr(args: ['\$14.99/year']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsBestValueSaveMonthly'.tr(),
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
              text: 'settings.SubscriptionsPlanMonthly'
                  .tr(args: ['\$1.99/month']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsTrialOneMonth'.tr(),
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
              text: 'settings.SubscriptionsPlanYearly'
                  .tr(args: ['\$14.99/year']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsTrialOneMonth'.tr(),
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
                    'settings.SubscriptionsLegalIntro'.tr(),
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
                          'settings.SubscriptionsTermsOfService'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: ZagColours.accentColor(context),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        'settings.SubscriptionsAnd'.tr(),
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
                          'settings.SubscriptionsPrivacyPolicy'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: ZagColours.accentColor(context),
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
                  'settings.SubscriptionsRestorePurchases'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: ZagColours.accentColor(context),
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
    if (raw.isEmpty) return 'settings.SubscriptionsPlanNamePro'.tr();
    final lower = raw.toLowerCase();
    if (lower.contains('lifetime')) {
      return 'settings.SubscriptionsPlanNameLifetime'.tr();
    }
    if (lower.contains('year')) {
      return 'settings.SubscriptionsPlanNameYearly'.tr();
    }
    if (lower.contains('month')) {
      return 'settings.SubscriptionsPlanNameMonthly'.tr();
    }
    return raw[0].toUpperCase() + raw.substring(1);
  }

  void _purchasePro(bool isMonthly) async {
    final iapService = RevenueCatService();

    // Check if IAP is available
    if (!iapService.isAvailable) {
      showZagInfoSnackBar(
        title: 'settings.SubscriptionsUnavailableTitle'.tr(),
        message: 'settings.SubscriptionsUnavailableMessage'.tr(),
      );
      return;
    }

    // Attempt real purchase
    showZagInfoSnackBar(
      title: 'settings.SubscriptionsProcessingTitle'.tr(),
      message: 'settings.SubscriptionsProcessingMessage'.tr(),
    );

    final bool success = isMonthly
        ? await iapService.purchaseMonthly()
        : await iapService.purchaseYearly();

    if (success) {
      setState(() {});
    }
  }

  void _purchaseProLifetime() async {
    final iapService = RevenueCatService();

    if (!iapService.isAvailable) {
      showZagInfoSnackBar(
        title: 'settings.SubscriptionsUnavailableTitle'.tr(),
        message: 'settings.SubscriptionsUnavailableMessage'.tr(),
      );
      return;
    }

    showZagInfoSnackBar(
      title: 'settings.SubscriptionsProcessingTitle'.tr(),
      message: 'settings.SubscriptionsProcessingMessage'.tr(),
    );

    final bool success = await iapService.purchaseProLifetime();

    if (success) {
      setState(() {});
    }
  }

  void _purchaseMega(bool isMonthly) async {
    final iapService = RevenueCatService();

    if (!iapService.isAvailable) {
      showZagInfoSnackBar(
        title: 'settings.SubscriptionsUnavailableTitle'.tr(),
        message: 'settings.SubscriptionsUnavailableMessage'.tr(),
      );
      return;
    }

    showZagInfoSnackBar(
      title: 'settings.SubscriptionsProcessingTitle'.tr(),
      message: 'settings.SubscriptionsProcessingMessage'.tr(),
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
        title: 'settings.SubscriptionsUnavailableTitle'.tr(),
        message: 'settings.SubscriptionsUnavailableMessage'.tr(),
      );
      return;
    }

    showZagInfoSnackBar(
      title: 'settings.SubscriptionsProcessingTitle'.tr(),
      message: 'settings.SubscriptionsProcessingMessage'.tr(),
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
      title: 'settings.SubscriptionsProRevokedTitle'.tr(),
      message: 'settings.SubscriptionsBootModuleRestored'
          .tr(args: [BIOSDatabase.BOOT_MODULE.read().name]),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showZagInfoSnackBar(
        title: 'zagreus.Error'.tr(),
        message: 'settings.SubscriptionsOpenLinkFailed'.tr(),
      );
    }
  }

  void _showUltraDialog(BuildContext context) {
    final bool isUltra = ZagreusUltra.isEnabled;
    final bool isSupreme = ZagreusSupreme.isEnabled;

    final String introText = isSupreme
        ? 'settings.SubscriptionsUltraIncludedSupreme'.tr()
        : isUltra
            ? 'settings.SubscriptionsUltraActiveMessage'.tr()
            : 'settings.SubscriptionsUltraUnlocks'.tr();

    ZagDialog.dialog(
      context: context,
      title: 'settings.SubscriptionsZagreusUltraTitle'.tr(),
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
              text: 'settings.SubscriptionsSwitchToYearly'
                  .tr(args: ['\$34.99/year']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsBestValueSaveOverMonthly'.tr(),
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
              text: 'settings.SubscriptionsPlanMonthly'
                  .tr(args: ['\$3.99/month']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsTrialTwoWeeks'.tr(),
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
              text: 'settings.SubscriptionsPlanYearly'
                  .tr(args: ['\$34.99/year']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsTrialTwoWeeks'.tr(),
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
                    'settings.SubscriptionsLegalIntro'.tr(),
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
                          'settings.SubscriptionsTermsOfService'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: ZagColours.accentColor(context),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        'settings.SubscriptionsAnd'.tr(),
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
                          'settings.SubscriptionsPrivacyPolicy'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: ZagColours.accentColor(context),
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
                  'settings.SubscriptionsRestorePurchases'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: ZagColours.accentColor(context),
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
      title: 'settings.SubscriptionsZagreusSupremeTitle'.tr(),
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              isSupreme
                  ? 'settings.SubscriptionsSupremeActiveMessage'.tr()
                  : 'settings.SubscriptionsSupremeUnlocks'.tr(),
              style: const TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
              ),
            ),
          ),
          if (!isSupreme) ...[
            ZagDialog.tile(
              icon: Icons.auto_awesome_rounded,
              iconColor: ZagColours.gold,
              text: 'settings.SubscriptionsPlanMonthly'
                  .tr(args: ['\$14.99/month']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsSupremeIncludesAll'.tr(),
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
              text: 'settings.SubscriptionsPlanYearly'
                  .tr(args: ['\$149.99/year']),
              subtitle: RichText(
                text: TextSpan(
                  text: 'settings.SubscriptionsBestValueSaveOver15'.tr(),
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
                    'settings.SubscriptionsLegalIntro'.tr(),
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
                          'settings.SubscriptionsTermsOfService'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: ZagColours.accentColor(context),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        'settings.SubscriptionsAnd'.tr(),
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
                          'settings.SubscriptionsPrivacyPolicy'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: ZagColours.accentColor(context),
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
                  'settings.SubscriptionsRestorePurchases'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: ZagColours.accentColor(context),
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
        title: 'settings.SubscriptionsUnavailableTitle'.tr(),
        message: 'settings.SubscriptionsUnavailableMessage'.tr(),
      );
      return;
    }

    showZagInfoSnackBar(
      title: 'settings.SubscriptionsProcessingTitle'.tr(),
      message: 'settings.SubscriptionsProcessingMessage'.tr(),
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
    _authSubscription?.cancel();
    super.dispose();
  }


}
