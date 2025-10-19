import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/server.dart';
import 'package:zagreus/api/unraid/unraid.dart';
import 'package:zagreus/api/unraid/models.dart';

class ServerDockerPage extends StatefulWidget {
  const ServerDockerPage({Key? key}) : super(key: key);

  @override
  State<ServerDockerPage> createState() => _ServerDockerPageState();
}

class _ServerDockerPageState extends State<ServerDockerPage>
    with ZagScrollControllerMixin {
  UnraidDockerInfo? _dockerInfo;
  bool _loading = true;
  String? _error;
  String? _expandedContainerId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final serverState = context.read<ServerState>();

      // Create API client
      final api = UnraidAPI(
        host: serverState.host,
        apiKey: serverState.apiKey,
        headers: serverState.headers,
      );

      // Fetch Docker containers
      final dockerInfo = await api.getDockerContainers();

      if (!mounted) return;

      setState(() {
        _dockerInfo = dockerInfo;
        _loading = false;
      });
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to load Docker containers', e, stackTrace);
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: ZagMessage(
          text: 'Error loading Docker containers',
          buttonText: 'Retry',
          onTap: _loadData,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ZagListView(
        controller: scrollController,
        children: [
          if (_dockerInfo != null) _buildHeaderCard(),
          if (_dockerInfo != null) ..._buildContainerList(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final info = _dockerInfo!;
    final running = info.runningCount;
    final total = info.totalCount;

    return ZagBlock(
      title: 'DOCKER CONTAINERS',
      body: [
        TextSpan(
          text: '$running of $total containers running',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  List<Widget> _buildContainerList() {
    final containers = _dockerInfo!.containers;

    if (containers.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No containers found'),
          ),
        ),
      ];
    }

    return containers.map((container) {
      final isExpanded = _expandedContainerId == container.id;
      return _buildContainerCard(container, isExpanded);
    }).toList();
  }

  Widget _buildContainerCard(UnraidDockerContainer container, bool isExpanded) {
    return ZagBlock(
      title: container.name,
      leading: _buildContainerIcon(container),
      body: _buildContainerBody(container, isExpanded),
      trailing: _buildContainerTrailing(container),
      onTap: () {
        setState(() {
          _expandedContainerId = isExpanded ? null : container.id;
        });
      },
    );
  }

  List<TextSpan> _buildContainerBody(
      UnraidDockerContainer container, bool isExpanded) {
    List<TextSpan> spans = [];

    // Status line
    String statusText = container.displayStatus;
    if (container.isUnhealthy) {
      statusText = '${container.uptime ?? container.state} (unhealthy)';
    }

    spans.add(TextSpan(
      text: statusText,
      style: TextStyle(
        color: _getContainerStateColor(container),
      ),
    ));

    // Show expanded details
    if (isExpanded) {
      spans.add(const TextSpan(text: '\n\n'));

      // Auto start status
      if (container.autostart != null) {
        spans.add(TextSpan(
          text: container.hasAutoStart
              ? 'Auto Start Enabled'
              : 'Auto Start Disabled',
          style: TextStyle(
            color: container.hasAutoStart ? Colors.green : Colors.grey,
          ),
        ));
        spans.add(const TextSpan(text: '\n'));
      }

      // Version info
      if (container.version != null || container.updated != null) {
        String versionText = '';
        if (container.version != null) {
          versionText = container.version!;
        }
        if (container.updated != null) {
          if (versionText.isNotEmpty) versionText += ' • ';
          versionText += container.updated!;
        }
        if (versionText.isNotEmpty) {
          spans.add(TextSpan(
            text: versionText,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ));
        }
      }
    }

    return spans;
  }

  Widget? _buildContainerIcon(UnraidDockerContainer container) {
    if (container.icon == null || container.icon!.isEmpty) {
      return null;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        container.icon!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to default icon on error
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ZagColours.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.apps,
              size: 24,
              color: ZagColours.accent,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContainerTrailing(UnraidDockerContainer container) {
    // Health indicator icon
    IconData icon;
    Color color;

    if (container.isHealthy) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (container.isUnhealthy) {
      icon = Icons.warning;
      color = ZagColours.orange;
    } else if (container.isStarting) {
      icon = Icons.hourglass_empty;
      color = Colors.grey;
    } else if (container.isStopped) {
      icon = Icons.stop_circle;
      color = Colors.grey;
    } else if (container.isRunning) {
      icon = Icons.check_circle_outline;
      color = ZagColours.accent;
    } else {
      icon = Icons.help_outline;
      color = Colors.grey;
    }

    return Icon(icon, color: color, size: 20);
  }

  Color _getContainerStateColor(UnraidDockerContainer container) {
    if (container.isRunning) {
      if (container.isUnhealthy) {
        return ZagColours.orange;
      }
      return Colors.green;
    } else if (container.isStopped) {
      return Colors.grey;
    } else if (container.isPaused) {
      return ZagColours.orange;
    }
    return Colors.white;
  }
}
