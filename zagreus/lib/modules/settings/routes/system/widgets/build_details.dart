import 'dart:math';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/system/environment.dart';
import 'package:zagreus/system/flavor.dart';
import 'package:zagreus/system/platform.dart';

class BuildDetails extends StatefulWidget {
  const BuildDetails({Key? key}) : super(key: key);

  @override
  State<BuildDetails> createState() => _State();
}

class _State extends State<BuildDetails> {
  Future<PackageInfo>? packageInfo;

  @override
  void initState() {
    super.initState();
    packageInfo = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: packageInfo,
      builder: (context, AsyncSnapshot<PackageInfo> package) {
        return ZagTableCard(
          content: [
            ZagTableContent(
              title: 'settings.Version'.tr(),
              body: package.data?.version ?? 'zagreus.Unknown'.tr(),
            ),
            ZagTableContent(
              title: 'settings.Platform'.tr(),
              body: ZagPlatform.current.name,
            ),
            ZagTableContent(
              title: 'settings.Channel'.tr(),
              body: ZagFlavor.current.name,
            ),
            ZagTableContent(
              title: 'settings.Build'.tr(),
              body: '${ZagEnvironment.build} (${_shortCommit})',
            ),
          ],
          buttons: [
            _changelogButton(),
            _upToDateButton(),
          ],
        );
      },
    );
  }

  String get _shortCommit {
    const commit = ZagEnvironment.commit;
    return commit.substring(0, min(7, commit.length));
  }

  ZagButton _changelogButton() {
    return ZagButton.text(
      icon: ZagIcons.CHANGELOG,
      text: 'zagreus.Changelog'.tr(),
      onTap: () {
        // TODO: Implement changelog sheet
        showZagInfoSnackBar(
          title: 'Coming Soon',
          message: 'Changelog feature coming soon',
        );
      },
    );
  }

  ZagButton _upToDateButton() {
    return ZagButton.text(
      icon: ZagIcons.CHECK_MARK,
      color: ZagColours.currentAccent,
      text: 'settings.UpToDate'.tr(),
      onTap: () {
        // Refresh package info
        setState(() {
          packageInfo = PackageInfo.fromPlatform();
        });
      },
    );
  }
}
