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

  @JsonKey(name: 'registrationType')
  final String? registrationType;

  @JsonKey(name: 'os')
  final UnraidOSInfo os;

  @JsonKey(name: 'cpu')
  final UnraidCPUInfo? cpu;

  @JsonKey(name: 'memory')
  final UnraidMemoryInfo? memory;

  UnraidSystemInfo({
    required this.name,
    required this.version,
    this.registrationType,
    required this.os,
    this.cpu,
    this.memory,
  });

  factory UnraidSystemInfo.fromJson(Map<String, dynamic> json) =>
      _$UnraidSystemInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UnraidSystemInfoToJson(this);

  /// Format registration type for display (e.g., "PRO" → "Unraid OS Pro")
  String get formattedRegistrationType {
    if (registrationType == null) return '';
    final type = registrationType!.toUpperCase();
    return 'Unraid OS $type';
  }
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

  @JsonKey(name: 'uptime')
  final String? uptime;

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
      uptime: json['uptime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => _$UnraidOSInfoToJson(this);

  /// Format uptime as human-readable string like "3 days, 1 hour, 43 minutes"
  String get formattedUptime {
    final raw = uptime?.trim() ?? '';
    if (raw.isEmpty) return 'Unknown';

    final seconds = int.tryParse(raw);
    if (seconds == null) {
      final parsedDate = DateTime.tryParse(raw);
      if (parsedDate == null) {
        return raw;
      }

      final nowUtc = DateTime.now().toUtc();
      final candidate = parsedDate.toUtc();
      final delta = nowUtc.difference(candidate);
      if (delta.isNegative) {
        return 'Just now';
      }
      return _formatDuration(delta.inSeconds);
    }

    if (seconds <= 0) {
      return 'Less than a minute';
    }

    return _formatDuration(seconds);
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    final parts = <String>[];
    if (days > 0) {
      parts.add('$days day${days == 1 ? '' : 's'}');
    }
    if (hours > 0) {
      parts.add('$hours hour${hours == 1 ? '' : 's'}');
    }
    if (minutes > 0) {
      parts.add('$minutes minute${minutes == 1 ? '' : 's'}');
    }
    if (parts.isEmpty) {
      if (secs > 0) {
        parts.add('$secs second${secs == 1 ? '' : 's'}');
      } else {
        parts.add('Less than a minute');
      }
    }

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

  @JsonKey(name: 'layout')
  final List<UnraidMemoryLayout>? layout;

  UnraidMemoryInfo({
    this.total,
    this.free,
    this.used,
    this.layout,
  });

  factory UnraidMemoryInfo.fromJson(Map<String, dynamic> json) {
    return UnraidMemoryInfo(
      total: parseNullableInt(json['total']),
      free: parseNullableInt(json['free']),
      used: parseNullableInt(json['used']),
      layout: (json['layout'] as List?)
          ?.map((e) => UnraidMemoryLayout.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => _$UnraidMemoryInfoToJson(this);

  /// Calculate percentage used
  double? get percentUsed {
    if (total == null || used == null || total == 0) return null;
    return (used! / total!) * 100.0;
  }

  /// Get formatted memory type and speed (e.g., "DDR3 (1867 MHz)")
  String get formattedTypeAndSpeed {
    if (layout == null || layout!.isEmpty) return '';
    final first = layout!.first;
    if (first.type == null && first.clockSpeed == null) return '';
    if (first.type != null && first.clockSpeed != null) {
      return '${first.type} (${first.clockSpeed} MHz)';
    }
    if (first.type != null) return first.type!;
    if (first.clockSpeed != null) return '${first.clockSpeed} MHz';
    return '';
  }

  /// Get total memory in GB
  double? get totalGB {
    if (total == null) return null;
    return total! / 1024 / 1024 / 1024;
  }

  /// Get free memory in GB
  double? get freeGB {
    if (free == null) return null;
    return free! / 1024 / 1024 / 1024;
  }
}

/// Memory layout information (type and speed)
@JsonSerializable()
class UnraidMemoryLayout {
  @JsonKey(name: 'type')
  final String? type; // e.g., "DDR3", "DDR4"

  @JsonKey(name: 'clockSpeed', fromJson: parseNullableInt)
  final int? clockSpeed; // in MHz

  UnraidMemoryLayout({
    this.type,
    this.clockSpeed,
  });

  factory UnraidMemoryLayout.fromJson(Map<String, dynamic> json) {
    return UnraidMemoryLayout(
      type: json['type'] as String?,
      clockSpeed: parseNullableInt(json['clockSpeed']),
    );
  }

  Map<String, dynamic> toJson() => _$UnraidMemoryLayoutToJson(this);
}
