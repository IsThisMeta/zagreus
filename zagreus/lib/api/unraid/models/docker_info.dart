import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/unraid/json_helpers.dart';

part 'docker_info.g.dart';

/// Docker container list response
@JsonSerializable()
class UnraidDockerInfo {
  @JsonKey(name: 'containers')
  final List<UnraidDockerContainer> containers;

  UnraidDockerInfo({
    required this.containers,
  });

  factory UnraidDockerInfo.fromJson(Map<String, dynamic> json) =>
      _$UnraidDockerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UnraidDockerInfoToJson(this);

  /// Get count of running containers
  int get runningCount => containers.where((c) => c.state == 'running').length;

  /// Get total container count
  int get totalCount => containers.length;
}

/// Individual Docker container
@JsonSerializable()
class UnraidDockerContainer {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'image')
  final String? image;

  @JsonKey(name: 'state')
  final String state; // "running", "stopped", "paused", etc.

  @JsonKey(name: 'status')
  final String? status; // "Up 2 days", "Up 3 days (unhealthy)", etc.

  @JsonKey(name: 'health')
  final String? health; // "healthy", "unhealthy", "starting", null

  @JsonKey(name: 'autostart')
  final bool? autostart;

  @JsonKey(name: 'icon')
  final String? icon; // URL to container icon

  @JsonKey(name: 'version')
  final String? version;

  @JsonKey(name: 'updated')
  final String? updated; // Date string like "August 6th, 2025"

  @JsonKey(name: 'ports')
  final List<UnraidDockerPort>? ports;

  @JsonKey(name: 'networks')
  final List<String>? networks;

  @JsonKey(name: 'volumes')
  final List<UnraidDockerVolume>? volumes;

  UnraidDockerContainer({
    required this.id,
    required this.name,
    this.image,
    required this.state,
    this.status,
    this.health,
    this.autostart,
    this.icon,
    this.version,
    this.updated,
    this.ports,
    this.networks,
    this.volumes,
  });

  factory UnraidDockerContainer.fromJson(Map<String, dynamic> json) =>
      _$UnraidDockerContainerFromJson(json);

  Map<String, dynamic> toJson() => _$UnraidDockerContainerToJson(this);

  /// Check if container is running
  bool get isRunning => state.toLowerCase() == 'running';

  /// Check if container is stopped
  bool get isStopped => state.toLowerCase() == 'stopped';

  /// Check if container is paused
  bool get isPaused => state.toLowerCase() == 'paused';

  /// Check if container is healthy
  bool get isHealthy => health == 'healthy';

  /// Check if container is unhealthy
  bool get isUnhealthy => health == 'unhealthy';

  /// Check if health check is starting
  bool get isStarting => health == 'starting';

  /// Get display status (combines state and health)
  String get displayStatus {
    if (status != null && status!.isNotEmpty) {
      return status!;
    }
    return state;
  }

  /// Get uptime from status string (e.g. "Up 2 days" -> "2 days")
  String? get uptime {
    if (status == null) return null;
    final match = RegExp(r'Up (.+?)(?:\s*\(|$)').firstMatch(status!);
    return match?.group(1);
  }

  /// Check if auto start is enabled
  bool get hasAutoStart => autostart == true;
}

/// Docker container port mapping
@JsonSerializable()
class UnraidDockerPort {
  @JsonKey(name: 'container', fromJson: parseRequiredInt)
  final int containerPort;

  @JsonKey(name: 'host', fromJson: parseNullableInt)
  final int? hostPort;

  @JsonKey(name: 'protocol')
  final String? protocol; // "tcp" or "udp"

  UnraidDockerPort({
    required this.containerPort,
    this.hostPort,
    this.protocol,
  });

  factory UnraidDockerPort.fromJson(Map<String, dynamic> json) {
    return UnraidDockerPort(
      containerPort: parseRequiredInt(json['container']),
      hostPort: parseNullableInt(json['host']),
      protocol: json['protocol'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$UnraidDockerPortToJson(this);

  /// Format port mapping as string (e.g. "8080:80/tcp")
  String get formatted {
    final proto = protocol != null ? '/$protocol' : '';
    if (hostPort != null) {
      return '$hostPort:$containerPort$proto';
    }
    return '$containerPort$proto';
  }
}

/// Docker container volume mapping
@JsonSerializable()
class UnraidDockerVolume {
  @JsonKey(name: 'container')
  final String containerPath;

  @JsonKey(name: 'host')
  final String? hostPath;

  @JsonKey(name: 'mode')
  final String? mode; // "rw" or "ro"

  UnraidDockerVolume({
    required this.containerPath,
    this.hostPath,
    this.mode,
  });

  factory UnraidDockerVolume.fromJson(Map<String, dynamic> json) =>
      _$UnraidDockerVolumeFromJson(json);

  Map<String, dynamic> toJson() => _$UnraidDockerVolumeToJson(this);

  /// Check if volume is read-only
  bool get isReadOnly => mode == 'ro';

  /// Format volume mapping as string (e.g. "/host/path:/container/path:rw")
  String get formatted {
    final modeStr = mode != null ? ':$mode' : '';
    if (hostPath != null) {
      return '$hostPath:$containerPath$modeStr';
    }
    return containerPath;
  }
}
