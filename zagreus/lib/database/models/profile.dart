import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/system/network/local_switching_service.dart';

part 'profile.g.dart';

/// Tracks which shadow profile (instance) is active for each module.
/// When null, the main profile is used.
class ZagInstanceContext {
  static final ZagInstanceContext _instance = ZagInstanceContext._();
  factory ZagInstanceContext() => _instance;
  ZagInstanceContext._();

  /// Maps module key -> active shadow profile key (or null for main)
  final Map<String, String?> _activeInstances = {};

  /// Get the active instance for a module (null = main profile)
  String? getActiveInstance(String moduleKey) => _activeInstances[moduleKey];

  /// Set the active instance for a module
  void setActiveInstance(String moduleKey, String? instanceKey) {
    _activeInstances[moduleKey] = instanceKey;
  }

  /// Clear the active instance for a module (revert to main)
  void clearActiveInstance(String moduleKey) {
    _activeInstances.remove(moduleKey);
  }

  /// Clear all active instances
  void clearAll() {
    _activeInstances.clear();
  }
}

@JsonSerializable()
@HiveType(typeId: 0, adapterName: 'ZagProfileAdapter')
class ZagProfile extends HiveObject {
  static const String DEFAULT_PROFILE = 'default';

  static ZagProfile get current {
    final enabled = ZagreusDatabase.ENABLED_PROFILE.read();
    return ZagBox.profiles.read(enabled) ?? ZagProfile();
  }

  /// Get the effective profile for a module, considering active instances.
  /// If an instance is active for this module, returns that shadow profile.
  /// Otherwise returns the current main profile.
  static ZagProfile forModule(String moduleKey) {
    final instanceKey = ZagInstanceContext().getActiveInstance(moduleKey);
    if (instanceKey != null) {
      final instanceProfile = ZagBox.profiles.read(instanceKey);
      if (instanceProfile != null) return instanceProfile;
    }
    return current;
  }

  /// Get the display name for the current instance of a module.
  /// Returns null if using the main profile.
  static String? getActiveInstanceName(String moduleKey) {
    final instanceKey = ZagInstanceContext().getActiveInstance(moduleKey);
    if (instanceKey == null) return null;
    return getInstanceDisplayName(instanceKey);
  }

  static List<String> get list {
    final profiles = ZagBox.profiles.keys.cast<String>().toList();
    profiles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return profiles;
  }

  @JsonKey()
  @HiveField(0, defaultValue: false)
  bool lidarrEnabled;

  @JsonKey()
  @HiveField(1, defaultValue: '')
  String lidarrHost;

  @JsonKey()
  @HiveField(2, defaultValue: '')
  String lidarrKey;

  @JsonKey()
  @HiveField(26, defaultValue: <String, String>{})
  Map<String, String> lidarrHeaders;

  @JsonKey()
  @HiveField(48, defaultValue: '')
  String lidarrLocalHost;

  @JsonKey()
  @HiveField(49, defaultValue: '')
  String lidarrLocalSsids;

  @JsonKey()
  @HiveField(3, defaultValue: false)
  bool radarrEnabled;

  @JsonKey()
  @HiveField(4, defaultValue: '')
  String radarrHost;

  @JsonKey()
  @HiveField(5, defaultValue: '')
  String radarrKey;

  @JsonKey()
  @HiveField(27, defaultValue: <String, String>{})
  Map<String, String> radarrHeaders;

  @JsonKey()
  @HiveField(50, defaultValue: '')
  String radarrLocalHost;

  @JsonKey()
  @HiveField(51, defaultValue: '')
  String radarrLocalSsids;

  @JsonKey()
  @HiveField(6, defaultValue: false)
  bool sonarrEnabled;

  @JsonKey()
  @HiveField(7, defaultValue: '')
  String sonarrHost;

  @JsonKey()
  @HiveField(8, defaultValue: '')
  String sonarrKey;

  @JsonKey()
  @HiveField(28, defaultValue: <String, String>{})
  Map<String, String> sonarrHeaders;

  @JsonKey()
  @HiveField(52, defaultValue: '')
  String sonarrLocalHost;

  @JsonKey()
  @HiveField(53, defaultValue: '')
  String sonarrLocalSsids;

