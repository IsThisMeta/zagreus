/// Dart library package to facilitate communication with Unraid's GraphQL API.
library unraid;

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:zagreus/api/unraid/json_helpers.dart';
import 'package:zagreus/api/unraid/models.dart';
import 'package:zagreus/system/logger.dart';

/// The core class to handle all connections to Unraid's GraphQL API.
///
/// [UnraidAPI] handles GraphQL queries using Dio HTTP client with x-api-key authentication.
class UnraidAPI {
  /// Internal constructor
  UnraidAPI._internal({
    required this.httpClient,
  });

  /// Create a new Unraid API connection manager.
  ///
  /// Required Parameters:
  /// - `host`: String that contains the protocol (http:// or https://), the host itself, and the base URL (if applicable)
  /// - `apiKey`: The API key generated from Unraid's Management Access settings
  ///
  /// Optional Parameters:
  /// - `headers`: Map that contains additional headers that should be attached to all requests
  /// - `followRedirects`: If the HTTP client should follow URL redirects
  /// - `maxRedirects`: The maximum amount of redirects the client should follow (does nothing if `followRedirects` is false)
  factory UnraidAPI({
    required String host,
    required String apiKey,
    Map<String, dynamic>? headers,
    bool followRedirects = true,
    int maxRedirects = 5,
  }) {
    // Prepare headers with API key
    Map<String, dynamic> finalHeaders = {
      'x-api-key': apiKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    // Build the HTTP client for GraphQL endpoint
    Dio dio = Dio(
      BaseOptions(
        baseUrl: host.endsWith('/') ? '${host}graphql' : '$host/graphql',
        headers: finalHeaders,
        followRedirects: followRedirects,
        maxRedirects: maxRedirects,
        responseType: ResponseType.json,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
      ),
    );

    return UnraidAPI._internal(
      httpClient: dio,
    );
  }

  /// The [Dio] HTTP client built during initialization.
  final Dio httpClient;

  /// Execute a GraphQL query
  Future<Map<String, dynamic>> _query(String query,
      {Map<String, dynamic>? variables}) async {
    try {
      final requestData = {
        'query': query,
        if (variables != null) 'variables': variables,
      };

      // Debug logging
      ZagLogger().debug('Unraid GraphQL Request:');
      ZagLogger().debug('  URL: ${httpClient.options.baseUrl}');
      ZagLogger().debug('  Headers: ${httpClient.options.headers}');
      ZagLogger()
          .debug('  Query: ${query.replaceAll(RegExp(r'\s+'), ' ').trim()}');
      if (variables != null) {
        ZagLogger().debug('  Variables: $variables');
      }

      final response = await httpClient.post(
        '',
        data: requestData,
      );

      // Debug response
      ZagLogger().debug('Unraid GraphQL Response:');
      ZagLogger().debug('  Status: ${response.statusCode}');
      ZagLogger().debug('  Data: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Check for GraphQL errors
        if (data.containsKey('errors')) {
          ZagLogger().error(
              'GraphQL returned errors', data['errors'], StackTrace.current);
          throw Exception('GraphQL Error: ${data['errors']}');
        }

        return data['data'] as Map<String, dynamic>? ?? {};
      }

      throw Exception('Unexpected response format: ${response.data}');
    } on DioException catch (e) {
      ZagLogger().error('Unraid API request failed', e, StackTrace.current);
      ZagLogger().debug('  URL: ${e.requestOptions.uri}');
      ZagLogger().debug('  Status Code: ${e.response?.statusCode}');
      ZagLogger().debug('  Response Data: ${e.response?.data}');
      ZagLogger().debug('  Response Headers: ${e.response?.headers}');

      // Provide more detailed error message
      String errorMsg = 'Network error: ${e.message}';
      if (e.response != null) {
        errorMsg += ' (Status ${e.response!.statusCode})';
        if (e.response!.data != null) {
          errorMsg += ' - ${e.response!.data}';
        }
      }
      throw Exception(errorMsg);
    }
  }

  /// Fetch system information
  Future<UnraidSystemInfo> getSystemInfo() async {
    const query = '''
      query {
        vars {
          name
          version
        }
        info {
          os {
            uptime
            distro
          }
        }
      }
    ''';

    final data = await _query(query);

    // Combine vars and info into a single response
    final Map<String, dynamic> combinedData = {
      'name': data['vars']?['name'],
      'version': data['vars']?['version'],
      'os': data['info']?['os'],
    };

    return UnraidSystemInfo.fromJson(combinedData);
  }

  /// Fetch array information including all disks
  Future<UnraidArrayInfo> getArrayInfo() async {
    const query = '''
      query {
        array {
          state
          capacity {
            kilobytes {
              total
              used
              free
            }
          }
          disks {
            name
            status
            temp
            critical
            warning
            size
            fsSize
            fsUsed
            fsFree
            numErrors
          }
          caches {
            name
            status
            temp
            critical
            warning
            size
            fsSize
            fsUsed
            fsFree
            numErrors
          }
          parities {
            name
            status
            temp
            critical
            warning
            size
            fsSize
            fsUsed
            fsFree
            numErrors
          }
        }
      }
    ''';

    final data = await _query(query);
    final arrayData = data['array'] as Map<String, dynamic>;

    // Transform capacity.kilobytes to capacity for model compatibility
    if (arrayData['capacity'] != null &&
        arrayData['capacity']['kilobytes'] != null) {
      arrayData['capacity'] = arrayData['capacity']['kilobytes'];
    }

    return UnraidArrayInfo.fromJson(arrayData);
  }

  /// Fetch parity check history/status
  Future<UnraidParityInfo?> getParityInfo() async {
    const query = '''
      query {
        parityHistory {
          date
          duration
          speed
          status
          errors
          progress
          correcting
          paused
          running
        }
      }
    ''';

    final data = await _query(query);

    final historyList = data['parityHistory'] as List?;
    if (historyList == null || historyList.isEmpty) return null;

    // Return the most recent parity check
    return UnraidParityInfo.fromJson(historyList.first as Map<String, dynamic>);
  }

  /// Fetch Docker containers information
  Future<UnraidDockerInfo> getDockerContainers() async {
    const query = '''
      query {
        docker {
          containers {
            id
            state
            status
            autoStart
            labels
            names
            ports {
              ip
              privatePort
              publicPort
              type
            }
          }
        }
      }
    ''';

    final data = await _query(query);
    final dockerData = data['docker'] as Map<String, dynamic>?;
    final containersData = dockerData?['containers'] as List?;

    if (containersData == null) {
      return UnraidDockerInfo(containers: []);
    }

    final containers = <UnraidDockerContainer>[];
    for (final entry in containersData) {
      if (entry is! Map<String, dynamic>) continue;
      final container = _parseDockerContainer(entry);
      if (container != null) {
        containers.add(container);
      }
    }

    return UnraidDockerInfo(containers: containers);
  }

  UnraidDockerContainer? _parseDockerContainer(Map<String, dynamic> json) {
    final rawId = json['id'];
    if (rawId == null) {
      ZagLogger().debug('Skipping Docker container with missing id: $json');
      return null;
    }

    final id = rawId.toString();
    final stateRaw = json['state']?.toString() ?? 'unknown';
    final state = stateRaw.toLowerCase();
    final statusRaw = json['status']?.toString() ?? '';
    final status = _cleanStatus(statusRaw);
    final health = _extractHealth(statusRaw);
    final autoStart =
        json['autoStart'] is bool ? json['autoStart'] as bool : null;

    final names = json['names'];
    final formattedName = _formatContainerName(id, names);

    final labels = _normalizeLabels(json['labels']);
    final icon = _stringOrNull(labels['net.unraid.docker.icon']);
    final image = _stringOrNull(labels['org.opencontainers.image.ref.name']);
    final version = _stringOrNull(labels['org.opencontainers.image.version']);
    final created = _stringOrNull(labels['org.opencontainers.image.created']);
    final updated = _formatReleaseDate(created);

    final ports = _parseDockerPorts(json['ports']);

    return UnraidDockerContainer(
      id: id,
      name: formattedName,
      image: image,
      state: state,
      status: status.isNotEmpty ? status : null,
      health: health,
      autostart: autoStart,
      icon: icon,
      version: version?.isNotEmpty == true ? version : null,
      updated: updated,
      ports: ports,
      networks: null,
      volumes: null,
    );
  }

  Map<String, dynamic> _normalizeLabels(dynamic labels) {
    if (labels is Map<String, dynamic>) {
      return labels;
    }
    if (labels is Map) {
      final result = <String, dynamic>{};
      labels.forEach((key, value) {
        result[key.toString()] = value;
      });
      return result;
    }
    return const {};
  }

  String _formatContainerName(String id, dynamic names) {
    if (names is List && names.isNotEmpty) {
      final raw = names.first?.toString();
      if (raw != null && raw.isNotEmpty) {
        final sanitized = raw.startsWith('/') ? raw.substring(1) : raw;
        if (sanitized.isEmpty) return _fallbackName(id);
        final capitalised = sanitized[0].toUpperCase() +
            (sanitized.length > 1 ? sanitized.substring(1) : '');
        return capitalised;
      }
    }
    return _fallbackName(id);
  }

  String _fallbackName(String id) {
    if (id.length <= 6) return 'Container $id';
    return 'Container ${id.substring(id.length - 6)}';
  }

  String _cleanStatus(String status) {
    var cleaned = status;
    const tokens = [
      'Exited (0)',
      'Exited (255)',
      '(healthy)',
      '(health: starting)',
      '(unhealthy)',
    ];
    for (final token in tokens) {
      cleaned = cleaned.replaceAll(token, '');
    }
    return cleaned.trim();
  }

  String? _extractHealth(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('(healthy)')) return 'healthy';
    if (lower.contains('(unhealthy)')) return 'unhealthy';
    if (lower.contains('(health: starting)')) return 'starting';
    return null;
  }

  String? _formatReleaseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) return null;
      final month = DateFormat('MMMM').format(parsed);
      final day = parsed.day;
      final suffix = _ordinalSuffix(day);
      return '$month $day$suffix, ${parsed.year}';
    } catch (_) {
      return null;
    }
  }

  String _ordinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  List<UnraidDockerPort>? _parseDockerPorts(dynamic ports) {
    if (ports is! List) return null;
    final parsed = <UnraidDockerPort>[];
    for (final entry in ports) {
      if (entry is! Map<String, dynamic>) continue;
      final containerPort = parseNullableInt(entry['privatePort']);
      if (containerPort == null) continue;
      final hostPort = parseNullableInt(entry['publicPort']);
      final protocol = _stringOrNull(entry['type'])?.toLowerCase();
      parsed.add(
        UnraidDockerPort(
          containerPort: containerPort,
          hostPort: hostPort,
          protocol: protocol,
        ),
      );
    }
    if (parsed.isEmpty) return null;
    return parsed;
  }

  String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }
}
