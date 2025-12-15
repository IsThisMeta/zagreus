import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/modules/settings.dart';

class ChangeEmailTile extends StatefulWidget {
  const ChangeEmailTile({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ChangeEmailTile> {
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;

  void updateState(ZagLoadingState state) {
    if (mounted) setState(() => _loadingState = state);
  }

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'settings.UpdateEmail'.tr(),
      trailing: ZagIconButton(
        icon: ZagIcons.EMAIL,
        loadingState: _loadingState,
      ),
      onTap: _update,
    );
  }

  Future<void> _update() async {
    if (_loadingState == ZagLoadingState.ACTIVE) return;
    updateState(ZagLoadingState.ACTIVE);

    Tuple3<bool, String, String> _result =
        await SettingsDialogs().updateAccountEmail(context);
    if (_result.item1) {
      await ZagSupabaseAuth()
          .updateEmail(_result.item2, _result.item3)
          .then((res) {
        if (res.state) {
          showZagSuccessSnackBar(
            title: 'settings.EmailUpdated'.tr(),
            message: _result.item2,
          );
        } else {
          updateState(ZagLoadingState.INACTIVE);
          showZagErrorSnackBar(
            title: 'settings.FailedToUpdateEmail'.tr(),
            message: res.error?.message ?? 'zagreus.UnknownError'.tr(),
          );
        }
      });
    }
    updateState(ZagLoadingState.INACTIVE);
  }
}