  @JsonKey()
  @HiveField(9, defaultValue: false)
  bool sabnzbdEnabled;

  @JsonKey()
  @HiveField(10, defaultValue: '')
  String sabnzbdHost;

  @JsonKey()
  @HiveField(11, defaultValue: '')
  String sabnzbdKey;

  @JsonKey()
  @HiveField(29, defaultValue: <String, String>{})
  Map<String, String> sabnzbdHeaders;

  @JsonKey()
  @HiveField(54, defaultValue: '')
  String sabnzbdLocalHost;

  @JsonKey()
  @HiveField(55, defaultValue: '')
  String sabnzbdLocalSsids;

  @JsonKey()
  @HiveField(12, defaultValue: false)
  bool nzbgetEnabled;

  @JsonKey()
  @HiveField(13, defaultValue: '')
  String nzbgetHost;

  @JsonKey()
  @HiveField(14, defaultValue: '')
  String nzbgetUser;

  @JsonKey()
  @HiveField(15, defaultValue: '')
  String nzbgetPass;

  @JsonKey()
  @HiveField(30, defaultValue: <String, String>{})
  Map<String, String> nzbgetHeaders;

  @JsonKey()
  @HiveField(56, defaultValue: '')
  String nzbgetLocalHost;

  @JsonKey()
  @HiveField(57, defaultValue: '')
  String nzbgetLocalSsids;

  @JsonKey()
  @HiveField(23, defaultValue: false)
  bool wakeOnLANEnabled;

  @JsonKey()
  @HiveField(24, defaultValue: '')
  String wakeOnLANBroadcastAddress;

  @JsonKey()
  @HiveField(25, defaultValue: '')
  String wakeOnLANMACAddress;

  @JsonKey()
  @HiveField(31, defaultValue: false)
  bool tautulliEnabled;

  @JsonKey()
  @HiveField(32, defaultValue: '')
  String tautulliHost;

  @JsonKey()
  @HiveField(33, defaultValue: '')
  String tautulliKey;

  @JsonKey()
  @HiveField(35, defaultValue: <String, String>{})
  Map<String, String> tautulliHeaders;

  @JsonKey()
  @HiveField(58, defaultValue: '')
  String tautulliLocalHost;

  @JsonKey()
  @HiveField(59, defaultValue: '')
  String tautulliLocalSsids;

  @JsonKey()
  @HiveField(40, defaultValue: false)
  bool overseerrEnabled;

  @JsonKey()
  @HiveField(41, defaultValue: '')
  String overseerrHost;

  @JsonKey()
  @HiveField(42, defaultValue: '')
  String overseerrKey;

  @JsonKey()
  @HiveField(43, defaultValue: <String, String>{})
  Map<String, String> overseerrHeaders;

  @JsonKey()
  @HiveField(68, defaultValue: '')
  String overseerrLocalHost;

  @JsonKey()
  @HiveField(69, defaultValue: '')
  String overseerrLocalSsids;

  @JsonKey()
  @HiveField(44, defaultValue: false)
  bool unraidEnabled;

  @JsonKey()
  @HiveField(45, defaultValue: '')
  String unraidHost;

  @JsonKey()
  @HiveField(46, defaultValue: '')
  String unraidKey;

  @JsonKey()
  @HiveField(47, defaultValue: <String, String>{})
  Map<String, String> unraidHeaders;

  @JsonKey()
  @HiveField(60, defaultValue: '')
  String unraidLocalHost;

  @JsonKey()
  @HiveField(61, defaultValue: '')
  String unraidLocalSsids;

  @JsonKey()
  @HiveField(62, defaultValue: false)
  bool readarrEnabled;

  @JsonKey()
  @HiveField(63, defaultValue: '')
  String readarrHost;

  @JsonKey()
  @HiveField(64, defaultValue: '')
  String readarrKey;

  @JsonKey()
  @HiveField(65, defaultValue: <String, String>{})
  Map<String, String> readarrHeaders;

  @JsonKey()
  @HiveField(66, defaultValue: '')
  String readarrLocalHost;

  @JsonKey()
  @HiveField(67, defaultValue: '')
  String readarrLocalSsids;

