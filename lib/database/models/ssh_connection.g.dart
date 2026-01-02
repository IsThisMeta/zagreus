// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ssh_connection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SSHConnectionAdapter extends TypeAdapter<SSHConnection> {
  @override
  final int typeId = 31;

  @override
  SSHConnection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SSHConnection(
      id: fields[0] == null ? '' : fields[0] as String,
      name: fields[1] == null ? '' : fields[1] as String,
      host: fields[2] == null ? '' : fields[2] as String,
      port: fields[3] == null ? 22 : fields[3] as int,
      username: fields[4] == null ? '' : fields[4] as String,
      authType:
          fields[5] == null ? SSHAuthType.password : fields[5] as SSHAuthType,
      password: fields[6] == null ? '' : fields[6] as String,
      privateKey: fields[7] == null ? '' : fields[7] as String,
      passphrase: fields[8] == null ? '' : fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SSHConnection obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.host)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.authType)
      ..writeByte(6)
      ..write(obj.password)
      ..writeByte(7)
      ..write(obj.privateKey)
      ..writeByte(8)
      ..write(obj.passphrase);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SSHConnectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SSHAuthTypeAdapter extends TypeAdapter<SSHAuthType> {
  @override
  final int typeId = 30;

  @override
  SSHAuthType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SSHAuthType.password;
      case 1:
        return SSHAuthType.privateKey;
      default:
        return SSHAuthType.password;
    }
  }

  @override
  void write(BinaryWriter writer, SSHAuthType obj) {
    switch (obj) {
      case SSHAuthType.password:
        writer.writeByte(0);
        break;
      case SSHAuthType.privateKey:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SSHAuthTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SSHConnection _$SSHConnectionFromJson(Map<String, dynamic> json) =>
    SSHConnection(
      id: json['id'] as String,
      name: json['name'] as String,
      host: json['host'] as String,
      port: (json['port'] as num?)?.toInt() ?? 22,
      username: json['username'] as String,
      authType: $enumDecodeNullable(_$SSHAuthTypeEnumMap, json['authType']) ??
          SSHAuthType.password,
      password: json['password'] as String? ?? '',
      privateKey: json['privateKey'] as String? ?? '',
      passphrase: json['passphrase'] as String? ?? '',
    );

Map<String, dynamic> _$SSHConnectionToJson(SSHConnection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'host': instance.host,
      'port': instance.port,
      'username': instance.username,
      'authType': _$SSHAuthTypeEnumMap[instance.authType]!,
      'password': instance.password,
      'privateKey': instance.privateKey,
      'passphrase': instance.passphrase,
    };

const _$SSHAuthTypeEnumMap = {
  SSHAuthType.password: 'password',
  SSHAuthType.privateKey: 'privateKey',
};
