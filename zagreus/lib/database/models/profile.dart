import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/modules.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/system/network/local_switching_service.dart';

part 'profile.g.dart';

@JsonSerializable()
@HiveType(typeId: 0, adapterName: 'ZagProfileAdapter')
class ZagProfile extends HiveObject {
  static const String DEFAULT_PROFILE = 'default';

  static ZagProfile get current {
    final enabled = ZagreusDatabase.ENABLED_PROFILE.read();
    return ZagBox.profiles.read(enabled) ?? ZagProfile();
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
  @HiveField(44, defaultValue: false)
  bool serverEnabled;

  @JsonKey()
  @HiveField(45, defaultValue: '')
  String serverHost;

  @JsonKey()
  @HiveField(46, defaultValue: '')
  String serverKey;

  @JsonKey()
  @HiveField(47, defaultValue: <String, String>{})
  Map<String, String> serverHeaders;

  @JsonKey()
  @HiveField(60, defaultValue: '')
  String serverLocalHost;

  @JsonKey()
  @HiveField(61, defaultValue: '')
  String serverLocalSsids;

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
    //Server
    required this.serverEnabled,
    required this.serverHost,
    required this.serverKey,
    required this.serverHeaders,
    required this.serverLocalHost,
    required this.serverLocalSsids,
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
    //Server
    bool? serverEnabled,
    String? serverHost,
    String? serverKey,
    Map<String, String>? serverHeaders,
    String? serverLocalHost,
    String? serverLocalSsids,
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
      // Server
      serverEnabled: serverEnabled ?? false,
      serverHost: serverHost ?? '',
      serverKey: serverKey ?? '',
      serverHeaders: serverHeaders ?? {},
      serverLocalHost: serverLocalHost ?? '',
      serverLocalSsids: serverLocalSsids ?? '',
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

  String effectiveServerHost() => ZagLocalConnectionService().resolveHost(
        remoteHost: serverHost,
        localHost: serverLocalHost,
        ssidList: serverLocalSsids,
      );
}
