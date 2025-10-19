import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/server.dart';
import 'package:zagreus/api/unraid/unraid.dart';
import 'package:zagreus/api/unraid/models.dart';

class ServerArrayPage extends StatefulWidget {
  const ServerArrayPage({Key? key}) : super(key: key);

  @override
  State<ServerArrayPage> createState() => _ServerArrayPageState();
}

class _ServerArrayPageState extends State<ServerArrayPage>
    with ZagScrollControllerMixin {
  UnraidArrayInfo? _arrayInfo;
  UnraidParityInfo? _parityInfo;
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
      final arrayInfo = await api.getArrayInfo();
      final parityInfo = await api.getParityInfo();

      if (!mounted) return;

      setState(() {
        _arrayInfo = arrayInfo;
        _parityInfo = parityInfo;
        _loading = false;
      });
    } catch (e, stackTrace) {
      ZagLogger().error('Failed to load array data', e, stackTrace);
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
          text: 'Error loading array data',
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
          if (_parityInfo != null) _buildParityCard(),
          if (_arrayInfo != null) _buildArrayCard(),
          if (_arrayInfo?.caches.isNotEmpty == true) _buildCacheCard(),
        ],
      ),
    );
  }

  Widget _buildParityCard() {
    final parity = _parityInfo!;

    return ZagBlock(
      title: 'PARITY',
      body: [
        TextSpan(
          text: parity.isValid ? 'Parity is valid' : 'Parity has errors',
          style: TextStyle(
            color: parity.isValid ? Colors.green : ZagColours.red,
          ),
        ),
        const TextSpan(text: '\n\n'),
        TextSpan(
          text: 'Last ran on ${parity.formattedDate} (${parity.daysAgo}d ago)',
        ),
        const TextSpan(text: '\n'),
        TextSpan(
          text: 'It took ${parity.formattedDuration}',
        ),
        const TextSpan(text: '\n'),
        TextSpan(
          text: 'Average speed was ${parity.speed}',
        ),
        const TextSpan(text: '\n'),
        TextSpan(
          text: 'And found ${parity.errors} errors',
        ),
      ],
      customBodyMaxLines: 8,
    );
  }

  Widget _buildArrayCard() {
    final array = _arrayInfo!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZagBlock(
          title: 'ARRAY',
          body: [
            TextSpan(
              text: '${array.capacity?.usedTB?.toStringAsFixed(1) ?? '?'} TB used of '
                    '${array.capacity?.totalTB?.toStringAsFixed(1) ?? '?'} TB',
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ZagUI.DEFAULT_MARGIN_SIZE,
            vertical: 0,
          ),
          child: Column(
            children: [
              ...array.parities.map((disk) => _buildDiskRow(disk)),
              ...array.disks.map((disk) => _buildDiskRow(disk)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCacheCard() {
    final caches = _arrayInfo!.caches;

    // Calculate total cache usage
    int totalSize = 0;
    int totalUsed = 0;
    for (final cache in caches) {
      totalSize += cache.fsSize ?? 0;
      totalUsed += cache.fsUsed ?? 0;
    }

    final totalSizeTB = totalSize / 1024 / 1024 / 1024 / 1024;
    final totalUsedTB = totalUsed / 1024 / 1024 / 1024 / 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZagBlock(
          title: 'CACHE',
          body: [
            TextSpan(
              text: '${totalUsedTB.toStringAsFixed(1)} TB used of '
                    '${totalSizeTB.toStringAsFixed(1)} TB',
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ZagUI.DEFAULT_MARGIN_SIZE,
            vertical: 0,
          ),
          child: Column(
            children: [
              ...caches.map((disk) => _buildDiskRow(disk)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiskRow(UnraidDisk disk) {
    final percentUsed = disk.percentUsed ?? 0;
    final isHealthy = disk.isHealthy;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHealthy ? Colors.green : ZagColours.red,
            ),
          ),
          const SizedBox(width: 12),

          // Disk name
          SizedBox(
            width: 60,
            child: Text(
              disk.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          const SizedBox(width: 12),

          // Temperature
          SizedBox(
            width: 45,
            child: Text(
              disk.temp != null ? '${disk.temp}°C' : '',
              style: TextStyle(
                fontSize: 14,
                color: _getTempColor(disk),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Progress bar
          Expanded(
            child: ZagLinearPercentIndicator(
              percent: percentUsed / 100,
              progressColor: _getUsageColor(percentUsed),
            ),
          ),

          const SizedBox(width: 12),

          // Percentage
          SizedBox(
            width: 40,
            child: Text(
              '${percentUsed.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTempColor(UnraidDisk disk) {
    if (disk.temp == null) return Colors.grey;

    if (disk.critical != null && disk.temp! >= disk.critical!) {
      return ZagColours.red;
    }
    if (disk.warning != null && disk.temp! >= disk.warning!) {
      return ZagColours.orange;
    }
    return Colors.green;
  }

  Color _getUsageColor(double percentUsed) {
    if (percentUsed > 90) {
      return ZagColours.red;
    } else if (percentUsed > 75) {
      return ZagColours.orange;
    } else {
      return ZagColours.accent;
    }
  }
}
