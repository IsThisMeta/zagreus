import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/config.dart';
import 'package:zagreus/supabase/database.dart';
import 'package:zagreus/supabase/storage.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/utils/encryption.dart';
import 'package:zagreus/utils/uuid.dart';

class SettingsAccountBackupConfigurationTile extends StatefulWidget {
  const SettingsAccountBackupConfigurationTile({
    Key? key,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<SettingsAccountBackupConfigurationTile> {
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;

  void updateState(ZagLoadingState state) {
    if (mounted) setState(() => _loadingState = state);
  }

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'settings.BackupToCloud'.tr(),
      body: [TextSpan(text: 'settings.BackupToCloudDescription'.tr())],
      trailing: ZagIconButton(
        icon: ZagIcons.CLOUD_UPLOAD,
        loadingState: _loadingState,
      ),
      onTap: () async => _backup(context),
    );
  }

  Future<void> _backup(BuildContext context) async {
    if (_loadingState == ZagLoadingState.ACTIVE) return;
    updateState(ZagLoadingState.ACTIVE);

    try {
      // Ask for encryption password
      Tuple2<bool, String> _values = 
          await SettingsDialogs().backupConfiguration(context);
      
      if (_values.item1) {
        String decrypted = ZagConfig().export();
        String encrypted = ZagEncryption().encrypt(_values.item2, decrypted);
        int timestamp = DateTime.now().millisecondsSinceEpoch;
        String id = ZagUUID().generate();
        String format = 'MMMM dd, yyyy\nhh:mm:ss a';
        String title = DateFormat(format).format(DateTime.now());

        await ZagSupabaseDatabase()
            .addBackupEntry(id, timestamp, title: title)
            .then((_) => ZagSupabaseStorage().uploadBackup(encrypted, id))
          .then((_) {
        updateState(ZagLoadingState.INACTIVE);
        showZagSuccessSnackBar(
          title: 'settings.BackupToCloudSuccess'.tr(),
          message: title.replaceAll('\n', ' ${ZagUI.TEXT_EMDASH} '),
        );
      }).catchError((error, stack) {
        ZagLogger().error(
          'Failed to backup configuration to the cloud',
          error,
          stack,
        );
        showZagErrorSnackBar(
          title: 'settings.BackupToCloudFailure'.tr(),
          error: error,
        );
      });
      }
    } catch (error, stack) {
      ZagLogger().error('Backup Failed', error, stack);
      showZagErrorSnackBar(
        title: 'settings.BackupToCloudFailure'.tr(),
        error: error,
      );
    }
    updateState(ZagLoadingState.INACTIVE);
  }
}
