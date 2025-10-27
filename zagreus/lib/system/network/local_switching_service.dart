import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/system/logger.dart';
import 'package:zagreus/widgets/ui/snackbar/snackbar_info.dart';

class ZagLocalConnectionService {
  ZagLocalConnectionService._();

  static final ZagLocalConnectionService _instance =
      ZagLocalConnectionService._();

  factory ZagLocalConnectionService() => _instance;

  final NetworkInfo _networkInfo = NetworkInfo();
  final ValueNotifier<String?> currentSsid = ValueNotifier<String?>(null);
  final Map<ZagModule, bool> _moduleLocalState = {};
  bool _permissionWarningShown = false;

  Future<void> refreshSsid({bool forceEvaluate = false}) async {
    try {
      final hasPermission = await _ensureWifiPermission();
      if (!hasPermission) {
        if (forceEvaluate) {
          _applySsidUpdate(
            null,
            source: 'permission-denied',
            forceEvaluate: true,
          );
        }
        return;
      }

      final ssid = await _networkInfo.getWifiName();
      _applySsidUpdate(
        ssid,
        source: 'plugin',
        forceEvaluate: forceEvaluate,
      );
    } catch (e, stackTrace) {
      ZagLogger().warning('Failed to read current Wi-Fi SSID: $e');
      ZagLogger().debug(stackTrace.toString());
      if (forceEvaluate) {
        _applySsidUpdate(
          null,
          source: 'plugin-error',
          forceEvaluate: true,
        );
      }
    }
  }

  Future<bool> _ensureWifiPermission() async {
    if (_shouldRequestLocationPermission) {
      try {
        final status = await Permission.locationWhenInUse.status;
        if (_isLocationAllowed(status)) {
          return true;
        }

        final result = await Permission.locationWhenInUse.request();
        if (_isLocationAllowed(result)) {
          return true;
        }

        _showPermissionWarning();
        return false;
      } catch (e, stackTrace) {
        ZagLogger().warning('Failed to request location permission: $e');
        ZagLogger().debug(stackTrace.toString());
        _showPermissionWarning();
        return false;
      }
    }

    return true;
  }

  bool _isLocationAllowed(PermissionStatus status) {
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited;
  }

  bool get _shouldRequestLocationPermission =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  void _showPermissionWarning() {
    if (_permissionWarningShown) return;
    _permissionWarningShown = true;

    showZagInfoSnackBar(
      title: 'network.LocationPermissionRequiredTitle'.tr(),
      message: 'network.LocationPermissionRequiredMessage'.tr(),
    );
  }

  void updateSsidFromNative(String? ssid) {
    _applySsidUpdate(ssid, source: 'native');
  }

  Future<void> handleAdvancedToggle(bool enabled) async {
    if (enabled) {
      await refreshSsid(forceEvaluate: true);
    } else {
      _moduleLocalState.clear();
    }
  }

  String resolveHost({
    required String remoteHost,
    required String localHost,
    required String ssidList,
  }) {
    if (!ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read()) {
      return remoteHost;
    }

    if (localHost.isEmpty) return remoteHost;

    final allowedSsids = _parseSsids(ssidList);
    if (allowedSsids.isEmpty) return remoteHost;

    final current = currentSsid.value;
    if (current == null) {
      return remoteHost;
    }

    if (allowedSsids.contains(current)) {
      return localHost;
    }

    return remoteHost;
  }

  List<String> _parseSsids(String value) {
    return value.split(',').map(_sanitize).whereType<String>().toSet().toList();
  }

