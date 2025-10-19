import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/api/unraid/models.dart';
import 'package:zagreus/api/unraid/unraid.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/server/core/state.dart';

class DockerContainerDetailPage extends StatefulWidget {
  final UnraidDockerContainer container;

  const DockerContainerDetailPage({
    super.key,
    required this.container,
  });

  @override
  State<DockerContainerDetailPage> createState() =>
      _DockerContainerDetailPageState();
}

class _DockerContainerDetailPageState extends State<DockerContainerDetailPage>
    with ZagScrollControllerMixin {
  bool _isStarting = false;
  bool _isStopping = false;

  bool get _isProcessing => _isStarting || _isStopping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Docker'),
      ),
      body: ZagListView(
        controller: scrollController,
        children: [
          _buildHeaderCard(),
          _buildActionButtons(),
          _buildInfoCard(),
          if (widget.container.ports?.isNotEmpty == true) _buildPortsCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return ZagBlock(
      title: widget.container.name,
      leading: _buildIcon(),
      body: [
        TextSpan(
          children: [
            TextSpan(text: widget.container.image ?? 'Unknown image'),
            const TextSpan(text: '\n'),
            TextSpan(
              text: widget.container.displayStatus,
              style: TextStyle(
                color: _getStateColor(),
              ),
            ),
          ],
        ),
      ],
      customBodyMaxLines: 2,
    );
  }

  Widget? _buildIcon() {
    if (widget.container.icon == null || widget.container.icon!.isEmpty) {
      return null;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        widget.container.icon!,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ZagColours.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ZagUI.DEFAULT_MARGIN_SIZE,
        vertical: 8,
      ),
      child: Row(
        children: [
          // Start/Stop button
          Expanded(
            child: _isProcessing
                ? Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  )
                : Material(
                    color: widget.container.isRunning
                        ? ZagColours.red
                        : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _handleToggleContainer,
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.container.isRunning
                                  ? Icons.stop
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.container.isRunning ? 'Stop' : 'Start',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          // Web UI button
          if (widget.container.webUi != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Material(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => widget.container.webUi?.openLink(),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.language, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Web UI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ZagUI.DEFAULT_MARGIN_SIZE,
            vertical: 8,
          ),
          child: Text(
            'CONTAINER INFORMATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ZagBlock(
          body: [
            TextSpan(
              children: [
                TextSpan(
                    text: 'State: ${widget.container.state.toUpperCase()}'),
                const TextSpan(text: '\n'),
                TextSpan(text: 'Uptime: ${widget.container.uptime ?? "Unknown"}'),
                const TextSpan(text: '\n'),
                TextSpan(
                  text:
                      'Auto Start: ${widget.container.hasAutoStart ? "Enabled" : "Disabled"}',
                ),
                if (widget.container.version != null) ...[
                  const TextSpan(text: '\n'),
                  TextSpan(text: 'Version: ${widget.container.version}'),
                ],
              ],
            ),
          ],
          customBodyMaxLines: 5,
          trailing: IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.container.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Container ID copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPortsCard() {
    final ports = widget.container.ports!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ZagUI.DEFAULT_MARGIN_SIZE,
            vertical: 8,
          ),
          child: Text(
            'WEB INTERFACES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...ports.map((port) => _buildPortRow(port)),
      ],
    );
  }

  Widget _buildPortRow(UnraidDockerPort port) {
    final hostPort = port.hostPort ?? port.containerPort;
    final protocol = port.protocol?.toUpperCase() ?? 'TCP';

    return ZagBlock(
      body: [
        TextSpan(
          children: [
            TextSpan(text: 'Port $hostPort'),
            const TextSpan(text: '\n'),
            TextSpan(text: 'Container: ${port.containerPort} • $protocol'),
          ],
        ),
      ],
      trailing: Text(
        'Available',
        style: TextStyle(
          fontSize: 13,
          color: Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
      customBodyMaxLines: 2,
    );
  }

  Color _getStateColor() {
    if (widget.container.isRunning) return Colors.green;
    if (widget.container.isUnhealthy) return ZagColours.orange;
    if (widget.container.isStopped) return Colors.grey;
    return Colors.white;
  }

  Future<void> _handleToggleContainer() async {
    if (_isProcessing) return;

    final isRunning = widget.container.isRunning;
    setState(() {
      if (isRunning) {
        _isStopping = true;
      } else {
        _isStarting = true;
      }
    });

    final serverState = context.read<ServerState>();
    if (!serverState.isConfigured) {
      if (mounted) {
        setState(() {
          _isStarting = false;
          _isStopping = false;
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

    final actionLabel = isRunning ? 'stop' : 'start';

    try {
      if (isRunning) {
        await api.stopDockerContainer(widget.container.id);
      } else {
        await api.startDockerContainer(widget.container.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Sent $actionLabel command to ${widget.container.name}.'),
        ),
      );

      // Return true to indicate refresh is needed
      Navigator.of(context).pop(true);
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
        _isStarting = false;
        _isStopping = false;
      });
    }
  }
}
