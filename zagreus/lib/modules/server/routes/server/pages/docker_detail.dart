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
    Key? key,
    required this.container,
  }) : super(key: key);

  @override
  State<DockerContainerDetailPage> createState() =>
      _DockerContainerDetailPageState();
}

class _DockerContainerDetailPageState extends State<DockerContainerDetailPage> {
  late final UnraidDockerContainer _container;
  _DockerAction _pendingAction = _DockerAction.none;

  @override
  void initState() {
    super.initState();
    _container = widget.container;
  }

  bool get _isProcessing => _pendingAction != _DockerAction.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Docker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              if (_container.isRunning) _buildStopButton(),
              if (!_container.isRunning) _buildStartButton(),
              if (_container.hasWebUi) ...[
                const SizedBox(height: 12),
                _buildWebUIButton(),
              ],
              const SizedBox(height: 24),
              _buildStatusCard(),
              const SizedBox(height: 24),
              _buildContainerInfoSection(),
              if (_container.ports?.isNotEmpty == true) ...[
                const SizedBox(height: 24),
                _buildWebInterfacesSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZagColours.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '/${_container.name}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _container.image ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStopButton() {
    final isProcessing = _pendingAction == _DockerAction.stop;
    return _PrimaryActionButton(
      color: ZagColours.red,
      icon: Icons.stop_circle,
      label: 'Stop',
      busy: isProcessing,
      onTap: () => _handleContainerAction(_DockerAction.stop),
    );
  }

  Widget _buildStartButton() {
    final isProcessing = _pendingAction == _DockerAction.start;
    return _PrimaryActionButton(
      color: Colors.green,
      icon: Icons.play_arrow,
      label: 'Start',
      busy: isProcessing,
      onTap: () => _handleContainerAction(_DockerAction.start),
    );
  }

  Widget _buildWebUIButton() {
    final webUi = _container.webUi;
    if (webUi == null) {
      return const SizedBox.shrink();
    }

    return _PrimaryActionButton(
      color: Colors.blue,
      icon: Icons.language,
      label: 'Web UI',
      busy: false,
      onTap: () => webUi.openLink(),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZagColours.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            'State',
            _container.state.toUpperCase(),
            _container.isRunning ? Colors.green : Colors.grey,
          ),
          _buildStatusItem(
            'Uptime',
            _container.uptime ?? 'N/A',
            Colors.blue,
          ),
          _buildStatusItem(
            'Web UI',
            _container.hasWebUi ? 'Yes' : 'No',
            _container.hasWebUi ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildContainerInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTAINER INFORMATION',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: ZagColours.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                Icons.inventory_2,
                'Image',
                _container.image ?? 'Unknown',
                canCopy: true,
              ),
              const Divider(height: 1, color: Colors.white10),
              _buildInfoRow(
                Icons.info_outline,
                'Status',
                _container.displayStatus,
              ),
              const Divider(height: 1, color: Colors.white10),
              _buildInfoRow(
                Icons.label_outline,
                'Container ID',
                _container.id.length > 12
                    ? '${_container.id.substring(0, 12)}...'
                    : _container.id,
                canCopy: true,
              ),
              if (_container.version?.isNotEmpty == true) ...[
                const Divider(height: 1, color: Colors.white10),
                _buildInfoRow(
                  Icons.tag,
                  'Version',
                  _container.version!,
                ),
              ],
              if (_container.updated?.isNotEmpty == true) ...[
                const Divider(height: 1, color: Colors.white10),
                _buildInfoRow(
                  Icons.update,
                  'Updated',
                  _container.updated!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebInterfacesSection() {
    final ports = _container.ports;
    if (ports == null || ports.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WEB INTERFACES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: ZagColours.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: ports.asMap().entries.map((entry) {
              final index = entry.key;
              final port = entry.value;
              final isLast = index == ports.length - 1;
              return Column(
                children: [
                  _buildPortRow(port),
                  if (!isLast) const Divider(height: 1, color: Colors.white10),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          if (canCopy)
            IconButton(
              icon: Icon(Icons.copy, color: Colors.grey.shade400, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPortRow(UnraidDockerPort port) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.language, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Port ${port.hostPort ?? port.containerPort}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'localhost',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleContainerAction(_DockerAction action) async {
    if (_isProcessing) return;

    setState(() {
      _pendingAction = action;
    });

    final serverState = context.read<ServerState>();
    if (!serverState.isConfigured) {
      if (mounted) {
        setState(() {
          _pendingAction = _DockerAction.none;
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

    final actionLabel = action == _DockerAction.start ? 'start' : 'stop';

    try {
      if (action == _DockerAction.start) {
        await api.startDockerContainer(_container.id);
      } else {
        await api.stopDockerContainer(_container.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent $actionLabel command to ${_container.name}.'),
        ),
      );

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
        _pendingAction = _DockerAction.none;
      });
    }
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final bool busy;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    Key? key,
    required this.color,
    required this.icon,
    required this.label,
    required this.busy,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: busy ? null : onTap,
          child: Center(
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

enum _DockerAction { none, start, stop }
