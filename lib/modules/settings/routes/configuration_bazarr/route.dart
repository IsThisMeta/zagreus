import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:url_launcher/url_launcher.dart';

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
        ZagDivider(),
        ZagHeader(text: 'Instance Selection'),
        _radarrInstanceSelector(),
        _sonarrInstanceSelector(),
      ],
    );
  }

  Widget _informationBanner() {
    return ZagBanner(
      headerText: 'Bazarr',
      bodyText: 'Bazarr is a companion application to Sonarr and Radarr that manages and downloads subtitles based on your requirements.',
      icon: Icons.subtitles_rounded,
      buttons: [
        ZagButton.text(
          text: 'zagreus.Website'.tr(),
          icon: ZagIcons.LINK,
          onTap: () => _openUrl('https://bazarr.media'),
        ),
        ZagButton.text(
          text: 'GitHub',
          icon: ZagIcons.GITHUB,
          onTap: () => _openUrl('https://github.com/morpheus65535/bazarr'),
        ),
      ],
    );
  }

  Widget _enabledToggle() {
    return ZagBox.profiles.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'settings.EnableModule'.tr(args: ['Bazarr']),
        trailing: ZagSwitch(
          value: ZagProfile.current.bazarrEnabled,
          onChanged: (value) {
            ZagProfile.current.bazarrEnabled = value;
            ZagProfile.current.save();
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _connectionDetailsPage() {
    return ZagBlock(
      title: 'settings.ConnectionDetails'.tr(),
      body: [
        TextSpan(
          text: 'settings.ConnectionDetailsDescription'.tr(
            args: ['Bazarr'],
          ),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: SettingsRoutes.CONFIGURATION_BAZARR_CONNECTION_DETAILS.go,
    );
  }

  Widget _radarrInstanceSelector() {
    return ZagreusDatabase.BAZARR_RADARR_INSTANCE.listenableBuilder(
      builder: (context, _) {
        final currentInstance = ZagreusDatabase.BAZARR_RADARR_INSTANCE.read() ?? '';
        final displayName = _getInstanceDisplayName('radarr', currentInstance);
        
        return ZagBlock(
          title: 'Radarr Instance',
          body: [
            TextSpan(text: displayName),
          ],
          trailing: const ZagIconButton.arrow(),
          onTap: () => _showInstanceSelector(
            moduleKey: 'radarr',
            moduleTitle: 'Radarr',
            currentInstance: currentInstance,
            onSelect: (instance) {
              ZagreusDatabase.BAZARR_RADARR_INSTANCE.update(instance);
            },
          ),
        );
      },
    );
  }

  Widget _sonarrInstanceSelector() {
    return ZagreusDatabase.BAZARR_SONARR_INSTANCE.listenableBuilder(
      builder: (context, _) {
        final currentInstance = ZagreusDatabase.BAZARR_SONARR_INSTANCE.read() ?? '';
        final displayName = _getInstanceDisplayName('sonarr', currentInstance);
        
        return ZagBlock(
          title: 'Sonarr Instance',
          body: [
            TextSpan(text: displayName),
          ],
          trailing: const ZagIconButton.arrow(),
          onTap: () => _showInstanceSelector(
            moduleKey: 'sonarr',
            moduleTitle: 'Sonarr',
            currentInstance: currentInstance,
            onSelect: (instance) {
              ZagreusDatabase.BAZARR_SONARR_INSTANCE.update(instance);
            },
          ),
        );
      },
    );
  }

  String _getInstanceDisplayName(String moduleKey, String instanceKey) {
    final moduleTitle = moduleKey == 'radarr' ? 'Radarr' : 'Sonarr';
    
    // Empty string means default/main instance
    if (instanceKey.isEmpty) {
      return moduleTitle;
    }
    
    // Get the display name for the shadow profile
    final displayName = ZagProfile.getInstanceDisplayName(instanceKey);
    if (displayName != null) {
      return '$moduleTitle $displayName';
    }
    
    return moduleTitle;
  }

  void _showInstanceSelector({
    required String moduleKey,
    required String moduleTitle,
    required String currentInstance,
    required void Function(String) onSelect,
  }) async {
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, moduleKey);
    
    // Build options: main instance + any additional instances
    final options = <String>['', ...instances];
    
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Select $moduleTitle Instance',
          style: TextStyle(color: ZagColours.textColor(ctx)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((instanceKey) {
            final isSelected = instanceKey == currentInstance;
            final name = _getInstanceDisplayName(moduleKey, instanceKey);
            
            return ListTile(
              title: Text(
                name,
                style: TextStyle(color: ZagColours.textColor(ctx)),
              ),
              leading: isSelected
                  ? Icon(
                      Icons.check,
                      color: moduleKey == 'radarr'
                          ? ZagModule.RADARR.color
                          : ZagModule.SONARR.color,
                    )
                  : const SizedBox(width: 24),
              onTap: () => Navigator.pop(ctx, instanceKey),
            );
          }).toList(),
        ),
      ),
    );

    if (!mounted) return;
    
    if (result != null && result != currentInstance) {
      onSelect(result);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showZagInfoSnackBar(
        title: 'Error',
        message: 'Could not open link',
      );
    }
  }
}
