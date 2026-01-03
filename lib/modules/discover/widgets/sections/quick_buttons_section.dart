import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/modules/radarr/core/state.dart';
import 'package:zagreus/modules/sonarr/core/state.dart';
import 'package:zagreus/modules/tautulli/core/state.dart';
import 'package:zagreus/modules/seerr/core/state.dart';
import 'package:zagreus/modules/unraid/core/state.dart';
import 'package:zagreus/modules/search/core/state.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/vendor.dart';

/// Data class for a quick button service
class _QuickButtonService {
  final ZagModule module;
  final Color color;
  final VoidCallback onTap;
  final String? labelOverride;

  const _QuickButtonService({
    required this.module,
    required this.color,
    required this.onTap,
    this.labelOverride,
  });

  String get label => labelOverride ?? module.title;
}

/// A horizontal wrap of quick access buttons to navigate to configured services.
/// Displays buttons for all enabled services like Radarr, Sonarr, Lidarr, etc.
class QuickButtonsSection extends StatelessWidget {
  const QuickButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final services = _getEnabledServices(context);

    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: services.map((service) => _QuickButton(service: service)).toList(),
      ),
    );
  }

  List<_QuickButtonService> _getEnabledServices(BuildContext context) {
    final services = <_QuickButtonService>[];
    final profile = ZagProfile.current;

    // Get the list of enabled quick buttons from settings (empty by default)
    final enabledButtons = List<String>.from(
      ZagreusDatabase.DISCOVER_QUICK_BUTTONS.read(),
    );

    // If no buttons are enabled, return empty list
    if (enabledButtons.isEmpty) {
      return services;
    }

    // Radarr - only show if enabled in quick buttons AND configured in app
    if (enabledButtons.contains('radarr') && context.read<RadarrState>().enabled) {
      services.add(_QuickButtonService(
        module: ZagModule.RADARR,
        color: ZagColours.radarr,
        onTap: () => ZagModule.RADARR.launch(restore: false),
      ));
    }

    // Sonarr
    if (enabledButtons.contains('sonarr') && context.read<SonarrState>().enabled) {
      services.add(_QuickButtonService(
        module: ZagModule.SONARR,
        color: ZagColours.sonarr,
        onTap: () => ZagModule.SONARR.launch(restore: false),
      ));
    }

    // Lidarr
    if (enabledButtons.contains('lidarr') && profile.lidarrEnabled) {
      services.add(_QuickButtonService(
        module: ZagModule.LIDARR,
        color: ZagColours.lidarr,
        onTap: () => ZagModule.LIDARR.launch(restore: false),
      ));
    }

    // Readarr
    if (enabledButtons.contains('readarr') && profile.readarrEnabled) {
      services.add(_QuickButtonService(
        module: ZagModule.READARR,
        color: ZagColours.readarr,
        onTap: () => ZagModule.READARR.launch(restore: false),
      ));
    }

    // Seerr (displayed as "Seerr")
    if (enabledButtons.contains('seerr') && context.read<SeerrState>().enabled) {
      services.add(_QuickButtonService(
        module: ZagModule.SEERR,
        color: ZagColours.seerr,
        onTap: () => ZagModule.SEERR.launch(restore: false),
        labelOverride: 'Seerr',
      ));
    }

    // Tautulli
    if (enabledButtons.contains('tautulli') && context.read<TautulliState>().enabled) {
      services.add(_QuickButtonService(
        module: ZagModule.TAUTULLI,
        color: ZagColours.tautulli,
        onTap: () => ZagModule.TAUTULLI.launch(restore: false),
      ));
    }

    // SABnzbd
    if (enabledButtons.contains('sabnzbd') && profile.sabnzbdEnabled) {
      services.add(_QuickButtonService(
        module: ZagModule.SABNZBD,
        color: ZagColours.sabnzbd,
        onTap: () => ZagModule.SABNZBD.launch(restore: false),
      ));
    }

    // NZBget
    if (enabledButtons.contains('nzbget') && profile.nzbgetEnabled) {
      services.add(_QuickButtonService(
        module: ZagModule.NZBGET,
        color: ZagColours.nzbget,
        onTap: () => ZagModule.NZBGET.launch(restore: false),
      ));
    }

    // Unraid
    if (enabledButtons.contains('unraid') && context.read<UnraidState>().enabled) {
      services.add(_QuickButtonService(
        module: ZagModule.UNRAID,
        color: ZagColours.unraid,
        onTap: () => ZagModule.UNRAID.launch(restore: false),
      ));
    }

    // Search
    if (enabledButtons.contains('search') && ZagModule.SEARCH.isEnabled) {
      services.add(_QuickButtonService(
        module: ZagModule.SEARCH,
        color: ZagModule.SEARCH.color,
        onTap: () => ZagModule.SEARCH.launch(restore: false),
      ));
    }

    return services;
  }
}

/// Individual quick button widget styled like discover section headers
class _QuickButton extends StatelessWidget {
  final _QuickButtonService service;

  const _QuickButton({required this.service});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: service.color.withOpacity(isDark ? 0.2 : 0.15),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          service.onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                service.module.icon,
                color: service.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                service.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ZagColours.textColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
