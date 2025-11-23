import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_mega.dart';
import 'package:zagreus/utils/zagreus_ultra.dart';
import 'package:zagreus/supabase/subscription_shares.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/database/tables/zagreus.dart';

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

  @override
  void initState() {
    super.initState();
    _loadShares();
  }

  Future<void> _loadShares() async {
    setState(() => _isLoading = true);

    // Determine current product ID
    if (ZagreusUltra.isEnabled) {
      _currentProductId = 'ultra';
    } else if (ZagreusMega.isEnabled) {
      _currentProductId = 'mega';
    }

    if (_currentProductId != null) {
      final remaining = await ZagSupabaseShares().getRemainingShares(_currentProductId!);
      final granted = await ZagSupabaseShares().getGrantedShares();
      setState(() {
        _remainingShares = remaining;
        _grantedShares = granted;
      });
    }

    final received = await ZagSupabaseShares().getReceivedShares();

    setState(() {
      _receivedShares = received;
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

    final bool canShare = ZagreusUltra.isEnabled || ZagreusMega.isEnabled;
    final int totalShares = ZagreusUltra.isEnabled ? 5 : (ZagreusMega.isEnabled ? 1 : 0);
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
                text: 'You have Pro access shared from ${_receivedShares.first.sharedWithEmail ?? "another user"}',
              ),
            ],
            trailing: ZagIconButton(
              icon: Icons.supervisor_account_rounded,
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
              title: share.sharedWithEmail ?? 'Shared User',
              body: [
                TextSpan(
                  text: 'Active • Expires ${_formatDate(share.ownerExpiresAt)}',
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
    final TextEditingController emailController = TextEditingController();

    ZagDialog.dialog(
      context: context,
      title: 'Grant Pro Share',
      customContent: ZagDialog.content(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter the email of the person you want to share Pro access with:',
                  style: const TextStyle(fontSize: ZagUI.FONT_SIZE_H2),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                    hintText: 'friend@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ZagDialog.tile(
            icon: Icons.send_rounded,
            iconColor: ZagColours.currentAccent,
            text: 'Send Invite',
            onTap: () {
              Navigator.of(context).pop();
              _grantShare(emailController.text.trim());
            },
          ),
        ],
      ),
      contentPadding: ZagDialog.listDialogContentPadding(),
    );
  }

  Future<void> _grantShare(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      showZagInfoSnackBar(
        title: 'Invalid Email',
        message: 'Please enter a valid email address',
      );
      return;
    }

    if (_currentProductId == null) {
      showZagInfoSnackBar(
        title: 'Error',
        message: 'No active Mega or Ultra subscription',
      );
      return;
    }

    showZagInfoSnackBar(
      title: 'Sending Invite',
      message: 'Granting Pro access...',
    );

    // Get expiry from local tier
    DateTime? expiresAt;
    if (ZagreusUltra.isEnabled) {
      final expiryString = ZagreusDatabase.ZAGREUS_ULTRA_EXPIRY.read();
      if (expiryString.isNotEmpty) {
        expiresAt = DateTime.parse(expiryString);
      }
    } else if (ZagreusMega.isEnabled) {
      final expiryString = ZagreusDatabase.ZAGREUS_MEGA_EXPIRY.read();
      if (expiryString.isNotEmpty) {
        expiresAt = DateTime.parse(expiryString);
      }
    }

    if (expiresAt == null) {
      showZagInfoSnackBar(
        title: 'Error',
        message: 'Could not determine subscription expiry',
      );
      return;
    }

    final result = await ZagSupabaseShares().grantShare(
      recipientEmail: email,
      productId: _currentProductId!,
      expiresAt: expiresAt,
    );

    if (result.success) {
      showZagInfoSnackBar(
        title: 'Share Granted',
        message: 'Pro access shared with $email',
      );
      _loadShares(); // Reload shares
    } else {
      showZagInfoSnackBar(
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
              'Remove Pro access for ${share.sharedWithEmail ?? "this user"}?',
              style: const TextStyle(fontSize: ZagUI.FONT_SIZE_H2),
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
      showZagInfoSnackBar(
        title: 'Share Revoked',
        message: 'Pro access removed',
      );
      _loadShares(); // Reload shares
    } else {
      showZagInfoSnackBar(
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
