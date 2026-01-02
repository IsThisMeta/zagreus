import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/utils/zagreus_supreme.dart';
import 'package:zagreus/supabase/subscription_shares.dart';
import 'package:zagreus/supabase/auth.dart';

class SharesManagementRoute extends StatefulWidget {
  const SharesManagementRoute({Key? key}) : super(key: key);

  @override
  State<SharesManagementRoute> createState() => _State();
}

class _State extends State<SharesManagementRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<SubscriptionShare> _grantedShares = [];
  List<SubscriptionShare> _receivedShares = [];
  int _remainingShares = 0;
  bool _isLoading = true;
  String? _currentProductId;
  DateTime? _currentExpiresAt;
  bool _accountLinkLoaded = false;
  bool _hasLinkedSubscription = false;

  @override
  void initState() {
    super.initState();
    _loadShares();
  }

  Future<void> _loadShares() async {
    setState(() => _isLoading = true);

    try {
      if (ZagSupabaseAuth().isSignedIn) {
        final row = await Supabase.instance.client
            .from('account_subscriptions')
            .select('tier,expires_at')
            .maybeSingle();

        if (row != null) {
          final tier = row['tier'] as String?;
          final expiresAtRaw = row['expires_at'];
          _currentProductId = tier;
          _currentExpiresAt = expiresAtRaw is String ? DateTime.tryParse(expiresAtRaw) : null;
          _hasLinkedSubscription = tier != null && tier.isNotEmpty;
        } else {
          _currentProductId = null;
          _currentExpiresAt = null;
          _hasLinkedSubscription = false;
        }
      } else {
        _currentProductId = null;
        _currentExpiresAt = null;
        _hasLinkedSubscription = false;
      }
    } catch (_) {
      _currentProductId = null;
      _currentExpiresAt = null;
      _hasLinkedSubscription = false;
    } finally {
      _accountLinkLoaded = true;
    }

    final receivedFuture = ZagSupabaseShares().getReceivedShares();
    final grantedFuture =
        _currentProductId != null ? ZagSupabaseShares().getGrantedShares() : Future.value(<SubscriptionShare>[]);
    final remainingFuture =
        _currentProductId != null ? ZagSupabaseShares().getRemainingShares(_currentProductId!) : Future.value(0);

    final received = await receivedFuture;
    final granted = await grantedFuture;
    final remaining = await remainingFuture;

    setState(() {
      _receivedShares = received;
      _grantedShares = granted;
      _remainingShares = remaining;
      _isLoading = false;
    });
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
      title: 'settings.SubscriptionsSharingTitle'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    if (!ZagSupabaseAuth().isSignedIn) {
      return ZagListView(
        controller: scrollController,
        children: [
          ZagBlock(
            title: 'settings.SubscriptionsSharingSignInRequiredTitle'.tr(),
            body: [
              TextSpan(
                text:
                    'settings.SubscriptionsSharingSignInRequiredMessage'.tr(),
              ),
            ],
          ),
        ],
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final bool canShare =
        _hasLinkedSubscription && (_currentProductId == 'ultra' || _currentProductId == 'mega' || _currentProductId == 'supreme');
    final int totalShares = switch (_currentProductId) {
      'supreme' => 10,
      'ultra' => 5,
      'mega' => 1,
      _ => 0,
    };
    final int usedShares = _grantedShares.length;

    return ZagListView(
      controller: scrollController,
      children: [
        // Received shares (for shared Pro users)
        if (_receivedShares.isNotEmpty) ...[
          ZagBlock(
            title: 'settings.SubscriptionsSharingSharedWithYouTitle'.tr(),
            body: [
              TextSpan(
                text: 'settings.SubscriptionsSharingSharedWithYouMessage'
                    .tr(args: [_formatDate(_receivedShares.first.ownerExpiresAt)]),
              ),
            ],
            trailing: ZagIconButton(
              icon: Icons.supervisor_account_rounded,
              color: ZagColours.currentAccent,
            ),
          ),
        ],

        if (_accountLinkLoaded &&
            !_hasLinkedSubscription &&
            (ZagreusMega.isEnabled || ZagreusUltra.isEnabled || ZagreusSupreme.isEnabled) &&
            _receivedShares.isEmpty) ...[
          ZagBlock(
            title: 'settings.SubscriptionsSharingLinkRequiredTitle'.tr(),
            body: [
              TextSpan(
                text: 'settings.SubscriptionsSharingLinkRequiredMessage'.tr(),
              ),
            ],
            trailing: ZagIconButton(
              icon: Icons.link_rounded,
              color: ZagColours.currentAccent,
            ),
          ),
        ],

        // Share management (for Mega/Ultra users)
        if (canShare) ...[
          ZagBlock(
            title: 'settings.SubscriptionsSharingYourSharesTitle'.tr(),
            body: [
              TextSpan(
                text: 'settings.SubscriptionsSharingSharesUsed'
                    .tr(args: [usedShares.toString(), totalShares.toString()]),
              ),
            ],
            trailing: ZagIconButton(
              icon: _remainingShares > 0
                  ? Icons.person_add_rounded
                  : Icons.people_rounded,
              color: ZagreusUltra.isEnabled
                  ? ZagColours.purple
                  : ZagColours.orange,
            ),
            onTap: _remainingShares > 0 ? () => _showGrantShareDialog() : null,
          ),

          // List of granted shares
          if (_grantedShares.isNotEmpty)
            ..._grantedShares.map((share) => ZagBlock(
              title: share.sharedWithEmail,
              body: [
                TextSpan(
                  text: share.isActive
                      ? 'settings.SubscriptionsSharingStatusActive'
                          .tr(args: [_formatDate(share.ownerExpiresAt)])
                      : 'settings.SubscriptionsSharingStatusPending'
                          .tr(args: [_formatDate(share.ownerExpiresAt)]),
                ),
              ],
              trailing: ZagIconButton(
                icon: Icons.close_rounded,
                color: ZagColours.red,
              ),
              onTap: () => _confirmRevokeShare(share),
            )),
        ],

        // Empty state for Mega/Ultra with no shares
        if (canShare && _grantedShares.isEmpty) ...[
          ZagBlock(
            title: 'settings.SubscriptionsSharingShareProTitle'.tr(),
            body: [
              TextSpan(
                text: ZagreusUltra.isEnabled
                    ? 'settings.SubscriptionsSharingShareProUltra'.tr()
                    : 'settings.SubscriptionsSharingShareProMega'.tr(),
              ),
            ],
            trailing: ZagIconButton(
              icon: Icons.person_add_rounded,
              color: ZagreusUltra.isEnabled ? ZagColours.purple : ZagColours.orange,
            ),
            onTap: () => _showGrantShareDialog(),
          ),
        ],

        // Info for non-sharing tiers
        if (!canShare && _receivedShares.isEmpty) ...[
          ZagBlock(
            title: 'settings.SubscriptionsSharingUpgradeToShareTitle'.tr(),
            body: [
              TextSpan(
                text: 'settings.SubscriptionsSharingUpgradeToShareMessage'.tr(),
              ),
            ],
            trailing: ZagIconButton(
              icon: Icons.arrow_upward_rounded,
              color: ZagColours.currentAccent,
            ),
          ),
        ],
      ],
    );
  }

  void _showGrantShareDialog() {
    final emailController = TextEditingController();

    ZagDialog.dialog(
      context: context,
      title: 'settings.SubscriptionsSharingGrantDialogTitle'.tr(),
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'settings.SubscriptionsSharingGrantPrompt'.tr(),
                  style: TextStyle(
                    fontSize: ZagUI.FONT_SIZE_H2,
                    color: ZagColours.textColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'settings.SubscriptionsSharingEmailHint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ZagDialog.tile(
            icon: Icons.person_add_rounded,
            iconColor: ZagColours.currentAccent,
            text: 'settings.SubscriptionsSharingGrantAction'.tr(),
            onTap: () {
              Navigator.of(context).pop();
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                _grantShareByEmail(email);
              }
            },
          ),
        ],
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  Future<void> _grantShareByEmail(String email) async {
    if (_currentProductId == null) {
      showZagErrorSnackBar(
        title: 'zagreus.Error'.tr(),
        message: 'settings.SubscriptionsSharingNoLinkedSubscription'.tr(),
      );
      return;
    }

    showZagInfoSnackBar(
      title: 'settings.SubscriptionsSharingGrantingTitle'.tr(),
      message: 'settings.SubscriptionsSharingCreatingShare'.tr(),
    );

    final expiresAt = _currentExpiresAt ?? DateTime.now();

    final result = await ZagSupabaseShares().grantShareByEmail(
      email: email,
      productId: _currentProductId!,
      expiresAt: expiresAt,
    );

    if (result.success) {
      showZagSuccessSnackBar(
        title: 'settings.SubscriptionsSharingSuccessTitle'.tr(),
        message: 'settings.SubscriptionsSharingSharedWithEmail'
            .tr(args: [email]),
      );
      _loadShares(); // Reload shares
    } else {
      showZagErrorSnackBar(
        title: 'settings.SubscriptionsSharingFailedTitle'.tr(),
        message: result.error ??
            'settings.SubscriptionsSharingCouldNotGrant'.tr(),
      );
    }
  }

  void _confirmRevokeShare(SubscriptionShare share) {
    ZagDialog.dialog(
      context: context,
      title: 'settings.SubscriptionsSharingRevokeTitle'.tr(),
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              'settings.SubscriptionsSharingRevokePrompt'
                  .tr(args: [share.sharedWithEmail]),
              style: TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
                color: ZagColours.textColor(context),
              ),
            ),
          ),
          ZagDialog.tile(
            icon: Icons.close_rounded,
            iconColor: ZagColours.red,
            text: 'settings.SubscriptionsSharingRevokeAction'.tr(),
            onTap: () {
              Navigator.of(context).pop();
              _revokeShare(share);
            },
          ),
        ],
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  Future<void> _revokeShare(SubscriptionShare share) async {
    final success = await ZagSupabaseShares().revokeShare(share.id);

    if (success) {
      showZagSuccessSnackBar(
        title: 'settings.SubscriptionsSharingRevokedTitle'.tr(),
        message: 'settings.SubscriptionsSharingRevokedMessage'.tr(),
      );
      _loadShares(); // Reload shares
    } else {
      showZagErrorSnackBar(
        title: 'settings.SubscriptionsSharingFailedTitle'.tr(),
        message: 'settings.SubscriptionsSharingCouldNotRevoke'.tr(),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays > 30) {
      return 'settings.SubscriptionsSharingTimeMonths'
          .tr(args: [(diff.inDays ~/ 30).toString()]);
    } else if (diff.inDays > 0) {
      return 'settings.SubscriptionsSharingTimeDays'
          .tr(args: [diff.inDays.toString()]);
    } else if (diff.inHours > 0) {
      return 'settings.SubscriptionsSharingTimeHours'
          .tr(args: [diff.inHours.toString()]);
    } else {
      return 'settings.SubscriptionsSharingTimeSoon'.tr();
    }
  }
}
