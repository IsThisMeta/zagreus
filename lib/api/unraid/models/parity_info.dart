import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/unraid/json_helpers.dart';

part 'parity_info.g.dart';

/// Parity check information
@JsonSerializable()
class UnraidParityInfo {
  @JsonKey(name: 'date')
  final String? date; // Last run date

  @JsonKey(name: 'duration', fromJson: parseNullableInt)
  final int? duration; // Duration in seconds

  @JsonKey(name: 'speed')
  final String? speed; // Speed like "164.1 MB/s"

  @JsonKey(name: 'status')
  final String? status; // e.g., "Parity is valid"

  @JsonKey(name: 'errors', fromJson: parseNullableInt)
  final int? errors; // Number of errors found

  @JsonKey(name: 'progress', fromJson: parseNullableDouble)
  final double? progress; // Progress percentage (0-100) for active checks

  @JsonKey(name: 'correcting')
  final bool? correcting; // Is correcting errors

  @JsonKey(name: 'paused')
  final bool? paused; // Is paused

  @JsonKey(name: 'running')
  final bool? running; // Is currently running

  UnraidParityInfo({
    this.date,
    this.duration,
    this.speed,
    this.status,
    this.errors,
    this.progress,
    this.correcting,
    this.paused,
    this.running,
  });

  factory UnraidParityInfo.fromJson(Map<String, dynamic> json) {
    return UnraidParityInfo(
      date: json['date'] as String?,
      duration: parseNullableInt(json['duration']),
      speed: json['speed'] as String?,
      status: json['status'] as String?,
      errors: parseNullableInt(json['errors']),
      progress: parseNullableDouble(json['progress']),
      correcting: json['correcting'] as bool?,
      paused: json['paused'] as bool?,
      running: json['running'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => _$UnraidParityInfoToJson(this);

  /// Format duration as human-readable string
  String get formattedDuration {
    if (duration == null) return '';
    int seconds = duration!;
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

  /// Format average speed as human-readable string
  String get formattedSpeed {
    final raw = speed?.trim();
    if (raw == null || raw.isEmpty) return '';

    // If the string already contains units, return as-is
    if (RegExp(r'[A-Za-z]').hasMatch(raw)) {
      return raw;
    }

    final value = double.tryParse(raw);
    if (value == null) return raw;

    const bytesPerKB = 1024;
    const bytesPerMB = bytesPerKB * 1024;
    const bytesPerGB = bytesPerMB * 1024;

    String format(double number, String unit) {
      final precision = number >= 100 ? 0 : number >= 10 ? 1 : 2;
      return '${number.toStringAsFixed(precision)} $unit';
    }

    if (value >= bytesPerGB) {
      return format(value / bytesPerGB, 'GB/s');
    }
    if (value >= bytesPerMB) {
      return format(value / bytesPerMB, 'MB/s');
    }
    if (value >= bytesPerKB) {
      return format(value / bytesPerKB, 'KB/s');
    }
    return '${value.toStringAsFixed(0)} B/s';
  }

  /// Format date as human-readable string
  String get formattedDate {
    if (date == null || date!.isEmpty) return 'Unknown';

    try {
      // Parse the date string (format: "YYYY-MM-DD HH:MM:SS" or ISO)
      DateTime dateTime = DateTime.parse(date!);

      // Get month name
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];

      // Get day suffix (1st, 2nd, 3rd, 4th, etc.)
      String getDaySuffix(int day) {
        if (day >= 11 && day <= 13) return 'th';
        switch (day % 10) {
          case 1: return 'st';
          case 2: return 'nd';
          case 3: return 'rd';
          default: return 'th';
        }
      }

      String month = months[dateTime.month - 1];
      String day = '${dateTime.day}${getDaySuffix(dateTime.day)}';
      String year = '${dateTime.year}';

      return '$month $day, $year';
    } catch (e) {
      return date ?? 'Unknown';
    }
  }

  /// Get days since parity check
  int get daysAgo {
    if (date == null || date!.isEmpty) return -1;

    try {
      DateTime dateTime = DateTime.parse(date!);
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);
      return difference.inDays;
    } catch (e) {
      return -1;
    }
  }

  /// Is parity check valid (no errors)
  bool get isValid => errors == null || errors == 0;
}