  ZagProfile._internal({
    //Lidarr
    required this.lidarrEnabled,
    required this.lidarrHost,
    required this.lidarrKey,
    required this.lidarrHeaders,
    required this.lidarrLocalHost,
    required this.lidarrLocalSsids,
    //Radarr
    required this.radarrEnabled,
    required this.radarrHost,
    required this.radarrKey,
    required this.radarrHeaders,
    required this.radarrLocalHost,
    required this.radarrLocalSsids,
    //Sonarr
    required this.sonarrEnabled,
    required this.sonarrHost,
    required this.sonarrKey,
    required this.sonarrHeaders,
    required this.sonarrLocalHost,
    required this.sonarrLocalSsids,
    //SABnzbd
    required this.sabnzbdEnabled,
    required this.sabnzbdHost,
    required this.sabnzbdKey,
    required this.sabnzbdHeaders,
    required this.sabnzbdLocalHost,
    required this.sabnzbdLocalSsids,
    //NZBGet
    required this.nzbgetEnabled,
    required this.nzbgetHost,
    required this.nzbgetUser,
    required this.nzbgetPass,
    required this.nzbgetHeaders,
    required this.nzbgetLocalHost,
    required this.nzbgetLocalSsids,
    //Wake On LAN
    required this.wakeOnLANEnabled,
    required this.wakeOnLANBroadcastAddress,
    required this.wakeOnLANMACAddress,
    //Tautulli
    required this.tautulliEnabled,
    required this.tautulliHost,
    required this.tautulliKey,
    required this.tautulliHeaders,
    required this.tautulliLocalHost,
    required this.tautulliLocalSsids,
    //Overseerr
    required this.overseerrEnabled,
    required this.overseerrHost,
    required this.overseerrKey,
    required this.overseerrHeaders,
    required this.overseerrLocalHost,
    required this.overseerrLocalSsids,
    //Unraid
    required this.unraidEnabled,
    required this.unraidHost,
    required this.unraidKey,
    required this.unraidHeaders,
    required this.unraidLocalHost,
    required this.unraidLocalSsids,
    //Readarr
    required this.readarrEnabled,
    required this.readarrHost,
    required this.readarrKey,
    required this.readarrHeaders,
    required this.readarrLocalHost,
    required this.readarrLocalSsids,
  });

