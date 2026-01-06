import 'package:flutter/material.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/widgets/sheets/download_client/sheet.dart';
import 'package:zagreus/widgets/ui.dart';

class DownloadClientButton extends StatelessWidget {
  const DownloadClientButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (_shouldShow) {
      return ZagIconButton.appBar(
        icon: ZagIcons.DOWNLOAD,
        onPressed: DownloadClientSheet().show,
      );
    }
    return const SizedBox();
  }

  bool get _shouldShow {
    final profile = ZagProfile.current;
    return profile.sabnzbdEnabled || profile.nzbgetEnabled;
  }
}
