import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/server.dart';
import 'package:zagreus/api/unraid/unraid.dart';
import 'package:zagreus/api/unraid/models.dart';

class ServerArrayPage extends StatefulWidget {
  const ServerArrayPage({super.key});

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

      // Fetch array data (required)
      final arrayInfo = await api.getArrayInfo();

      // Try to fetch parity info (optional - may not exist)
      UnraidParityInfo? parityInfo;
      try {
        parityInfo = await api.getParityInfo();
      } catch (e) {
        // Parity info may not exist if no parity checks have been run
        ZagLogger().debug('Parity info not available: $e');
        parityInfo = null;
      }

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
          if ((_arrayInfo?.caches ?? const []).isNotEmpty) _buildCacheCard(),
        ],
      ),
    );
  }

  Widget _buildParityCard() {
    final parity = _parityInfo!;

    final status = parity.status?.isNotEmpty == true
        ? parity.status!
        : parity.isValid
            ? 'Parity is valid'
            : 'Parity has errors';
    final statusColor = parity.isValid ? Colors.green : ZagColours.red;
    final relativeAge = _formatRelativeAge(parity);
    final relativeAgeColor = _relativeAgeColor(parity.daysAgo);
    final duration = parity.formattedDuration.isNotEmpty
        ? parity.formattedDuration
        : 'Unknown duration';
    final averageSpeed = parity.formattedSpeed.isNotEmpty
        ? parity.formattedSpeed
        : 'Unknown';
    final errorsCount = parity.errors ?? 0;
    final errorsColor = errorsCount == 0 ? Colors.green : ZagColours.red;

    final isRunning = parity.running == true;
    final progress = parity.progress?.clamp(0.0, 100.0);

    return ZagBlock(
      title: 'Parity',
      bodyLeadingIcons: [
        Icons.check_circle_rounded,
        Icons.event_rounded,
        Icons.access_time_rounded,
        Icons.speed_rounded,
        Icons.bug_report_rounded,
      ],
      bodyLeadingIconsColor: Colors.grey.shade500,
      body: [
        TextSpan(
          text: status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextSpan(
          children: [
            TextSpan(
              text: parity.formattedDate,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (relativeAge != null)
              TextSpan(
                text: ' $relativeAge',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: relativeAgeColor,
                ),
              ),
          ],
        ),
        TextSpan(
          text: duration,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        TextSpan(
          text: averageSpeed,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        TextSpan(
          text: '$errorsCount errors',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: errorsColor,
          ),
        ),
      ],
      bottom:
          isRunning && progress != null ? _buildParityProgress(progress) : null,
      bottomHeight:
          isRunning && progress != null ? 74 : ZagBlock.SUBTITLE_HEIGHT,
    );
  }

  String? _formatRelativeAge(UnraidParityInfo parity) {
    final days = parity.daysAgo;
    if (days < 0) return null;
    if (days == 0) return '(today)';
    if (days == 1) return '(yesterday)';
    if (days < 7) return '(${days}d ago)';
    if (days < 30) {
      final weeks = (days / 7).floor();
      return '(${weeks}w ago)';
    }
    if (days < 365) {
      final months = (days / 30).floor();
      return '(${months}mo ago)';
    }
    final years = (days / 365).floor();
    return '(${years}y ago)';
  }

  Color _relativeAgeColor(int days) {
    if (days < 0) return Colors.grey.shade400;
    if (days <= 30) return Colors.green;
    if (days <= 90) return ZagColours.orange;
    return ZagColours.red;
  }

  Widget _buildParityProgress(double progress) {
    final percent = progress / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Parity check running • ${progress.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        ZagLinearPercentIndicator(
          percent: percent.clamp(0.0, 1.0),
          progressColor: ZagColours.accent,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
        ),
      ],
    );
  }

  String _formatStorage(double? tb) {
    if (tb == null) return '?';
    if (tb >= 1.0) {
      final display = tb >= 10 ? tb.toStringAsFixed(0) : tb.toStringAsFixed(1);
      return '$display TB';
    }
    final gb = tb * 1024;
    final display = gb >= 10 ? gb.toStringAsFixed(0) : gb.toStringAsFixed(1);
    return '$display GB';
  }

  Widget _buildArrayCard() {
    final array = _arrayInfo!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZagBlock(
          title: 'Array',
          body: [
            TextSpan(
              text:
                  '${_formatStorage(array.capacity?.usedTB)} used of ${_formatStorage(array.capacity?.totalTB)}',
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
          title: 'Cache',
          body: [
            TextSpan(
              text:
                  '${_formatStorage(totalUsedTB)} used of ${_formatStorage(totalSizeTB)}',
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
    final percentUsed = (disk.percentUsed ?? 0).toDouble();
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
