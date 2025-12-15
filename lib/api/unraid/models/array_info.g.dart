// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'array_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnraidArrayInfo _$UnraidArrayInfoFromJson(Map<String, dynamic> json) =>
    UnraidArrayInfo(
      state: json['state'] as String,
      capacity: json['capacity'] == null
          ? null
          : UnraidArrayCapacity.fromJson(
              json['capacity'] as Map<String, dynamic>),
      disks: (json['disks'] as List<dynamic>?)
              ?.map((e) => UnraidDisk.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      caches: (json['caches'] as List<dynamic>?)
              ?.map((e) => UnraidDisk.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      parities: (json['parities'] as List<dynamic>?)
              ?.map((e) => UnraidDisk.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UnraidArrayInfoToJson(UnraidArrayInfo instance) {
  final val = <String, dynamic>{
    'state': instance.state,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('capacity', instance.capacity?.toJson());
  val['disks'] = instance.disks.map((e) => e.toJson()).toList();
  val['caches'] = instance.caches.map((e) => e.toJson()).toList();
  val['parities'] = instance.parities.map((e) => e.toJson()).toList();
  return val;
}

UnraidArrayCapacity _$UnraidArrayCapacityFromJson(Map<String, dynamic> json) =>
    UnraidArrayCapacity(
      total: parseNullableInt(json['total']),
      used: parseNullableInt(json['used']),
      free: parseNullableInt(json['free']),
    );

Map<String, dynamic> _$UnraidArrayCapacityToJson(UnraidArrayCapacity instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('total', instance.total);
  writeNotNull('used', instance.used);
  writeNotNull('free', instance.free);
  return val;
}

UnraidDisk _$UnraidDiskFromJson(Map<String, dynamic> json) => UnraidDisk(
      name: json['name'] as String,
      status: json['status'] as String?,
      temp: parseNullableInt(json['temp']),
      critical: parseNullableInt(json['critical']),
      warning: parseNullableInt(json['warning']),
      size: parseNullableInt(json['size']),
      fsSize: parseNullableInt(json['fsSize']),
      fsUsed: parseNullableInt(json['fsUsed']),
      fsFree: parseNullableInt(json['fsFree']),
      numErrors: parseNullableInt(json['numErrors']),
    );

Map<String, dynamic> _$UnraidDiskToJson(UnraidDisk instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('status', instance.status);
  writeNotNull('temp', instance.temp);
  writeNotNull('critical', instance.critical);
  writeNotNull('warning', instance.warning);
  writeNotNull('size', instance.size);
  writeNotNull('fsSize', instance.fsSize);
  writeNotNull('fsUsed', instance.fsUsed);
  writeNotNull('fsFree', instance.fsFree);
  writeNotNull('numErrors', instance.numErrors);
  return val;
}
