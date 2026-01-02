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

  SSHConnection({
    required this.id,
    required this.name,
    required this.host,
    this.port = 22,
    required this.username,
    this.authType = SSHAuthType.password,
    this.password = '',
    this.privateKey = '',
    this.passphrase = '',
  });

  factory SSHConnection.create({
    required String name,
    required String host,
    int port = 22,
    required String username,
    SSHAuthType authType = SSHAuthType.password,
    String password = '',
    String privateKey = '',
    String passphrase = '',
  }) {
    return SSHConnection(
      id: Uuid().v4(),
      name: name,
      host: host,
      port: port,
      username: username,
      authType: authType,
      password: password,
      privateKey: privateKey,
      passphrase: passphrase,
    );
  }

  Map<String, dynamic> toJson() => _$SSHConnectionToJson(this);

  factory SSHConnection.fromJson(Map<String, dynamic> json) =>
      _$SSHConnectionFromJson(json);

  SSHConnection copyWith({
    String? name,
    String? host,
    int? port,
    String? username,
    SSHAuthType? authType,
    String? password,
    String? privateKey,
    String? passphrase,
  }) {
    return SSHConnection(
      id: id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      password: password ?? this.password,
      privateKey: privateKey ?? this.privateKey,
      passphrase: passphrase ?? this.passphrase,
    );
  }

  @override
  String toString() => 'SSHConnection($name @ $host:$port)';
}
