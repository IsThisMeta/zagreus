import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/server.dart';
import 'package:zagreus/api/unraid/unraid.dart';
import 'package:zagreus/api/unraid/models.dart';
import 'package:zagreus/modules/server/routes/server/pages/docker_detail.dart';

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
  final Map<String, bool> _processingContainers = {};

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
      return Column(
        children: [
          _buildContainerCard(container, isExpanded),
          if (isExpanded) _buildExpandedContent(container),
        ],
      );
    }).toList();
  }

  Widget _buildContainerCard(UnraidDockerContainer container, bool isExpanded) {
    return ZagBlock(
      title: container.name,
      leading: _buildContainerIcon(container),
      body: _buildContainerBody(container),
      trailing: _buildContainerTrailing(container),
      onTap: () {
        setState(() {
          _expandedContainerId = isExpanded ? null : container.id;
        });
      },
    );
  }

  List<TextSpan> _buildContainerBody(UnraidDockerContainer container) {
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

    return spans;
  }

  Widget? _buildContainerIcon(UnraidDockerContainer container) {
    if (container.icon == null || container.icon!.isEmpty) {
      return null;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        container.icon!,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ZagColours.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.apps,
              size: 18,
              color: ZagColours.accent,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContainerTrailing(UnraidDockerContainer container) {
    List<Widget> indicators = [];

    // Auto start indicator - "A" that's lit or unlit
    if (container.autostart != null) {
      indicators.add(Text(
        'A',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: container.hasAutoStart ? Colors.green : Colors.grey.shade700,
        ),
      ));
      indicators.add(const SizedBox(width: 12));
    }

    // Running status - checkmark or cancel
    indicators.add(Icon(
      container.isRunning ? Icons.check_circle : Icons.cancel,
      color: container.isRunning ? ZagColours.accent : ZagColours.red,
      size: 20,
    ));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: indicators,
    );
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

  Widget _buildExpandedContent(UnraidDockerContainer container) {
    final isProcessing = _processingContainers[container.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(
        left: ZagUI.DEFAULT_MARGIN_SIZE,
        right: ZagUI.DEFAULT_MARGIN_SIZE,
        bottom: ZagUI.DEFAULT_MARGIN_SIZE,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZagColours.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Auto start status
          if (container.autostart != null)
            Row(
              children: [
                Icon(
                  container.hasAutoStart ? Icons.check_circle : Icons.block,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Text(
                  container.hasAutoStart
                      ? 'Auto Start Enabled'
                      : 'Auto Start Disabled',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          // Version info
          if (container.version != null || container.updated != null) ...[
            if (container.autostart != null) const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(
                  [
                    if (container.version != null) 'v${container.version}',
                    if (container.updated != null) container.updated!,
                  ].join(' • '),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Action button
          Material(
            color: container.isRunning ? ZagColours.red : Colors.green,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isProcessing ? null : () => _handleToggleContainer(container),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                child: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        container.isRunning ? 'Stop Container' : 'Start Container',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggleContainer(UnraidDockerContainer container) async {
    setState(() {
      _processingContainers[container.id] = true;
    });

    final serverState = context.read<ServerState>();
    if (!serverState.isConfigured) {
      if (mounted) {
        setState(() {
          _processingContainers[container.id] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configure your server connection first.'),
          ),
        );
      }
      return;
    }

    final api = UnraidAPI(
      host: serverState.host,
      apiKey: serverState.apiKey,
      headers: serverState.headers,
    );

    final actionLabel = container.isRunning ? 'stop' : 'start';

    try {
      if (container.isRunning) {
        await api.stopDockerContainer(container.id);
      } else {
        await api.startDockerContainer(container.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent $actionLabel command to ${container.name}.'),
        ),
      );

      // Reload data
      await _loadData();

      setState(() {
        _processingContainers[container.id] = false;
      });
    } catch (error, stackTrace) {
      ZagLogger().error(
        'Failed to $actionLabel Docker container',
        error,
        stackTrace,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to $actionLabel container. Please try again.'),
        ),
      );

      setState(() {
        _processingContainers[container.id] = false;
      });
    }
  }
}
