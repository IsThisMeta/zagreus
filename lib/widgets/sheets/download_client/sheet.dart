import 'package:flutter/material.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/nzbget.dart';
import 'package:zagreus/modules/sabnzbd/routes.dart';
import 'package:zagreus/utils/dialogs.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/widgets/pages/invalid_route.dart';
import 'package:zagreus/widgets/ui.dart';

class DownloadClientSheet extends ZagBottomModalSheet {
  Future<ZagModule?> getDownloadClient() async {
    final profile = ZagProfile.current;
    final nzbget = profile.nzbgetEnabled;
    final sabnzbd = profile.sabnzbdEnabled;

    if (nzbget && sabnzbd) {
      return ZagDialogs().selectDownloadClient();
    }
    if (nzbget) {
      return ZagModule.NZBGET;
    }
    if (sabnzbd) {
      return ZagModule.SABNZBD;
    }

    return null;
  }

  @override
  Future<dynamic> show({
    Widget Function(BuildContext context)? builder,
  }) async {
    final module = await getDownloadClient();
    if (module != null) {
      return showModal(builder: (context) {
        if (module == ZagModule.SABNZBD) {
          return const SABnzbdRoute(showDrawer: false);
        }
        if (module == ZagModule.NZBGET) {
          return const NZBGetRoute(showDrawer: false);
        }
        return InvalidRoutePage();
      });
    }
  }
}
