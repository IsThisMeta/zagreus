import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/server.dart';
import 'package:zagreus/api/unraid/unraid.dart';
import 'package:zagreus/api/unraid/models.dart';

class ServerSystemPage extends StatefulWidget {
  const ServerSystemPage({Key? key}) : super(key: key);

  @override
  State<ServerSystemPage> createState() => _ServerSystemPageState();
}

class _ServerSystemPageState extends State<ServerSystemPage>
    with ZagScrollControllerMixin {
  UnraidSystemInfo? _systemInfo;
  UnraidArrayInfo? _arrayInfo;
  UnraidUpsInfo? _upsInfo;
  bool _loading = true;
  String? _error;

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

      // Fetch data
      final systemInfo = await api.getSystemInfo();
      final arrayInfo = await api.getArrayInfo();

      // Try to fetch UPS info (optional - may not exist)
      UnraidUpsInfo? upsInfo;
      try {
        upsInfo = await api.getUpsInfo();
      } catch (e) {
        ZagLogger().debug('UPS info not available: $e');
        upsInfo = null;
      }

      if (!mounted) return;

      setState(() {
        _systemInfo = systemInfo;
        _arrayInfo = arrayInfo;
        _upsInfo = upsInfo;
        _loading = false;
      });
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to load server data', e, stackTrace);
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
          text: 'Error loading server data',
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
          if (_systemInfo != null) _buildServerInfoCard(),
          if (_arrayInfo?.capacity != null) _buildArrayCapacityCard(),
          if (_systemInfo?.memory != null) _buildMemoryCard(),
          if (_upsInfo?.hasUps == true) _buildPowerCard(),
        ],
      ),
    );
  }

  Widget _buildServerInfoCard() {
    final info = _systemInfo!;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 32,
                color: Colors.white70,
              ),
              const SizedBox(width: 12),
              Text(
                info.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Version
          Text(
            'Version: ${info.version}',
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 8),
          // Registration
          if (info.registrationType != null) ...[
            Row(
              children: [
                Icon(Icons.badge, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(
                  'Registration: ${info.formattedRegistrationType}',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          // Uptime
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                'Uptime: ${info.os.formattedUptime}',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Array status
          Row(
            children: [
              Icon(Icons.dns, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              const Text(
                'Array: ',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              Text(
                _arrayInfo?.state ?? "Unknown",
                style: TextStyle(
                  fontSize: 14,
                  color: _arrayInfo?.isStarted == true ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrayCapacityCard() {
    final capacity = _arrayInfo!.capacity!;
    final percentUsed = capacity.percentUsed ?? 0;

    // Helper to format storage size (TB or GB)
    String formatStorage(double? tb) {
      if (tb == null) return '?';
      if (tb < 1.0) {
        final gb = tb * 1024;
        return '${gb.toStringAsFixed(1)} GB';
      }
      return '${tb.toStringAsFixed(1)} TB';
    }

    return ZagBlock(
      title: 'ARRAY CAPACITY',
      leading: const Icon(
        Icons.storage,
        size: 32,
        color: Colors.white70,
      ),
      body: [
        TextSpan(
          text: '${formatStorage(capacity.totalTB)} Total',
        ),
      ],
      bottomHeight: ZagLinearPercentIndicator.height + 12,
      bottom: Stack(
        alignment: Alignment.center,
        children: [
          ZagLinearPercentIndicator(
            percent: percentUsed / 100,
            progressColor: percentUsed > 90
                ? ZagColours.red
                : percentUsed > 75
                    ? ZagColours.orange
                    : ZagColours.orange,
          ),
          Text(
            '${percentUsed.toStringAsFixed(0)}% used (${formatStorage(capacity.freeTB)} free)',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard() {
    final memory = _systemInfo!.memory!;
    final percentUsed = memory.percentUsed ?? 0;
    final totalGB = memory.totalGB ?? 0;
    final freeGB = memory.freeGB ?? 0;
    final memoryTypeSpeed = memory.formattedTypeAndSpeed;

    return ZagBlock(
      title: 'MEMORY',
      leading: const Icon(
        Icons.memory,
        size: 32,
        color: Colors.white70,
      ),
      body: [
        TextSpan(
          text: 'Total Memory: ${totalGB.toStringAsFixed(1)} GB',
        ),
        if (memoryTypeSpeed.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: memoryTypeSpeed),
        ],
      ],
      bottomHeight: ZagLinearPercentIndicator.height + 12,
      bottom: Stack(
        alignment: Alignment.center,
        children: [
          ZagLinearPercentIndicator(
            percent: percentUsed / 100,
            progressColor: percentUsed > 90
                ? ZagColours.red
                : percentUsed > 75
                    ? ZagColours.orange
                    : Colors.green,
          ),
          Text(
            '${percentUsed.toStringAsFixed(0)}% used (${freeGB.toStringAsFixed(1)} GB free)',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerCard() {
    final ups = _upsInfo!;

    return ZagBlock(
      title: 'POWER',
      leading: const Icon(
        Icons.power,
        size: 32,
        color: Colors.white70,
      ),
      body: [
        TextSpan(text: 'UPS Model: ${ups.displayName}'),
        const TextSpan(text: '\n\n'),
        const TextSpan(text: 'Status: '),
        TextSpan(
          text: ups.status ?? 'Unknown',
          style: TextStyle(
            color: ups.isOnline ? Colors.green : Colors.orange,
          ),
        ),
        if (ups.power?.loadPercentage != null) ...[
          const TextSpan(text: '\n'),
          TextSpan(text: 'UPS load: ${ups.power!.loadPercentage}%'),
        ],
        if (ups.battery?.chargeLevel != null) ...[
          const TextSpan(text: '\n'),
          TextSpan(text: 'Battery charge: ${ups.battery!.chargeLevel}%'),
        ],
        if (ups.battery?.estimatedRuntime != null) ...[
          const TextSpan(text: '\n'),
          TextSpan(
            text: 'Runtime left: ${ups.battery!.estimatedRuntime} Minutes',
          ),
        ],
      ],
      customBodyMaxLines: 7,
    );
  }
}
