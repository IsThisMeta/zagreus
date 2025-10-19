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

  /// Is parity check valid (no errors)
  bool get isValid => errors == null || errors == 0;
}