  factory ZagProfile({
    //Lidarr
    bool? lidarrEnabled,
    String? lidarrHost,
    String? lidarrKey,
    Map<String, String>? lidarrHeaders,
    String? lidarrLocalHost,
    String? lidarrLocalSsids,
    //Radarr
    bool? radarrEnabled,
    String? radarrHost,
    String? radarrKey,
    Map<String, String>? radarrHeaders,
    String? radarrLocalHost,
    String? radarrLocalSsids,
    //Sonarr
    bool? sonarrEnabled,
    String? sonarrHost,
    String? sonarrKey,
    Map<String, String>? sonarrHeaders,
    String? sonarrLocalHost,
    String? sonarrLocalSsids,
    //SABnzbd
    bool? sabnzbdEnabled,
    String? sabnzbdHost,
    String? sabnzbdKey,
    Map<String, String>? sabnzbdHeaders,
    String? sabnzbdLocalHost,
    String? sabnzbdLocalSsids,
    //NZBGet
    bool? nzbgetEnabled,
    String? nzbgetHost,
    String? nzbgetUser,
    String? nzbgetPass,
    Map<String, String>? nzbgetHeaders,
    String? nzbgetLocalHost,
    String? nzbgetLocalSsids,
    //Wake On LAN
    bool? wakeOnLANEnabled,
    String? wakeOnLANBroadcastAddress,
    String? wakeOnLANMACAddress,
    //Tautulli
    bool? tautulliEnabled,
    String? tautulliHost,
    String? tautulliKey,
    Map<String, String>? tautulliHeaders,
    String? tautulliLocalHost,
    String? tautulliLocalSsids,
    //Overseerr
    bool? overseerrEnabled,
    String? overseerrHost,
    String? overseerrKey,
    Map<String, String>? overseerrHeaders,
    String? overseerrLocalHost,
    String? overseerrLocalSsids,
    //Unraid
    bool? unraidEnabled,
    String? unraidHost,
    String? unraidKey,
    Map<String, String>? unraidHeaders,
    String? unraidLocalHost,
    String? unraidLocalSsids,
    //Readarr
    bool? readarrEnabled,
    String? readarrHost,
    String? readarrKey,
    Map<String, String>? readarrHeaders,
    String? readarrLocalHost,
    String? readarrLocalSsids,
  }) {
    return ZagProfile._internal(
      // Lidarr
      lidarrEnabled: lidarrEnabled ?? false,
      lidarrHost: lidarrHost ?? '',
      lidarrKey: lidarrKey ?? '',
      lidarrHeaders: lidarrHeaders ?? {},
      lidarrLocalHost: lidarrLocalHost ?? '',
      lidarrLocalSsids: lidarrLocalSsids ?? '',
      // Radarr
      radarrEnabled: radarrEnabled ?? false,
      radarrHost: radarrHost ?? '',
      radarrKey: radarrKey ?? '',
      radarrHeaders: radarrHeaders ?? {},
      radarrLocalHost: radarrLocalHost ?? '',
      radarrLocalSsids: radarrLocalSsids ?? '',
      // Sonarr
      sonarrEnabled: sonarrEnabled ?? false,
      sonarrHost: sonarrHost ?? '',
      sonarrKey: sonarrKey ?? '',
      sonarrHeaders: sonarrHeaders ?? {},
      sonarrLocalHost: sonarrLocalHost ?? '',
      sonarrLocalSsids: sonarrLocalSsids ?? '',
      // SABnzbd
      sabnzbdEnabled: sabnzbdEnabled ?? false,
      sabnzbdHost: sabnzbdHost ?? '',
      sabnzbdKey: sabnzbdKey ?? '',
      sabnzbdHeaders: sabnzbdHeaders ?? {},
      sabnzbdLocalHost: sabnzbdLocalHost ?? '',
      sabnzbdLocalSsids: sabnzbdLocalSsids ?? '',
      // NZBGet
      nzbgetEnabled: nzbgetEnabled ?? false,
      nzbgetHost: nzbgetHost ?? '',
      nzbgetUser: nzbgetUser ?? '',
      nzbgetPass: nzbgetPass ?? '',
      nzbgetHeaders: nzbgetHeaders ?? {},
      nzbgetLocalHost: nzbgetLocalHost ?? '',
      nzbgetLocalSsids: nzbgetLocalSsids ?? '',
      // Wake On LAN
      wakeOnLANEnabled: wakeOnLANEnabled ?? false,
      wakeOnLANBroadcastAddress: wakeOnLANBroadcastAddress ?? '',
      wakeOnLANMACAddress: wakeOnLANMACAddress ?? '',
      // Tautulli
      tautulliEnabled: tautulliEnabled ?? false,
      tautulliHost: tautulliHost ?? '',
      tautulliKey: tautulliKey ?? '',
      tautulliHeaders: tautulliHeaders ?? {},
      tautulliLocalHost: tautulliLocalHost ?? '',
      tautulliLocalSsids: tautulliLocalSsids ?? '',
      // Overseerr
      overseerrEnabled: overseerrEnabled ?? false,
      overseerrHost: overseerrHost ?? '',
      overseerrKey: overseerrKey ?? '',
      overseerrHeaders: overseerrHeaders ?? {},
      overseerrLocalHost: overseerrLocalHost ?? '',
      overseerrLocalSsids: overseerrLocalSsids ?? '',
      // Unraid
      unraidEnabled: unraidEnabled ?? false,
      unraidHost: unraidHost ?? '',
      unraidKey: unraidKey ?? '',
      unraidHeaders: unraidHeaders ?? {},
      unraidLocalHost: unraidLocalHost ?? '',
      unraidLocalSsids: unraidLocalSsids ?? '',
      // Readarr
      readarrEnabled: readarrEnabled ?? false,
      readarrHost: readarrHost ?? '',
      readarrKey: readarrKey ?? '',
      readarrHeaders: readarrHeaders ?? {},
      readarrLocalHost: readarrLocalHost ?? '',
      readarrLocalSsids: readarrLocalSsids ?? '',
    );
  }

