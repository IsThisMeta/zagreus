import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/settings/routes/account/pages.dart';
import 'package:zagreus/router/routes/settings.dart';

class AccountRoute extends StatefulWidget {
  const AccountRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<AccountRoute> createState() => _State();
}

class _State extends State<AccountRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      title: 'settings.Account'.tr(),
      scrollControllers: [scrollController],
      actions: [
        StreamBuilder(
          stream: ZagSupabaseAuth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return ZagIconButton(
                icon: Icons.help_outline_rounded,
                onPressed: () async {
                  SettingsDialogs().accountHelpMessage(context);
                },
              );
            }
            return ZagIconButton(
              icon: Icons.settings_rounded,
              onPressed: SettingsRoutes.ACCOUNT_SETTINGS.go,
            );
          },
        ),
      ],
    );
  }

  Widget _body() {
    return StreamBuilder(
      stream: ZagSupabaseAuth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return SettingsAccountSignedOutPage(
            scrollController: scrollController,
          );
        }
        return SettingsAccountSignedInPage(
          scrollController: scrollController,
        );
      },
    );
  }
}
