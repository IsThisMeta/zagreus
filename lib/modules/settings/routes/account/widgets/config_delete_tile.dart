import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/supabase/database.dart';
import 'package:zagreus/supabase/storage.dart';
import 'package:zagreus/supabase/types.dart';
import 'package:zagreus/modules/settings.dart';

class SettingsAccountDeleteConfigurationTile extends StatefulWidget {
  const SettingsAccountDeleteConfigurationTile({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SettingsAccountDeleteConfigurationTile> {
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;

  void updateState(ZagLoadingState state) {
    if (mounted) setState(() => _loadingState = state);
  }

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'settings.DeleteCloudBackup'.tr(),
      body: [TextSpan(text: 'settings.DeleteCloudBackupDescription'.tr())],
      trailing: ZagIconButton(
        icon: ZagIcons.CLOUD_DELETE,
        loadingState: _loadingState,
      ),
      onTap: () async => _delete(context),
    );
  }

  Future<void> _delete(BuildContext context) async {
    if (_loadingState == ZagLoadingState.ACTIVE) return;
    updateState(ZagLoadingState.ACTIVE);

    try {
      List<ZagSupabaseBackupDocument> documents =
          await ZagSupabaseDatabase().getBackupEntries();
      Tuple2<bool, ZagSupabaseBackupDocument?> result =
          await SettingsDialogs().getBackupFromCloud(context, documents);
      if (result.item1) {
        await ZagSupabaseDatabase()
            .deleteBackupEntry(result.item2!.id)
            .then((_) => ZagSupabaseStorage().deleteBackup(result.item2!.id))
            .then((_) {
          updateState(ZagLoadingState.INACTIVE);
          showZagSuccessSnackBar(
            title: 'settings.DeleteCloudBackupSuccess'.tr(),
            message: result.item2!.title!
                .replaceAll('\n', ' ${ZagUI.TEXT_EMDASH} '),
          );
        }).catchError((error, stack) {
          ZagLogger().error('Supabase Backup Deletion Failed', error, stack);
          showZagErrorSnackBar(
            title: 'settings.DeleteCloudBackupFailure'.tr(),
            error: error,
          );
        });
      }
    } catch (error, stack) {
      ZagLogger().error('Supabase Backup Deletion Failed', error, stack);
      showZagErrorSnackBar(
        title: 'settings.DeleteCloudBackupFailure'.tr(),
        error: error,
      );
    }
    updateState(ZagLoadingState.INACTIVE);
  }
}