  String? _sanitize(String? value) {
    if (value == null) return null;
    final trimmed = value.replaceAll('"', '').trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _applySsidUpdate(
    String? ssid, {
    required String source,
    bool forceEvaluate = false,
  }) {
    final sanitized = _sanitize(ssid);
    final changed = sanitized != currentSsid.value;
    if (changed) {
      currentSsid.value = sanitized;
      ZagLogger()
          .debug('Wi-Fi SSID updated ($source): ${sanitized ?? 'Unknown'}');
    }

    if (ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read()) {
      if (changed || forceEvaluate) {
        _evaluateSwitches();
      }
    } else if (_moduleLocalState.isNotEmpty) {
      _moduleLocalState.clear();
    }
  }

  void _evaluateSwitches() {
    if (!ZagreusDatabase.NETWORKING_LOCAL_SWITCHING_ENABLED.read()) {
      _moduleLocalState.clear();
      return;
    }

    final profile = ZagProfile.current;
    final configs = _collectConfigs(profile);
    final processed = <ZagModule>{};

    for (final config in configs) {
      processed.add(config.module);

      if (!config.enabled) {
        _moduleLocalState.remove(config.module);
        continue;
      }

      bool shouldUseLocal = false;
      if (config.localHost.isNotEmpty) {
        final ssids = _parseSsids(config.ssids);
        shouldUseLocal = ssids.isNotEmpty &&
            currentSsid.value != null &&
            ssids.contains(currentSsid.value);
      }

      final previous = _moduleLocalState[config.module];
      _moduleLocalState[config.module] = shouldUseLocal;

      if (previous == null) continue;
      if (previous == shouldUseLocal) continue;

      _showSwitchToast(config.module, shouldUseLocal);
    }

    _moduleLocalState.removeWhere((module, _) => !processed.contains(module));
  }

  List<_LocalSwitchConfig> _collectConfigs(ZagProfile profile) {
    return [
      _LocalSwitchConfig(
        module: ZagModule.RADARR,
        enabled: profile.radarrEnabled,
        localHost: profile.radarrLocalHost,
        ssids: profile.radarrLocalSsids,
      ),
      _LocalSwitchConfig(
        module: ZagModule.SONARR,
        enabled: profile.sonarrEnabled,
        localHost: profile.sonarrLocalHost,
        ssids: profile.sonarrLocalSsids,
      ),
      _LocalSwitchConfig(
        module: ZagModule.LIDARR,
        enabled: profile.lidarrEnabled,
        localHost: profile.lidarrLocalHost,
        ssids: profile.lidarrLocalSsids,
      ),
      _LocalSwitchConfig(
        module: ZagModule.SABNZBD,
        enabled: profile.sabnzbdEnabled,
        localHost: profile.sabnzbdLocalHost,
        ssids: profile.sabnzbdLocalSsids,
      ),
      _LocalSwitchConfig(
        module: ZagModule.NZBGET,
        enabled: profile.nzbgetEnabled,
        localHost: profile.nzbgetLocalHost,
        ssids: profile.nzbgetLocalSsids,
      ),
      _LocalSwitchConfig(
        module: ZagModule.TAUTULLI,
        enabled: profile.tautulliEnabled,
        localHost: profile.tautulliLocalHost,
        ssids: profile.tautulliLocalSsids,
      ),
      _LocalSwitchConfig(
        module: ZagModule.SERVER,
        enabled: profile.serverEnabled,
        localHost: profile.serverLocalHost,
        ssids: profile.serverLocalSsids,
      ),
    ];
  }

  void _showSwitchToast(ZagModule module, bool usingLocal) {
    final moduleName = module.title;
    final title = 'network.SwitchDetected'.tr();
    final message = usingLocal
        ? 'network.SwitchLocal'.tr(
            args: [moduleName, currentSsid.value ?? 'network.UnknownSsid'.tr()])
        : 'network.SwitchRemote'.tr(args: [moduleName]);

    showZagInfoSnackBar(
      title: title,
      message: message,
    );
  }
}

class _LocalSwitchConfig {
  const _LocalSwitchConfig({
    required this.module,
    required this.enabled,
    required this.localHost,
    required this.ssids,
  });

  final ZagModule module;
  final bool enabled;
  final String localHost;
  final String ssids;
}
