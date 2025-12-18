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
      title: 'Subscription Sharing',
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    if (!ZagSupabaseAuth().isSignedIn) {
      return ZagListView(
        controller: scrollController,
        children: [
          ZagBlock(
            title: 'Sign In Required',
            body: [
              TextSpan(text: 'Sign in to manage subscription shares'),
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
            title: 'Shared With You',
            body: [
              TextSpan(
                text: 'You have Pro access shared by another user • Expires ${_formatDate(_receivedShares.first.ownerExpiresAt)}',
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
            title: 'Link Required',
            body: [
              TextSpan(
                text: 'To share your subscription, link your account first in the Subscriptions screen.',
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
            title: 'Your Shares',
            body: [
              TextSpan(
                text: '$usedShares of $totalShares shares used',
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
                      ? 'Active • Expires ${_formatDate(share.ownerExpiresAt)}'
                      : 'Pending sign-in • Expires ${_formatDate(share.ownerExpiresAt)}',
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
            title: 'Share Pro Access',
            body: [
              TextSpan(
                text: ZagreusUltra.isEnabled
                    ? 'Share Pro access with up to 5 friends or family members'
                    : 'Share Pro access with 1 friend or family member',
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
            title: 'Upgrade to Share',
            body: [
              TextSpan(
                text: 'Mega subscribers can share Pro with 1 person.\nUltra subscribers can share Pro with 5 people.',
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
      title: 'Share Pro Access',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter the email address of the person you want to share Pro access with:',
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
                    hintText: 'email@example.com',
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
            text: 'Grant Access',
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
        title: 'Error',
        message: 'No linked subscription found',
      );
      return;
    }

    showZagInfoSnackBar(
      title: 'Granting Access',
      message: 'Creating share...',
    );

    final expiresAt = _currentExpiresAt ?? DateTime.now();

    final result = await ZagSupabaseShares().grantShareByEmail(
      email: email,
      productId: _currentProductId!,
      expiresAt: expiresAt,
    );

    if (result.success) {
      showZagSuccessSnackBar(
        title: 'Success',
        message: 'Pro access shared with $email',
      );
      _loadShares(); // Reload shares
    } else {
      showZagErrorSnackBar(
        title: 'Failed',
        message: result.error ?? 'Could not grant share',
      );
    }
  }

  void _confirmRevokeShare(SubscriptionShare share) {
    ZagDialog.dialog(
      context: context,
      title: 'Revoke Share?',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: ZagDialog.textDialogContentPadding(),
            child: Text(
              'Remove Pro access for ${share.sharedWithEmail}?',
              style: TextStyle(
                fontSize: ZagUI.FONT_SIZE_H2,
                color: ZagColours.textColor(context),
              ),
            ),
          ),
          ZagDialog.tile(
            icon: Icons.close_rounded,
            iconColor: ZagColours.red,
            text: 'Revoke Access',
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
        title: 'Share Revoked',
        message: 'Pro access removed',
      );
      _loadShares(); // Reload shares
    } else {
      showZagErrorSnackBar(
        title: 'Failed',
        message: 'Could not revoke share',
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30} months';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} days';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours';
    } else {
      return 'soon';
    }
  }
}
