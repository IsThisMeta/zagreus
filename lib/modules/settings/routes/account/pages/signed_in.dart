import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/modules/settings/routes/account/widgets/config_backup_tile.dart';
import 'package:zagreus/modules/settings/routes/account/widgets/config_delete_tile.dart';
import 'package:zagreus/modules/settings/routes/account/widgets/config_restore_tile.dart';

class SettingsAccountSignedInPage extends StatefulWidget {
  final ScrollController scrollController;

  const SettingsAccountSignedInPage({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SettingsAccountSignedInPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        ZagButton.text(
          text: 'settings.SignOut'.tr(),
          icon: Icons.logout_rounded,
          color: ZagColours.red,
          onTap: () async {
            bool result =
                await SettingsDialogs().confirmAccountSignOut(context);
            if (result)
              ZagSupabaseAuth()
                  .signOut()
                  .then((_) => showZagSuccessSnackBar(
                        title: 'settings.SignedOutSuccess'.tr(),
                        message: 'settings.SignedOutSuccessMessage'.tr(),
                      ))
                  .catchError((error, stack) {
                ZagLogger().error('Failed to sign out', error, stack);
                showZagErrorSnackBar(
                  title: 'settings.SignedOutFailure'.tr(),
                  error: error,
                );
              });
          },
        ),
      ],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: widget.scrollController,
      children: const [
        SettingsAccountBackupConfigurationTile(),
        SettingsAccountRestoreConfigurationTile(),
        SettingsAccountDeleteConfigurationTile(),
      ],
    );
  }
}
