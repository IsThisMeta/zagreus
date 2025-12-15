import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/supabase/core.dart';
import 'package:zagreus/modules/settings/routes/account/widgets/change_email_tile.dart';
import 'package:zagreus/modules/settings/routes/account/widgets/change_password_tile.dart';
import 'package:zagreus/modules/settings/routes/account/widgets/delete_account_tile.dart';

class AccountSettingsRoute extends StatefulWidget {
  const AccountSettingsRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<AccountSettingsRoute> createState() => _State();
}

class _State extends State<AccountSettingsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      title: 'settings.AccountSettings'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        _currentEmailSection(),
        const ChangeEmailTile(),
        const ChangePasswordTile(),
        const DeleteAccountTile(),
      ],
    );
  }

  Widget _currentEmailSection() {
    final user = ZagSupabase.client.auth.currentUser;
    final email = user?.email ?? 'Unknown';
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Email',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email_rounded,
                  size: 20,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
