// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnraidSystemInfo _$UnraidSystemInfoFromJson(Map<String, dynamic> json) =>
    UnraidSystemInfo(
      name: json['name'] as String,
      version: json['version'] as String,
      registrationType: json['registrationType'] as String?,
      os: UnraidOSInfo.fromJson(json['os'] as Map<String, dynamic>),
      cpu: json['cpu'] == null
          ? null
          : UnraidCPUInfo.fromJson(json['cpu'] as Map<String, dynamic>),
      memory: json['memory'] == null
          ? null
          : UnraidMemoryInfo.fromJson(json['memory'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UnraidSystemInfoToJson(UnraidSystemInfo instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'version': instance.version,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('registrationType', instance.registrationType);
  val['os'] = instance.os.toJson();
  writeNotNull('cpu', instance.cpu?.toJson());
  writeNotNull('memory', instance.memory?.toJson());
  return val;
}

UnraidOSInfo _$UnraidOSInfoFromJson(Map<String, dynamic> json) => UnraidOSInfo(
      platform: json['platform'] as String?,
      distro: json['distro'] as String?,
      release: json['release'] as String?,
      uptime: json['uptime'] as String?,
    );

Map<String, dynamic> _$UnraidOSInfoToJson(UnraidOSInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('platform', instance.platform);
  writeNotNull('distro', instance.distro);
  writeNotNull('release', instance.release);
  writeNotNull('uptime', instance.uptime);
  return val;
}

UnraidCPUInfo _$UnraidCPUInfoFromJson(Map<String, dynamic> json) =>
    UnraidCPUInfo(
      manufacturer: json['manufacturer'] as String?,
      brand: json['brand'] as String?,
      cores: parseNullableInt(json['cores']),
      threads: parseNullableInt(json['threads']),
    );

Map<String, dynamic> _$UnraidCPUInfoToJson(UnraidCPUInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('manufacturer', instance.manufacturer);
  writeNotNull('brand', instance.brand);
  writeNotNull('cores', instance.cores);
  writeNotNull('threads', instance.threads);
  return val;
}

UnraidMemoryInfo _$UnraidMemoryInfoFromJson(Map<String, dynamic> json) =>
    UnraidMemoryInfo(
      total: parseNullableInt(json['total']),
      free: parseNullableInt(json['free']),
      used: parseNullableInt(json['used']),
      layout: (json['layout'] as List<dynamic>?)
          ?.map((e) => UnraidMemoryLayout.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnraidMemoryInfoToJson(UnraidMemoryInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('total', instance.total);
  writeNotNull('free', instance.free);
  writeNotNull('used', instance.used);
  writeNotNull('layout', instance.layout?.map((e) => e.toJson()).toList());
  return val;
}

UnraidMemoryLayout _$UnraidMemoryLayoutFromJson(Map<String, dynamic> json) =>
    UnraidMemoryLayout(
      type: json['type'] as String?,
      clockSpeed: parseNullableInt(json['clockSpeed']),
    );

Map<String, dynamic> _$UnraidMemoryLayoutToJson(UnraidMemoryLayout instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', instance.type);
  writeNotNull('clockSpeed', instance.clockSpeed);
  return val;
}
