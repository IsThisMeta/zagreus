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
import 'package:zagreus/modules/ssh/core/state.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/vendor.dart';

/// Data class for a quick button service
class _QuickButtonService {
  final String key;
  final ZagModule module;
  final Color color;
  final VoidCallback onTap;
  final String? labelOverride;

  const _QuickButtonService({
    required this.key,
    required this.module,
    required this.color,
    required this.onTap,
    this.labelOverride,
  });

  String get label => labelOverride ?? module.title;
}

/// A horizontal wrap of quick access buttons to navigate to configured services.
/// Supports long press + drag to reorder buttons.
class QuickButtonsSection extends StatefulWidget {
  const QuickButtonsSection({super.key});

  @override
  State<QuickButtonsSection> createState() => _QuickButtonsSectionState();
}

class _QuickButtonsSectionState extends State<QuickButtonsSection> {
  List<_QuickButtonService> _services = [];
  int? _targetIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services = _getEnabledServices(context);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    setState(() {
      final item = _services.removeAt(oldIndex);
      // When moving forward, adjust for the index shift caused by removal
      final adjustedIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
      _services.insert(adjustedIndex, item);
    });

    // Save the new order to database
    final newOrder = _services.map((s) => s.key).toList();
    ZagreusDatabase.DISCOVER_QUICK_BUTTONS.update(newOrder);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (_services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(_services.length, (index) {
          final service = _services[index];
          final isTarget = _targetIndex == index;

          return DragTarget<int>(
            onWillAcceptWithDetails: (details) {
              if (details.data != index) {
                setState(() => _targetIndex = index);
                return true;
              }
              return false;
            },
            onLeave: (_) {
              setState(() => _targetIndex = null);
            },
            onAcceptWithDetails: (details) {
              _onReorder(details.data, index);
              setState(() => _targetIndex = null);
            },
            builder: (context, candidateData, rejectedData) {
              return LongPressDraggable<int>(
                data: index,
                delay: const Duration(milliseconds: 200),
                hapticFeedbackOnStart: true,
                onDragStarted: () {
                  HapticFeedback.mediumImpact();
                },
                onDragEnd: (_) {
                  setState(() => _targetIndex = null);
                },
                feedback: Material(
                  color: Colors.transparent,
                  child: Transform.scale(
                    scale: 1.05,
                    child: Opacity(
                      opacity: 0.9,
                      child: _QuickButton(service: service),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _QuickButton(service: service),
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: isTarget ? 1.05 : 1.0,
                  child: _QuickButton(service: service),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  List<_QuickButtonService> _getEnabledServices(BuildContext context) {
    final profile = ZagProfile.current;

    // Get the ordered list of enabled quick buttons from settings
    final enabledButtons = List<String>.from(
      ZagreusDatabase.DISCOVER_QUICK_BUTTONS.read(),
    );

    if (enabledButtons.isEmpty) {
      return [];
    }

    // Map of service key to its configuration
    final serviceConfigs = <String, _QuickButtonService Function()>{
      'radarr': () => _QuickButtonService(
            key: 'radarr',
            module: ZagModule.RADARR,
            color: ZagColours.radarr,
            onTap: () => ZagModule.RADARR.launch(restore: false),
          ),
      'sonarr': () => _QuickButtonService(
            key: 'sonarr',
            module: ZagModule.SONARR,
            color: ZagColours.sonarr,
            onTap: () => ZagModule.SONARR.launch(restore: false),
          ),
      'lidarr': () => _QuickButtonService(
            key: 'lidarr',
            module: ZagModule.LIDARR,
            color: ZagColours.lidarr,
            onTap: () => ZagModule.LIDARR.launch(restore: false),
          ),
      'readarr': () => _QuickButtonService(
            key: 'readarr',
            module: ZagModule.READARR,
            color: ZagColours.readarr,
            onTap: () => ZagModule.READARR.launch(restore: false),
          ),
      'seerr': () => _QuickButtonService(
            key: 'seerr',
            module: ZagModule.SEERR,
            color: ZagColours.seerr,
            onTap: () => ZagModule.SEERR.launch(restore: false),
            labelOverride: 'Seerr',
          ),
      'tautulli': () => _QuickButtonService(
            key: 'tautulli',
            module: ZagModule.TAUTULLI,
            color: ZagColours.tautulli,
            onTap: () => ZagModule.TAUTULLI.launch(restore: false),
          ),
      'sabnzbd': () => _QuickButtonService(
            key: 'sabnzbd',
            module: ZagModule.SABNZBD,
            color: ZagColours.sabnzbd,
            onTap: () => ZagModule.SABNZBD.launch(restore: false),
          ),
      'nzbget': () => _QuickButtonService(
            key: 'nzbget',
            module: ZagModule.NZBGET,
            color: ZagColours.nzbget,
            onTap: () => ZagModule.NZBGET.launch(restore: false),
          ),
      'unraid': () => _QuickButtonService(
            key: 'unraid',
            module: ZagModule.UNRAID,
            color: ZagColours.unraid,
            onTap: () => ZagModule.UNRAID.launch(restore: false),
          ),
      'search': () => _QuickButtonService(
            key: 'search',
            module: ZagModule.SEARCH,
            color: ZagModule.SEARCH.color,
            onTap: () => ZagModule.SEARCH.launch(restore: false),
          ),
      'ssh': () => _QuickButtonService(
            key: 'ssh',
            module: ZagModule.SSH,
            color: ZagModule.SSH.color,
            onTap: () => ZagModule.SSH.launch(restore: false),
          ),
    };

    // Map of service key to enabled check
    final serviceEnabledChecks = <String, bool>{
      'radarr': context.read<RadarrState>().enabled,
      'sonarr': context.read<SonarrState>().enabled,
      'lidarr': profile.lidarrEnabled,
      'readarr': profile.readarrEnabled,
      'seerr': context.read<SeerrState>().enabled,
      'tautulli': context.read<TautulliState>().enabled,
      'sabnzbd': profile.sabnzbdEnabled,
      'nzbget': profile.nzbgetEnabled,
      'unraid': context.read<UnraidState>().enabled,
      'search': ZagModule.SEARCH.isEnabled,
      'ssh': context.read<SSHState>().enabled,
    };

    // Build services list respecting the stored order
    final services = <_QuickButtonService>[];
    for (final key in enabledButtons) {
      final isEnabled = serviceEnabledChecks[key] ?? false;
      final config = serviceConfigs[key];
      if (isEnabled && config != null) {
        services.add(config());
      }
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
