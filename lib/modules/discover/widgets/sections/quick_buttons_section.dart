import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules/radarr/core/state.dart';
import 'package:zagreus/modules/sonarr/core/state.dart';
import 'package:zagreus/modules/tautulli/core/state.dart';
import 'package:zagreus/modules/overseerr/core/state.dart';
import 'package:zagreus/modules/unraid/core/state.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/router/routes/lidarr.dart';
import 'package:zagreus/router/routes/readarr.dart';
import 'package:zagreus/router/routes/sabnzbd.dart';
import 'package:zagreus/router/routes/nzbget.dart';
import 'package:zagreus/router/routes/tautulli.dart';
import 'package:zagreus/router/routes/overseerr.dart';
import 'package:zagreus/router/routes/unraid.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/vendor.dart';

/// Data class for a quick button service
class _QuickButtonService {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickButtonService({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });
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
        name: 'Radarr',
        icon: Icons.movie_rounded,
        color: ZagColours.radarr,
        onTap: () => RadarrRoutes.HOME.go(),
      ));
    }

    // Sonarr
    if (enabledButtons.contains('sonarr') && context.read<SonarrState>().enabled) {
      services.add(_QuickButtonService(
        name: 'Sonarr',
        icon: Icons.tv_rounded,
        color: ZagColours.sonarr,
        onTap: () => SonarrRoutes.HOME.go(),
      ));
    }

    // Lidarr
    if (enabledButtons.contains('lidarr') && profile.lidarrEnabled) {
      services.add(_QuickButtonService(
        name: 'Lidarr',
        icon: Icons.music_note_rounded,
        color: ZagColours.lidarr,
        onTap: () => LidarrRoutes.HOME.go(),
      ));
    }

    // Readarr
    if (enabledButtons.contains('readarr') && profile.readarrEnabled) {
      services.add(_QuickButtonService(
        name: 'Readarr',
        icon: Icons.menu_book_rounded,
        color: ZagColours.readarr,
        onTap: () => ReadarrRoutes.HOME.go(),
      ));
    }

    // Overseerr
    if (enabledButtons.contains('overseerr') && context.read<OverseerrState>().enabled) {
      services.add(_QuickButtonService(
        name: 'Overseerr',
        icon: Icons.request_page_rounded,
        color: ZagColours.overseerr,
        onTap: () => OverseerrRoutes.HOME.go(),
      ));
    }

    // Tautulli
    if (enabledButtons.contains('tautulli') && context.read<TautulliState>().enabled) {
      services.add(_QuickButtonService(
        name: 'Tautulli',
        icon: Icons.bar_chart_rounded,
        color: ZagColours.tautulli,
        onTap: () => TautulliRoutes.HOME.go(),
      ));
    }

    // SABnzbd
    if (enabledButtons.contains('sabnzbd') && profile.sabnzbdEnabled) {
      services.add(_QuickButtonService(
        name: 'SABnzbd',
        icon: Icons.download_rounded,
        color: ZagColours.sabnzbd,
        onTap: () => SABnzbdRoutes.HOME.go(),
      ));
    }

    // NZBget
    if (enabledButtons.contains('nzbget') && profile.nzbgetEnabled) {
      services.add(_QuickButtonService(
        name: 'NZBget',
        icon: Icons.download_rounded,
        color: ZagColours.nzbget,
        onTap: () => NZBGetRoutes.HOME.go(),
      ));
    }

    // Unraid
    if (enabledButtons.contains('unraid') && context.read<UnraidState>().enabled) {
      services.add(_QuickButtonService(
        name: 'Unraid',
        icon: Icons.storage_rounded,
        color: ZagColours.unraid,
        onTap: () => UnraidRoutes.HOME.go(),
      ));
    }

    return services;
  }
}

/// Individual quick button widget styled like nzb360
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
                service.icon,
                size: 18,
                color: service.color,
              ),
              const SizedBox(width: 8),
              Text(
                service.name,
                style: TextStyle(
                  color: service.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.north_east_rounded,
                size: 14,
                color: service.color.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
