import 'package:uuid/uuid.dart';
import 'package:zagreus/vendor.dart';

part 'ssh_connection.g.dart';

@HiveType(typeId: 30, adapterName: 'SSHAuthTypeAdapter')
enum SSHAuthType {
  @HiveField(0)
  password,
  @HiveField(1)
  privateKey,
}

@JsonSerializable()
@HiveType(typeId: 31, adapterName: 'SSHConnectionAdapter')
class SSHConnection extends HiveObject {
  @JsonKey()
  @HiveField(9, defaultValue: '')
  String profileId;

  @JsonKey()
  @HiveField(0, defaultValue: '')
  String id;

  @JsonKey()
  @HiveField(1, defaultValue: '')
  String name;

  @JsonKey()
  @HiveField(2, defaultValue: '')
  String host;

  @JsonKey()
  @HiveField(3, defaultValue: 22)
  int port;

  @JsonKey()
  @HiveField(4, defaultValue: '')
  String username;

  @JsonKey()
  @HiveField(5, defaultValue: SSHAuthType.password)
  SSHAuthType authType;

  @JsonKey()
  @HiveField(6, defaultValue: '')
  String password;

  @JsonKey()
  @HiveField(7, defaultValue: '')
  String privateKey;

  @JsonKey()
  @HiveField(8, defaultValue: '')
  String passphrase;

  @JsonKey()
  @HiveField(10, defaultValue: '')
  String localHost;

  @JsonKey()
  @HiveField(11, defaultValue: '')
  String localSsids;

  @JsonKey()
  @HiveField(12, defaultValue: '')
  String hostKeyFingerprint;

  @JsonKey()
  @HiveField(13, defaultValue: '')
  String hostKeyType;

  SSHConnection({
    required this.profileId,
    required this.id,
    required this.name,
    required this.host,
    this.port = 22,
    required this.username,
    this.authType = SSHAuthType.password,
    this.password = '',
    this.privateKey = '',
    this.passphrase = '',
    this.localHost = '',
    this.localSsids = '',
    this.hostKeyFingerprint = '',
    this.hostKeyType = '',
  });

  factory SSHConnection.create({
    required String profileId,
    required String name,
    required String host,
    int port = 22,
    required String username,
    SSHAuthType authType = SSHAuthType.password,
    String password = '',
    String privateKey = '',
    String passphrase = '',
    String localHost = '',
    String localSsids = '',
    String hostKeyFingerprint = '',
    String hostKeyType = '',
  }) {
    return SSHConnection(
      profileId: profileId,
      id: Uuid().v4(),
      name: name,
      host: host,
      port: port,
      username: username,
      authType: authType,
      password: password,
      privateKey: privateKey,
      passphrase: passphrase,
      localHost: localHost,
      localSsids: localSsids,
      hostKeyFingerprint: hostKeyFingerprint,
      hostKeyType: hostKeyType,
    );
  }

  Map<String, dynamic> toJson() => _$SSHConnectionToJson(this);

  factory SSHConnection.fromJson(Map<String, dynamic> json) =>
      _$SSHConnectionFromJson(json);

  SSHConnection copyWith({
    String? profileId,
    String? name,
    String? host,
    int? port,
    String? username,
    SSHAuthType? authType,
    String? password,
    String? privateKey,
    String? passphrase,
    String? localHost,
    String? localSsids,
    String? hostKeyFingerprint,
    String? hostKeyType,
  }) {
    return SSHConnection(
      profileId: profileId ?? this.profileId,
      id: id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      password: password ?? this.password,
      privateKey: privateKey ?? this.privateKey,
      passphrase: passphrase ?? this.passphrase,
      localHost: localHost ?? this.localHost,
      localSsids: localSsids ?? this.localSsids,
      hostKeyFingerprint: hostKeyFingerprint ?? this.hostKeyFingerprint,
      hostKeyType: hostKeyType ?? this.hostKeyType,
    );
  }

  @override
  String toString() => 'SSHConnection($name @ $host:$port)';
}
