// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docker_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnraidDockerInfo _$UnraidDockerInfoFromJson(Map<String, dynamic> json) =>
    UnraidDockerInfo(
      containers: (json['containers'] as List<dynamic>)
          .map((e) => UnraidDockerContainer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnraidDockerInfoToJson(UnraidDockerInfo instance) =>
    <String, dynamic>{
      'containers': instance.containers.map((e) => e.toJson()).toList(),
    };

UnraidDockerContainer _$UnraidDockerContainerFromJson(
        Map<String, dynamic> json) =>
    UnraidDockerContainer(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      state: json['state'] as String,
      status: json['status'] as String?,
      health: json['health'] as String?,
      autostart: json['autostart'] as bool?,
      icon: json['icon'] as String?,
      version: json['version'] as String?,
      updated: json['updated'] as String?,
      ports: (json['ports'] as List<dynamic>?)
          ?.map((e) => UnraidDockerPort.fromJson(e as Map<String, dynamic>))
          .toList(),
      networks: (json['networks'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      volumes: (json['volumes'] as List<dynamic>?)
          ?.map((e) => UnraidDockerVolume.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnraidDockerContainerToJson(
    UnraidDockerContainer instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('image', instance.image);
  val['state'] = instance.state;
  writeNotNull('status', instance.status);
  writeNotNull('health', instance.health);
  writeNotNull('autostart', instance.autostart);
  writeNotNull('icon', instance.icon);
  writeNotNull('version', instance.version);
  writeNotNull('updated', instance.updated);
  writeNotNull('ports', instance.ports?.map((e) => e.toJson()).toList());
  writeNotNull('networks', instance.networks);
  writeNotNull('volumes', instance.volumes?.map((e) => e.toJson()).toList());
  return val;
}

UnraidDockerPort _$UnraidDockerPortFromJson(Map<String, dynamic> json) =>
    UnraidDockerPort(
      containerPort: parseRequiredInt(json['container']),
      hostPort: parseNullableInt(json['host']),
      protocol: json['protocol'] as String?,
    );

Map<String, dynamic> _$UnraidDockerPortToJson(UnraidDockerPort instance) {
  final val = <String, dynamic>{
    'container': instance.containerPort,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('host', instance.hostPort);
  writeNotNull('protocol', instance.protocol);
  return val;
}

UnraidDockerVolume _$UnraidDockerVolumeFromJson(Map<String, dynamic> json) =>
    UnraidDockerVolume(
      containerPath: json['container'] as String,
      hostPath: json['host'] as String?,
      mode: json['mode'] as String?,
    );

Map<String, dynamic> _$UnraidDockerVolumeToJson(UnraidDockerVolume instance) {
  final val = <String, dynamic>{
    'container': instance.containerPath,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('host', instance.hostPath);
  writeNotNull('mode', instance.mode);
  return val;
}
