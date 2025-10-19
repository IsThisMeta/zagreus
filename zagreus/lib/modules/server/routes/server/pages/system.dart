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

      if (!mounted) return;

      setState(() {
        _systemInfo = systemInfo;
        _arrayInfo = arrayInfo;
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
        ],
      ),
    );
  }

  Widget _buildServerInfoCard() {
    final info = _systemInfo!;

    return ZagBlock(
      title: info.name.toUpperCase(),
      body: [
        TextSpan(text: 'Version: ${info.version}\n'),
        TextSpan(text: 'Uptime: ${info.os.formattedUptime}\n'),
        TextSpan(
          text: 'Array: ${_arrayInfo?.state ?? "Unknown"}',
          style: TextStyle(
            color: _arrayInfo?.isStarted == true
                ? Colors.green
                : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildArrayCapacityCard() {
    final capacity = _arrayInfo!.capacity!;
    final percentUsed = capacity.percentUsed ?? 0;

    return ZagBlock(
      title: 'ARRAY CAPACITY',
      body: [
        TextSpan(
          text: '${capacity.totalTB?.toStringAsFixed(1) ?? '?'} TB Total\n',
        ),
        TextSpan(
          text: '${percentUsed.toStringAsFixed(0)}% used '
                '(${capacity.freeTB?.toStringAsFixed(1) ?? '?'} TB free)',
        ),
      ],
      bottomHeight: ZagLinearPercentIndicator.height,
      bottom: ZagLinearPercentIndicator(
        percent: percentUsed / 100,
        progressColor: percentUsed > 90
            ? ZagColours.red
            : percentUsed > 75
                ? ZagColours.orange
                : ZagColours.accent,
      ),
    );
  }

  Widget _buildMemoryCard() {
    final memory = _systemInfo!.memory!;
    final percentUsed = memory.percentUsed ?? 0;
    final totalGB = (memory.total ?? 0) / 1024 / 1024 / 1024;
    final freeGB = (memory.free ?? 0) / 1024 / 1024 / 1024;

    return ZagBlock(
      title: 'MEMORY',
      body: [
        TextSpan(
          text: 'Total Memory: ${totalGB.toStringAsFixed(1)} GB\n',
        ),
        TextSpan(
          text: '${percentUsed.toStringAsFixed(0)}% used '
                '(${freeGB.toStringAsFixed(1)} GB free)',
        ),
      ],
      bottomHeight: ZagLinearPercentIndicator.height,
      bottom: ZagLinearPercentIndicator(
        percent: percentUsed / 100,
        progressColor: percentUsed > 90
            ? ZagColours.red
            : percentUsed > 75
                ? ZagColours.orange
                : ZagColours.accent,
      ),
    );
  }
}