  @override
  String toString() => json.encode(this.toJson());

  Map<String, dynamic> toJson() {
    final json = _$ZagProfileToJson(this);
    json['key'] = key.toString();
    return json;
  }

  factory ZagProfile.fromJson(Map<String, dynamic> json) {
    return _$ZagProfileFromJson(json);
  }

  factory ZagProfile.clone(ZagProfile profile) {
    return ZagProfile.fromJson(profile.toJson().cast<String, dynamic>());
  }

  factory ZagProfile.get(String key) {
    return ZagBox.profiles.read(key)!;
  }

  bool isAnythingEnabled() {
    for (final module in ZagModule.active) {
      if (module.isEnabled) return true;
    }
    return false;
  }

  String effectiveLidarrHost() => ZagLocalConnectionService().resolveHost(
        remoteHost: lidarrHost,
        localHost: lidarrLocalHost,
        ssidList: lidarrLocalSsids,
      );

  String effectiveRadarrHost() => ZagLocalConnectionService().resolveHost(
        remoteHost: radarrHost,
        localHost: radarrLocalHost,
        ssidList: radarrLocalSsids,
      );

  String effectiveSonarrHost() => ZagLocalConnectionService().resolveHost(
        remoteHost: sonarrHost,
        localHost: sonarrLocalHost,
        ssidList: sonarrLocalSsids,
      );

  String effectiveSabnzbdHost() => ZagLocalConnectionService().resolveHost(
        remoteHost: sabnzbdHost,
        localHost: sabnzbdLocalHost,
        ssidList: sabnzbdLocalSsids,
      );

  String effectiveNzbgetHost() => ZagLocalConnectionService().resolveHost(
        remoteHost: nzbgetHost,
        localHost: nzbgetLocalHost,
        ssidList: nzbgetLocalSsids,
      );

  String effectiveTautulliHost() => ZagLocalConnectionService().resolveHost(
        remoteHost: tautulliHost,
        localHost: tautulliLocalHost,
        ssidList: tautulliLocalSsids,
      );

  String effectiveOverseerrHost() => ZagLocalConnectionService().resolveHost(
        remoteHost: overseerrHost,
        localHost: overseerrLocalHost,
        ssidList: overseerrLocalSsids,
      );

  String effectiveUnraidHost() => ZagLocalConnectionService().resolveHost(
        remoteHost: unraidHost,
        localHost: unraidLocalHost,
        ssidList: unraidLocalSsids,
      );

  String effectiveReadarrHost() => ZagLocalConnectionService().resolveHost(
        remoteHost: readarrHost,
        localHost: readarrLocalHost,
        ssidList: readarrLocalSsids,
      );

  // ============== Multi-Instance (Shadow Profile) Support ==============

  /// Shadow profile key format: `__<module>__<name>__<parentProfile>`
  static const String _shadowPrefix = '__';
  static const String _shadowDelimiter = '__';

  /// Check if a profile key is a shadow profile
  static bool isShadowProfile(String profileKey) {
    return profileKey.startsWith(_shadowPrefix);
  }

  /// Get visible profiles (filters out shadow profiles)
  static List<String> get visibleList {
    return list.where((key) => !isShadowProfile(key)).toList();
  }

  /// Parse shadow profile key into components
  static ({String module, String name, String parent})? parseShadowKey(
      String key) {
    if (!isShadowProfile(key)) return null;
    final parts = key.substring(_shadowPrefix.length).split(_shadowDelimiter);
    if (parts.length != 3) return null;
    return (module: parts[0], name: parts[1], parent: parts[2]);
  }

  /// Build a shadow profile key
  static String buildShadowKey({
    required String module,
    required String name,
    required String parent,
  }) {
    return '$_shadowPrefix$module$_shadowDelimiter$name$_shadowDelimiter$parent';
  }

  /// Get all shadow profiles for a parent profile
  static List<String> getInstancesForProfile(String parentProfile) {
    final dynamic instances = ZagreusDatabase.PROFILE_INSTANCES.read();
    print('🔍 getInstancesForProfile: parentProfile=$parentProfile, raw instances=$instances, type=${instances.runtimeType}');
    if (instances == null || instances is! Map) return [];
    final dynamic list = instances[parentProfile];
    print('🔍 getInstancesForProfile: list for $parentProfile = $list');
    if (list == null || list is! List) return [];
    return list.cast<String>();
  }

