import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/router.dart';

class ChangePasswordTile extends StatefulWidget {
  const ChangePasswordTile({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ChangePasswordTile> {
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;

  void updateState(ZagLoadingState state) {
    if (mounted) setState(() => _loadingState = state);
  }

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'settings.UpdatePassword'.tr(),
      trailing: ZagIconButton(
        icon: ZagIcons.PASSWORD,
        loadingState: _loadingState,
      ),
      onTap: _delete,
    );
  }

  Future<void> _delete() async {
    if (_loadingState == ZagLoadingState.ACTIVE) return;
    updateState(ZagLoadingState.ACTIVE);

    Tuple3<bool, String, String> _result =
        await SettingsDialogs().updateAccountPassword(context);
    if (_result.item1) {
      await ZagSupabaseAuth()
          .updatePassword(_result.item2, _result.item3)
          .then((res) {
        if (res.state) {
          showZagSuccessSnackBar(
            title: 'settings.PasswordUpdated'.tr(),
            message: 'settings.PleaseSignInAgain'.tr(),
          );
          ZagRouter().popSafely();
          ZagSupabaseAuth().signOut();
        } else {
          updateState(ZagLoadingState.INACTIVE);
          showZagErrorSnackBar(
            title: 'settings.FailedToUpdatePassword'.tr(),
            message: res.error?.message ?? 'zagreus.UnknownError'.tr(),
          );
        }
      });
    }
    updateState(ZagLoadingState.INACTIVE);
  }
}
