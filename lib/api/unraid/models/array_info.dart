import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/unraid/json_helpers.dart';

part 'array_info.g.dart';

/// Array information from Unraid server
@JsonSerializable()
class UnraidArrayInfo {
  @JsonKey(name: 'state')
  final String state; // "Started" or "Stopped"

  @JsonKey(name: 'capacity')
  final UnraidArrayCapacity? capacity;

  @JsonKey(name: 'disks')
  final List<UnraidDisk> disks;

  @JsonKey(name: 'caches')
  final List<UnraidDisk> caches;

  @JsonKey(name: 'parities')
  final List<UnraidDisk> parities;

  UnraidArrayInfo({
    required this.state,
    this.capacity,
    this.disks = const [],
    this.caches = const [],
    this.parities = const [],
  });

  factory UnraidArrayInfo.fromJson(Map<String, dynamic> json) =>
      _$UnraidArrayInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UnraidArrayInfoToJson(this);

  /// Check if array is started
  bool get isStarted => state.toLowerCase() == 'started';
}

/// Array capacity information
@JsonSerializable()
class UnraidArrayCapacity {
  @JsonKey(name: 'total', fromJson: parseNullableInt)
  final int? total; // in kilobytes

  @JsonKey(name: 'used', fromJson: parseNullableInt)
  final int? used; // in kilobytes

  @JsonKey(name: 'free', fromJson: parseNullableInt)
  final int? free; // in kilobytes

  UnraidArrayCapacity({
    this.total,
    this.used,
    this.free,
  });

  factory UnraidArrayCapacity.fromJson(Map<String, dynamic> json) {
    return UnraidArrayCapacity(
      total: parseNullableInt(json['total']),
      used: parseNullableInt(json['used']),
      free: parseNullableInt(json['free']),
    );
  }

  Map<String, dynamic> toJson() => _$UnraidArrayCapacityToJson(this);

  /// Calculate percentage used
  double? get percentUsed {
    if (total == null || used == null || total == 0) return null;
    return (used! / total!) * 100.0;
  }

  /// Convert kilobytes to terabytes
  double? get totalTB {
    if (total == null) return null;
    return total! / 1024 / 1024 / 1024;
  }

  double? get usedTB {
    if (used == null) return null;
    return used! / 1024 / 1024 / 1024;
  }

  double? get freeTB {
    if (free == null) return null;
    return free! / 1024 / 1024 / 1024;
  }
}

/// Storage disk information
@JsonSerializable()
class UnraidDisk {
  @JsonKey(name: 'name')
  final String name; // e.g., "Disk1", "Parity", "Cache"

  @JsonKey(name: 'status')
  final String? status; // e.g., "DISK_OK", "DISK_NEW", etc.

  @JsonKey(name: 'temp', fromJson: parseNullableInt)
  final int? temp; // temperature in Celsius

  @JsonKey(name: 'critical', fromJson: parseNullableInt)
  final int? critical; // critical temperature threshold

  @JsonKey(name: 'warning', fromJson: parseNullableInt)
  final int? warning; // warning temperature threshold

  @JsonKey(name: 'size', fromJson: parseNullableInt)
  final int? size; // disk size in bytes

  @JsonKey(name: 'fsSize', fromJson: parseNullableInt)
  final int? fsSize; // filesystem size in bytes

  @JsonKey(name: 'fsUsed', fromJson: parseNullableInt)
  final int? fsUsed; // filesystem used in bytes

  @JsonKey(name: 'fsFree', fromJson: parseNullableInt)
  final int? fsFree; // filesystem free in bytes

  @JsonKey(name: 'numErrors', fromJson: parseNullableInt)
  final int? numErrors; // number of errors

  UnraidDisk({
    required this.name,
    this.status,
    this.temp,
    this.critical,
    this.warning,
    this.size,
    this.fsSize,
    this.fsUsed,
    this.fsFree,
    this.numErrors,
  });

  factory UnraidDisk.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    if (name == null) {
      throw const FormatException('Unraid disk is missing a name field.');
    }

    return UnraidDisk(
      name: name,
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
  }

  Map<String, dynamic> toJson() => _$UnraidDiskToJson(this);

  /// Check if disk is healthy
  bool get isHealthy {
    return status == 'DISK_OK' || status == 'DISK_NEW';
  }

  /// Calculate percentage used
  double? get percentUsed {
    if (fsSize == null || fsUsed == null || fsSize == 0) return null;
    return (fsUsed! / fsSize!) * 100.0;
  }

  /// Get temperature color status based on thresholds
  String get tempStatus {
    if (temp == null) return 'normal';
    if (critical != null && temp! >= critical!) return 'critical';
    if (warning != null && temp! >= warning!) return 'warning';
    return 'normal';
  }

  /// Get device name (placeholder for now - might come from additional API data)
  String? get deviceName => null;

  /// Get total size in TB
  double? get totalTB {
    if (size == null) return null;
    return size! / 1024 / 1024 / 1024 / 1024;
  }

  /// Get used size in TB
  double? get usedTB {
    if (fsUsed == null) return null;
    return fsUsed! / 1024 / 1024 / 1024 / 1024;
  }
}
