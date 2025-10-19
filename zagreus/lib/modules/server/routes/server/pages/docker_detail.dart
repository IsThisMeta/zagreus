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

class _DockerContainerDetailPageState extends State<DockerContainerDetailPage> {
  late final UnraidDockerContainer _container;
  _DockerAction _pendingAction = _DockerAction.none;

  bool get _isProcessing => _pendingAction != _DockerAction.none;

  @override
  void initState() {
    super.initState();
    _container = widget.container;
  }

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(context),
            const SizedBox(height: 20),
            _buildActionRow(context),
            const SizedBox(height: 18),
            _buildQuickStats(context),
            const SizedBox(height: 24),
            _buildInfoCard(context),
            if (_container.ports?.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              _buildPortsCard(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final accent = ZagColours.accentColor(context);
    final gradient = LinearGradient(
      colors: [
        accent.withValues(alpha: 0.32),
        accent.withValues(alpha: 0.12),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconHero(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _container.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _container.image ?? 'Unraid Container',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildChip(
                          label: _container.state.toUpperCase(),
                          color: _stateColor(context),
                          icon: Icons.circle,
                        ),
                        if (_container.hasAutoStart)
                          _buildChip(
                            label: 'AUTOSTART',
                            color: Colors.lightBlueAccent,
                            icon: Icons.flash_on,
                          ),
                        if (_container.version?.isNotEmpty == true)
                          _buildChip(
                            label: 'v ${_container.version}',
                            color: accent,
                            icon: Icons.tag,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _truncateId(_container.id),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconHero() {
    if (_container.icon?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          _container.icon!,
          height: 64,
          width: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) => _buildFallbackIcon(),
        ),
      );
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: Icon(
        Icons.dns_rounded,
        color: Colors.white.withValues(alpha: 0.7),
        size: 32,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    final webUi = _container.webUi;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final stackVertical = width < 520 || webUi == null;

        final primaryAction = _ActionButton(
          color: _container.isRunning ? ZagColours.red : Colors.green,
          icon: _container.isRunning ? Icons.stop : Icons.play_arrow,
          label: _container.isRunning ? 'Stop Container' : 'Start Container',
          busy: _isProcessing,
          onTap: () => _handleContainerAction(
            _container.isRunning ? _DockerAction.stop : _DockerAction.start,
          ),
        );

        final webAction = webUi != null
            ? _ActionButton.secondary(
                icon: Icons.language,
                label: 'Open Web UI',
                onTap: () => webUi.openLink(),
              )
            : null;

        if (stackVertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primaryAction,
              if (webAction != null) ...[
                const SizedBox(height: 12),
                webAction,
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: primaryAction),
            const SizedBox(width: 12),
            Expanded(child: webAction!),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final tiles = [
      _QuickStatTile(
        label: 'Status',
        value: _container.displayStatus,
        valueColor: _stateColor(context),
        icon: Icons.dns,
      ),
      _QuickStatTile(
        label: 'Uptime',
        value: _container.uptime ?? 'Unknown',
        valueColor: Colors.lightBlueAccent,
        icon: Icons.access_time_rounded,
      ),
      _QuickStatTile(
        label: 'Web UI',
        value: _container.hasWebUi ? 'Available' : 'Unavailable',
        valueColor: _container.hasWebUi ? Colors.greenAccent : Colors.grey,
        icon: Icons.public,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 680
            ? 3
            : width >= 460
                ? 2
                : 1;
        final spacing = 12.0;
        final tileWidth =
            columns == 1 ? width : (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: tiles
              .map((tile) => SizedBox(width: tileWidth, child: tile))
              .toList(),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return _DetailCard(
      title: 'Container Details',
      children: [
        _buildInfoRow(
          icon: Icons.inventory_2_outlined,
          label: 'Image',
          value: _container.image ?? 'Unknown',
          copyValue: _container.image,
        ),
        _buildDivider(),
        _buildInfoRow(
          icon: Icons.info_outline,
          label: 'Status',
          value: _container.displayStatus,
        ),
        _buildDivider(),
        _buildInfoRow(
          icon: Icons.tag_outlined,
          label: 'Version',
          value: _container.version ?? 'Unknown',
        ),
        _buildDivider(),
        _buildInfoRow(
          icon: Icons.code_outlined,
          label: 'Container ID',
          value: _container.id,
          copyValue: _container.id,
        ),
      ],
    );
  }

  Widget _buildPortsCard(BuildContext context) {
    final ports = _container.ports!;
    return _DetailCard(
      title: 'Exposed Ports',
      children: [
        for (int index = 0; index < ports.length; index++) ...[
          _buildPortRow(ports[index]),
          if (index != ports.length - 1) _buildDivider(),
        ],
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    String? copyValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.75), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          if (copyValue?.isNotEmpty == true)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              color: Colors.white.withValues(alpha: 0.6),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: copyValue!));
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
    final host = port.hostPort ?? port.containerPort;
    final protocol = port.protocol?.toUpperCase() ?? 'TCP';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.public, color: Colors.blueAccent.shade100, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Host $host',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        protocol,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.6,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Container ${port.containerPort}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Divider _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }

  Color _stateColor(BuildContext context) {
    if (_container.isRunning) return Colors.greenAccent;
    if (_container.isUnhealthy) return Colors.orangeAccent;
    if (_container.isStopped) return Colors.redAccent;
    return Colors.white.withValues(alpha: 0.75);
  }

  String _truncateId(String id) {
    if (id.length <= 36) return id;
    return '${id.substring(0, 36)}…';
  }

  Future<void> _handleContainerAction(_DockerAction action) async {
    if (_isProcessing) return;

    setState(() {
      _pendingAction = action;
    });

    final serverState = context.read<ServerState>();
    if (!serverState.isConfigured) {
      if (mounted) {
        setState(() => _pendingAction = _DockerAction.none);
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

class _ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final bool busy;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
  }) : outlined = false;

  const _ActionButton.secondary({
    required this.icon,
    required this.label,
    required this.onTap,
  })  : color = Colors.transparent,
        busy = false,
        outlined = true;

  @override
  Widget build(BuildContext context) {
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: shape,
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
        ),
      );
    }

    return ElevatedButton(
      onPressed: busy ? null : onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: shape,
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

class _QuickStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color valueColor;

  const _QuickStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: valueColor),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.7,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

enum _DockerAction { none, start, stop }
