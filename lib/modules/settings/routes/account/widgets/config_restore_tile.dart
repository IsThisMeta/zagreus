import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/config.dart';
import 'package:zagreus/supabase/database.dart';
import 'package:zagreus/supabase/storage.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/utils/encryption.dart';

class SettingsAccountRestoreConfigurationTile extends StatefulWidget {
  const SettingsAccountRestoreConfigurationTile({
    Key? key,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<SettingsAccountRestoreConfigurationTile> {
  ZagLoadingState _loadingState = ZagLoadingState.INACTIVE;

  void updateState(ZagLoadingState state) {
    if (mounted) setState(() => _loadingState = state);
  }

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'settings.RestoreFromCloud'.tr(),
      body: [TextSpan(text: 'settings.RestoreFromCloudDescription'.tr())],
      trailing: ZagIconButton(
        icon: ZagIcons.CLOUD_DOWNLOAD,
        loadingState: _loadingState,
      ),
      onTap: () async => _restore(context),
    );
  }

  Future<void> _restore(BuildContext context) async {
    if (_loadingState == ZagLoadingState.ACTIVE) return;
    updateState(ZagLoadingState.ACTIVE);
    try {
      final docs = await ZagSupabaseDatabase().getBackupEntries();
      final result = await SettingsDialogs().getBackupFromCloud(context, docs);

      if (result.item1) {
        String? id = result.item2!.id;
        String? encrypted = await ZagSupabaseStorage().downloadBackup(id);
        if (encrypted != null) {
          await _decryptBackup(context, encrypted);
        }
      }
    } catch (error, stack) {
      ZagLogger().error('Failed to restore cloud backup', error, stack);
      showZagErrorSnackBar(
        title: 'settings.RestoreFromCloudFailure'.tr(),
        error: error,
      );
    }
    updateState(ZagLoadingState.INACTIVE);
  }

  Future<void> _decryptBackup(BuildContext context, String encrypted) async {
    Tuple2<bool, String> _key = await SettingsDialogs().decryptBackup(context);
    if (_key.item1) {
      try {
        String decrypted = ZagEncryption().decrypt(_key.item2, encrypted);
        await ZagConfig().import(context, decrypted);
        showZagSuccessSnackBar(
          title: 'settings.RestoreFromCloudSuccess'.tr(),
          message: 'settings.RestoreFromCloudSuccessMessage'.tr(),
        );
      } catch (_) {
        showZagErrorSnackBar(
          title: 'settings.RestoreFromCloudFailure'.tr(),
          message: 'zagreus.IncorrectEncryptionKey'.tr(),
          showButton: true,
          buttonText: 'zagreus.Retry'.tr(),
          buttonOnPressed: () async => _decryptBackup(context, encrypted),
        );
      }
    }
  }
}