  /// Get shadow profiles for a specific module under a parent
  static List<String> getInstancesForModule(String parentProfile, String moduleKey) {
    return getInstancesForProfile(parentProfile).where((key) {
      final parsed = parseShadowKey(key);
      return parsed != null && parsed.module == moduleKey;
    }).toList();
  }

  /// Create a new shadow profile for a module
  static Future<String?> createInstance({
    required String moduleKey,
    required String instanceName,
    required String parentProfile,
  }) async {
    // Validate no underscores in name
    if (instanceName.contains('_')) {
      return null; // Caller should show toast
    }

    final shadowKey = buildShadowKey(
      module: moduleKey,
      name: instanceName.replaceAll(' ', '-'),
      parent: parentProfile,
    );

    // Check if already exists
    if (ZagBox.profiles.contains(shadowKey)) {
      return null;
    }

    // Create empty profile (only the specific module will be configured)
    final profile = ZagProfile();
    await ZagBox.profiles.update(shadowKey, profile);

    // Add to instances list
    final dynamic currentInstances = ZagreusDatabase.PROFILE_INSTANCES.read();
    final Map<String, List<String>> instances = {};
    if (currentInstances is Map) {
      for (final entry in currentInstances.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is List) {
          instances[key] = value.cast<String>();
        }
      }
    }
    instances.putIfAbsent(parentProfile, () => []);
    instances[parentProfile]!.add(shadowKey);
    ZagreusDatabase.PROFILE_INSTANCES.update(instances);

    return shadowKey;
  }

  /// Rename a shadow profile
  static Future<String?> renameInstance(String oldKey, String newName) async {
    final parsed = parseShadowKey(oldKey);
    if (parsed == null) return null;

    // Validate new name
    final sanitized = newName.trim().replaceAll(' ', '-');
    if (sanitized.isEmpty || sanitized.contains('_')) return null;

    // Get old profile data
    final oldProfile = ZagBox.profiles.read(oldKey);
    if (oldProfile == null) return null;

    // Create new key
    final newKey = '__${parsed.module}__${sanitized}__${parsed.parent}';
    
    // Skip if key is the same
    if (newKey == oldKey) return oldKey;

    // Save profile with new key
    await ZagBox.profiles.update(newKey, oldProfile);
    await ZagBox.profiles.delete(oldKey);

    // Update instances list
    final dynamic currentInstances = ZagreusDatabase.PROFILE_INSTANCES.read();
    final Map<String, List<String>> instances = {};
    if (currentInstances is Map) {
      for (final entry in currentInstances.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is List) {
          instances[key] = value.cast<String>();
        }
      }
    }
    
    final list = instances[parsed.parent] ?? [];
    final idx = list.indexOf(oldKey);
    if (idx >= 0) {
      list[idx] = newKey;
    }
    instances[parsed.parent] = list;
    ZagreusDatabase.PROFILE_INSTANCES.update(instances);

    return newKey;
  }

  /// Delete a shadow profile
  static Future<void> deleteInstance(String shadowKey) async {
    final parsed = parseShadowKey(shadowKey);
    if (parsed == null) return;

    // Remove from profiles box
    await ZagBox.profiles.delete(shadowKey);

    // Remove from instances list
    final dynamic currentInstances = ZagreusDatabase.PROFILE_INSTANCES.read();
    final Map<String, List<String>> instances = {};
    if (currentInstances is Map) {
      for (final entry in currentInstances.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (value is List) {
          instances[key] = value.cast<String>();
        }
      }
    }
    instances[parsed.parent]?.remove(shadowKey);
    ZagreusDatabase.PROFILE_INSTANCES.update(instances);
  }

  /// Get display name for a shadow profile
  static String? getInstanceDisplayName(String shadowKey) {
    final parsed = parseShadowKey(shadowKey);
    if (parsed == null) return null;
    // Convert dashes back to spaces
    return parsed.name.replaceAll('-', ' ');
  }
}
