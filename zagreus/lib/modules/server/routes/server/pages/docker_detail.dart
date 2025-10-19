import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/unraid/models.dart';

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

class _DockerContainerDetailPageState
    extends State<DockerContainerDetailPage> {
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              if (widget.container.isRunning) _buildStopButton(),
              if (!widget.container.isRunning) _buildStartButton(),
              const SizedBox(height: 12),
              if (widget.container.ports?.isNotEmpty == true)
                _buildWebUIButton(),
              const SizedBox(height: 24),
              _buildStatusCard(),
              const SizedBox(height: 24),
              _buildContainerInfoSection(),
              const SizedBox(height: 24),
              if (widget.container.ports?.isNotEmpty == true)
                _buildWebInterfacesSection(),
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
            '/${widget.container.name}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.container.image ?? '',
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
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: ZagColours.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Implement stop container
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.stop_circle, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Stop',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Implement start container
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.play_arrow, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Start',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebUIButton() {
    final port = widget.container.ports?.firstWhere(
      (p) => p.hostPort != null,
      orElse: () => widget.container.ports!.first,
    );

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Open web UI
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.language, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Web UI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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
            widget.container.state.toUpperCase(),
            widget.container.isRunning ? Colors.green : Colors.grey,
          ),
          _buildStatusItem(
            'Uptime',
            widget.container.uptime ?? 'N/A',
            Colors.blue,
          ),
          _buildStatusItem(
            'Web UI',
            widget.container.ports?.isNotEmpty == true ? 'Yes' : 'No',
            widget.container.ports?.isNotEmpty == true
                ? Colors.green
                : Colors.grey,
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
                widget.container.image ?? 'Unknown',
                canCopy: true,
              ),
              const Divider(height: 1, color: Colors.white10),
              _buildInfoRow(
                Icons.info_outline,
                'Status',
                widget.container.displayStatus,
              ),
              const Divider(height: 1, color: Colors.white10),
              _buildInfoRow(
                Icons.label_outline,
                'Container ID',
                widget.container.id.length > 12
                    ? '${widget.container.id.substring(0, 12)}...'
                    : widget.container.id,
                canCopy: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebInterfacesSection() {
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
            children: [
              ...widget.container.ports!.asMap().entries.map((entry) {
                final index = entry.key;
                final port = entry.value;
                final isLast = index == widget.container.ports!.length - 1;

                return Column(
                  children: [
                    _buildPortRow(port),
                    if (!isLast)
                      const Divider(height: 1, color: Colors.white10),
                  ],
                );
              }).toList(),
            ],
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
          Text(
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
}
