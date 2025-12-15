import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/router/router.dart';

class DeleteAccountTile extends StatefulWidget {
  const DeleteAccountTile({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<DeleteAccountTile> {
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;

  void updateState(ZagLoadingState state) {
    if (mounted) setState(() => _loadingState = state);
  }

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'settings.DeleteAccount'.tr(),
      body: [
        TextSpan(text: 'settings.DeleteAccountDescription'.tr()),
      ],
      trailing: ZagIconButton(
        icon: ZagIcons.DELETE,
        color: ZagColours.red,
        loadingState: _loadingState,
      ),
      onTap: _delete,
    );
  }

  Future<void> _delete() async {
    if (_loadingState == ZagLoadingState.ACTIVE) return;
    updateState(ZagLoadingState.ACTIVE);

    Tuple2<bool, String> _result =
        await SettingsDialogs().confirmDeleteAccount(context);
    if (_result.item1) {
      await ZagSupabaseAuth().deleteUser(_result.item2).then((res) {
        if (res.state) {
          showZagSuccessSnackBar(
            title: 'settings.AccountDeleted'.tr(),
            message: 'settings.AccountDeletedMessage'.tr(),
          );
          ZagRouter().popSafely();
        } else {
          updateState(ZagLoadingState.INACTIVE);
          showZagErrorSnackBar(
            title: 'settings.FailedToDeleteAccount'.tr(),
            message: res.error?.message ?? 'zagreus.UnknownError'.tr(),
          );
        }
      });
    }
    updateState(ZagLoadingState.INACTIVE);
  }
}
