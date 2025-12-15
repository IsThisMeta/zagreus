import 'package:zagreus/api/unraid/json_helpers.dart';

/// Lightweight representation of the Unraid `metrics` response.
class UnraidMetricsInfo {
  final UnraidMetricsMemory memory;
  final UnraidMetricsCpu? cpu;

  UnraidMetricsInfo({
    required this.memory,
    this.cpu,
  });

  factory UnraidMetricsInfo.fromJson(Map<String, dynamic> json) {
    final memoryJson = json['memory'] as Map<String, dynamic>?;
    if (memoryJson == null) {
      throw FormatException('metrics.memory field missing: $json');
    }

    return UnraidMetricsInfo(
      memory: UnraidMetricsMemory.fromJson(memoryJson),
      cpu: json['cpu'] is Map<String, dynamic>
          ? UnraidMetricsCpu.fromJson(json['cpu'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UnraidMetricsMemory {
  /// Total system memory in bytes.
  final int? totalBytes;

  /// Available (free) memory in bytes.
  final int? availableBytes;

  UnraidMetricsMemory({
    this.totalBytes,
    this.availableBytes,
  });

  factory UnraidMetricsMemory.fromJson(Map<String, dynamic> json) {
    return UnraidMetricsMemory(
      totalBytes: parseNullableInt(json['total']),
      availableBytes: parseNullableInt(json['available']),
    );
  }

  /// Returns memory usage as a percentage, or null if unknown.
  double? get percentUsed {
    if (totalBytes == null || totalBytes == 0 || availableBytes == null) {
      return null;
    }
    final used = totalBytes! - availableBytes!;
    if (used <= 0) return 0;
    return (used / totalBytes!) * 100.0;
  }

  double? get totalGB {
    if (totalBytes == null) return null;
    return totalBytes! / 1024 / 1024 / 1024;
  }

  double? get availableGB {
    if (availableBytes == null) return null;
    return availableBytes! / 1024 / 1024 / 1024;
  }

  double? get usedGB {
    if (totalBytes == null || availableBytes == null) return null;
    final used = totalBytes! - availableBytes!;
    return used / 1024 / 1024 / 1024;
  }
}

class UnraidMetricsCpu {
  final double? percentTotal;

  UnraidMetricsCpu({this.percentTotal});

  factory UnraidMetricsCpu.fromJson(Map<String, dynamic> json) {
    final value = json['percentTotal'];
    if (value == null) {
      return UnraidMetricsCpu(percentTotal: null);
    }
    if (value is num) {
      return UnraidMetricsCpu(percentTotal: value.toDouble());
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      return UnraidMetricsCpu(percentTotal: parsed);
    }
    return UnraidMetricsCpu(percentTotal: null);
  }
}
