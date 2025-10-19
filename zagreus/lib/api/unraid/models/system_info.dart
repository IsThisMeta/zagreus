import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/unraid/json_helpers.dart';

part 'system_info.g.dart';

/// System information from Unraid server
@JsonSerializable()
class UnraidSystemInfo {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'version')
  final String version;

  @JsonKey(name: 'os')
  final UnraidOSInfo os;

  @JsonKey(name: 'cpu')
  final UnraidCPUInfo? cpu;

  @JsonKey(name: 'memory')
  final UnraidMemoryInfo? memory;

  UnraidSystemInfo({
    required this.name,
    required this.version,
    required this.os,
    this.cpu,
    this.memory,
  });

  factory UnraidSystemInfo.fromJson(Map<String, dynamic> json) =>
      _$UnraidSystemInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UnraidSystemInfoToJson(this);
}

/// OS information
@JsonSerializable()
class UnraidOSInfo {
  @JsonKey(name: 'platform')
  final String? platform;

  @JsonKey(name: 'distro')
  final String? distro;

  @JsonKey(name: 'release')
  final String? release;

  @JsonKey(name: 'uptime', fromJson: parseNullableInt)
  final int? uptime; // in seconds

  UnraidOSInfo({
    this.platform,
    this.distro,
    this.release,
    this.uptime,
  });

  factory UnraidOSInfo.fromJson(Map<String, dynamic> json) {
    return UnraidOSInfo(
      platform: json['platform'] as String?,
      distro: json['distro'] as String?,
      release: json['release'] as String?,
      uptime: parseNullableInt(json['uptime']),
    );
  }

  Map<String, dynamic> toJson() => _$UnraidOSInfoToJson(this);

  /// Format uptime as human-readable string like "3 days, 1 hour, 43 minutes"
  String get formattedUptime {
    if (uptime == null) return '';
    int seconds = uptime!;
    int days = seconds ~/ 86400;
    seconds %= 86400;
    int hours = seconds ~/ 3600;
    seconds %= 3600;
    int minutes = seconds ~/ 60;

    List<String> parts = [];
    if (days > 0) parts.add('$days day${days != 1 ? 's' : ''}');
    if (hours > 0) parts.add('$hours hour${hours != 1 ? 's' : ''}');
    if (minutes > 0) parts.add('$minutes minute${minutes != 1 ? 's' : ''}');

    return parts.join(', ');
  }
}

/// CPU information
@JsonSerializable()
class UnraidCPUInfo {
  @JsonKey(name: 'manufacturer')
  final String? manufacturer;

  @JsonKey(name: 'brand')
  final String? brand;

  @JsonKey(name: 'cores', fromJson: parseNullableInt)
  final int? cores;

  @JsonKey(name: 'threads', fromJson: parseNullableInt)
  final int? threads;

  UnraidCPUInfo({
    this.manufacturer,
    this.brand,
    this.cores,
    this.threads,
  });

  factory UnraidCPUInfo.fromJson(Map<String, dynamic> json) {
    return UnraidCPUInfo(
      manufacturer: json['manufacturer'] as String?,
      brand: json['brand'] as String?,
      cores: parseNullableInt(json['cores']),
      threads: parseNullableInt(json['threads']),
    );
  }

  Map<String, dynamic> toJson() => _$UnraidCPUInfoToJson(this);
}

/// Memory information
@JsonSerializable()
class UnraidMemoryInfo {
  @JsonKey(name: 'total', fromJson: parseNullableInt)
  final int? total; // in bytes

  @JsonKey(name: 'free', fromJson: parseNullableInt)
  final int? free; // in bytes

  @JsonKey(name: 'used', fromJson: parseNullableInt)
  final int? used; // in bytes

  UnraidMemoryInfo({
    this.total,
    this.free,
    this.used,
  });

  factory UnraidMemoryInfo.fromJson(Map<String, dynamic> json) {
    return UnraidMemoryInfo(
      total: parseNullableInt(json['total']),
      free: parseNullableInt(json['free']),
      used: parseNullableInt(json['used']),
    );
  }

  Map<String, dynamic> toJson() => _$UnraidMemoryInfoToJson(this);

  /// Calculate percentage used
  double? get percentUsed {
    if (total == null || used == null || total == 0) return null;
    return (used! / total!) * 100.0;
  }
}
