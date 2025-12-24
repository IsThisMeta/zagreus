import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/supabase/core.dart';

class BuildDetails extends StatefulWidget {
  const BuildDetails({Key? key}) : super(key: key);

  @override
  State<BuildDetails> createState() => _State();
}

class _State extends State<BuildDetails> {
  Future<PackageInfo>? packageInfo;
  String? latestVersion;
  String? currentVersion;
  bool isCheckingVersion = false;

  @override
  void initState() {
    super.initState();
    packageInfo = PackageInfo.fromPlatform();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = info.version;
    });
  }

  Future<void> _checkVersion() async {
    setState(() {
      isCheckingVersion = true;
    });

    try {
      final response = await ZagSupabase.client
          .from('app_version')
          .select('version')
          .single();

      final fetchedVersion = response['version'] as String?;

      print('📱 Version check:');
      print('  Current: "$currentVersion"');
      print('  Latest: "$fetchedVersion"');
      print('  Match: ${currentVersion == fetchedVersion}');

      setState(() {
        latestVersion = fetchedVersion;
        isCheckingVersion = false;
      });
    } catch (e, stack) {
      ZagLogger().error('Failed to check version', e, stack);
      setState(() {
        isCheckingVersion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: packageInfo,
      builder: (context, AsyncSnapshot<PackageInfo> package) {
        return ZagTableCard(
          content: [
            ZagTableContent(
              body:
                  'Version ${package.data?.version ?? 'zagreus.Unknown'.tr()}',
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

  ZagButton _changelogButton() {
    return ZagButton.text(
      icon: ZagIcons.CHANGELOG,
      text: 'zagreus.Changelog'.tr(),
      onTap: () => 'https://zagreus.app/changelog'.openLink(),
    );
  }

  ZagButton _upToDateButton() {
    if (isCheckingVersion) {
      return ZagButton.text(
        icon: ZagIcons.REFRESH,
        text: 'Checking...',
        onTap: null,
      );
    }

    final isUpToDate = latestVersion == null || latestVersion == currentVersion;

    if (isUpToDate) {
      return ZagButton.text(
        icon: latestVersion == null ? null : ZagIcons.CHECK_MARK,
        color: ZagColours.currentAccent,
        text: latestVersion == null ? 'Check For Update' : 'settings.UpToDate'.tr(),
        onTap: _checkVersion,
      );
    } else {
      return ZagButton.text(
        icon: null,
        color: ZagColours.orange,
        text: 'Update Available: v$latestVersion',
        onTap: () => 'https://zagreus.app/changelog'.openLink(),
      );
    }
  }
}
