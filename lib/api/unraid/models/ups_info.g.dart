// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ups_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnraidUpsInfo _$UnraidUpsInfoFromJson(Map<String, dynamic> json) =>
    UnraidUpsInfo(
      id: json['id'] as String?,
      name: json['name'] as String?,
      model: json['model'] as String?,
      status: json['status'] as String?,
      battery: json['battery'] == null
          ? null
          : UnraidUpsBattery.fromJson(json['battery'] as Map<String, dynamic>),
      power: json['power'] == null
          ? null
          : UnraidUpsPower.fromJson(json['power'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UnraidUpsInfoToJson(UnraidUpsInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('model', instance.model);
  writeNotNull('status', instance.status);
  writeNotNull('battery', instance.battery?.toJson());
  writeNotNull('power', instance.power?.toJson());
  return val;
}

UnraidUpsBattery _$UnraidUpsBatteryFromJson(Map<String, dynamic> json) =>
    UnraidUpsBattery(
      chargeLevel: parseNullableInt(json['chargeLevel']),
      estimatedRuntime: parseNullableInt(json['estimatedRuntime']),
      health: json['health'] as String?,
    );

Map<String, dynamic> _$UnraidUpsBatteryToJson(UnraidUpsBattery instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('chargeLevel', instance.chargeLevel);
  writeNotNull('estimatedRuntime', instance.estimatedRuntime);
  writeNotNull('health', instance.health);
  return val;
}

UnraidUpsPower _$UnraidUpsPowerFromJson(Map<String, dynamic> json) =>
    UnraidUpsPower(
      loadPercentage: parseNullableInt(json['loadPercentage']),
    );

Map<String, dynamic> _$UnraidUpsPowerToJson(UnraidUpsPower instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('loadPercentage', instance.loadPercentage);
  return val;
}
