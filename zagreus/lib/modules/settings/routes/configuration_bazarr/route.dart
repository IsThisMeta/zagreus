import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/bazarr/bazarr.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ConfigurationBazarrRoute extends StatefulWidget {
  const ConfigurationBazarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationBazarrRoute> createState() => _State();
}

class _State extends State<ConfigurationBazarrRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'Bazarr',
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        _informationBanner(),
        _enabledToggle(),
        _connectionDetailsPage(),
      ],
    );
  }

  Widget _informationBanner() {
    return ZagBanner(
      headerText: 'Bazarr',
      bodyText: 'Bazarr is a companion application to Sonarr and Radarr that manages and downloads subtitles based on your requirements.',
      iconData: Icons.subtitles_rounded,
      buttons: [
        ZagButton.text(
          text: 'zagreus.Website'.tr(),
          icon: ZagIcons.LINK,
          onTap: () => 'https://bazarr.media'.launchUrl(
            mode: LaunchMode.externalApplication,
          ),
        ),
        ZagButton.text(
          text: 'GitHub',
          icon: ZagIcons.GITHUB,
          onTap: () => 'https://github.com/morpheus65535/bazarr'.launchUrl(
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }

  Widget _enabledToggle() {
    final isPro = ZagreusPro.isEnabled;

    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: ['Bazarr']),
        trailing: ZagSwitch(
          value: ZagProfile.current.bazarrEnabled,
          onChanged: isPro
              ? (value) {
                  ZagProfile.current.bazarrEnabled = value;
                  ZagProfile.current.save();
                  setState(() {});
                }
              : (_) => _showProUpgradeToast(),
        ),
      ),
    );
  }

  Widget _connectionDetailsPage() {
    final isPro = ZagreusPro.isEnabled;

    return ZagBlock(
      title: 'settings.ConnectionDetails'.tr(),
      body: [
        TextSpan(
          text: 'settings.ConnectionDetailsDescription'.tr(
            args: ['Bazarr'],
          ),
        ),
      ],
      trailing: isPro
          ? const ZagIconButton.arrow()
          : const ZagIconButton(icon: Icons.lock_rounded),
      onTap: isPro
          ? SettingsRoutes.CONFIGURATION_BAZARR_CONNECTION_DETAILS.go
          : _showProUpgradeToast,
    );
  }

  void _showProUpgradeToast() {
    showZagInfoSnackBar(
      title: 'Zagreus Pro required',
      message: 'Upgrade to Zagreus Pro to configure Bazarr.',
    );
  }
}
