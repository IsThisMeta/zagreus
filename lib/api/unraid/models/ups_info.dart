import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/unraid/json_helpers.dart';

part 'ups_info.g.dart';

/// UPS/Power information from Unraid server
@JsonSerializable()
class UnraidUpsInfo {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'model')
  final String? model;

  @JsonKey(name: 'status')
  final String? status; // "Online", "OnBattery", etc.

  @JsonKey(name: 'battery')
  final UnraidUpsBattery? battery;

  @JsonKey(name: 'power')
  final UnraidUpsPower? power;

  UnraidUpsInfo({
    this.id,
    this.name,
    this.model,
    this.status,
    this.battery,
    this.power,
  });

  factory UnraidUpsInfo.fromJson(Map<String, dynamic> json) =>
      _$UnraidUpsInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UnraidUpsInfoToJson(this);

  /// Check if UPS is connected
  bool get hasUps => model != null || name != null;

  /// Check if UPS is online
  bool get isOnline => status?.toLowerCase() == 'online';

  /// Get display name (model or name)
  String get displayName => model ?? name ?? 'Unknown UPS';
}

/// UPS Battery information
@JsonSerializable()
class UnraidUpsBattery {
  @JsonKey(name: 'chargeLevel', fromJson: parseNullableInt)
  final int? chargeLevel; // 0-100

  @JsonKey(name: 'estimatedRuntime', fromJson: parseNullableInt)
  final int? estimatedRuntime; // in minutes

  @JsonKey(name: 'health')
  final String? health;

  UnraidUpsBattery({
    this.chargeLevel,
    this.estimatedRuntime,
    this.health,
  });

  factory UnraidUpsBattery.fromJson(Map<String, dynamic> json) {
    return UnraidUpsBattery(
      chargeLevel: parseNullableInt(json['chargeLevel']),
      estimatedRuntime: parseNullableInt(json['estimatedRuntime']),
      health: json['health'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$UnraidUpsBatteryToJson(this);
}

/// UPS Power information
@JsonSerializable()
class UnraidUpsPower {
  @JsonKey(name: 'loadPercentage', fromJson: parseNullableInt)
  final int? loadPercentage; // 0-100

  UnraidUpsPower({
    this.loadPercentage,
  });

  factory UnraidUpsPower.fromJson(Map<String, dynamic> json) {
    return UnraidUpsPower(
      loadPercentage: parseNullableInt(json['loadPercentage']),
    );
  }

  Map<String, dynamic> toJson() => _$UnraidUpsPowerToJson(this);
}
