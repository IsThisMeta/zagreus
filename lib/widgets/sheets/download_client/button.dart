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
    if (_shouldShow(context)) {
      return ZagIconButton.appBar(
        icon: ZagIcons.DOWNLOAD,
        onPressed: DownloadClientSheet().show,
      );
    }
    return const SizedBox();
  }

  bool _shouldShow(BuildContext context) {
    final profile = ZagProfile.current;
    // Don't show if no download clients are enabled
    if (!profile.sabnzbdEnabled && !profile.nzbgetEnabled) {
      return false;
    }

    // Don't show if we're already inside a download module or settings
    final routeName = ModalRoute.of(context)?.settings.name ?? '';
    if (routeName.startsWith('sabnzbd:') ||
        routeName.startsWith('nzbget:') ||
        routeName.startsWith('settings:')) {
      return false;
    }

    return true;
  }
}
