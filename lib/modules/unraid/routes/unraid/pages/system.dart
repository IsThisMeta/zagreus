import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/unraid.dart';
import 'package:zagreus/modules/sabnzbd/core/api/api.dart';
import 'package:zagreus/api/unraid/unraid.dart';
import 'package:zagreus/api/unraid/models.dart';
import 'package:zagreus/modules/unraid/core/download_history_fetcher.dart';
import 'package:zagreus/modules/unraid/routes/unraid/widgets/download_history_card.dart';

class UnraidSystemPage extends StatefulWidget {
  const UnraidSystemPage({Key? key}) : super(key: key);

  @override
  State<UnraidSystemPage> createState() => _UnraidSystemPageState();
}

class _UnraidSystemPageState extends State<UnraidSystemPage>
    with ZagScrollControllerMixin {
  UnraidSystemInfo? _systemInfo;
  UnraidArrayInfo? _arrayInfo;
  UnraidMetricsInfo? _metricsInfo;
  UnraidUpsInfo? _upsInfo;
  DownloadHistoryData? _downloadHistory;
  bool _loading = true;
  String? _error;
  int _downloadHistoryWeeks = 1;

  @override
  void initState() {
    super.initState();
    print('🔍 UnraidSystemPage initialized - download history feature loaded!');
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
      _metricsInfo = null;
      _downloadHistory = null;
    });

    try {
      final serverState = context.read<UnraidState>();

      // Create API client
      final api = UnraidAPI(
        host: serverState.host,
        apiKey: serverState.apiKey,
        headers: serverState.headers,
      );

      // Fetch data
      final systemInfo = await api.getSystemInfo();
      final arrayInfo = await api.getArrayInfo();

      UnraidMetricsInfo? metricsInfo;
      try {
        metricsInfo = await api.getMetricsInfo();
      } catch (e) {
        ZagLogger().debug('Metrics info not available: $e');
        metricsInfo = null;
      }

      // Try to fetch UPS info (optional - may not exist)
      UnraidUpsInfo? upsInfo;
      try {
        upsInfo = await api.getUpsInfo();
      } catch (e) {
        ZagLogger().debug('UPS info not available: $e');
        upsInfo = null;
      }

      // Fetch download history from SABnzbd if enabled
      DownloadHistoryData? downloadHistory;
      try {
        final profile = ZagProfile.current;
        ZagLogger().debug('SABnzbd enabled: ${profile.sabnzbdEnabled}');
        if (profile.sabnzbdEnabled) {
          ZagLogger().debug('Fetching download history...');
          final sabnzbdApi = SABnzbdAPI.from(profile);
          downloadHistory = await DownloadHistoryFetcher.fetchSabnzbdDownloadStats(
            api: sabnzbdApi,
            weeksLookBack: _downloadHistoryWeeks,
          );
          ZagLogger().debug('Download history fetched: ${downloadHistory.chartData.length} days, ${downloadHistory.totalGB} GB');
        }
      } catch (e, stackTrace) {
        ZagLogger().error('Download history error', e, stackTrace);
        downloadHistory = null;
      }

      if (!mounted) return;

      setState(() {
        _systemInfo = systemInfo;
        _arrayInfo = arrayInfo;
        _metricsInfo = metricsInfo;
        _upsInfo = upsInfo;
        _downloadHistory = downloadHistory;
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

  Color _sectionIconColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.light ? Colors.black54 : Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: ZagMessage(
          text: 'unraid.ErrorLoadingServerData'.tr(),
          buttonText: 'zagreus.Retry'.tr(),
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
          if (_downloadHistory != null)
            DownloadHistoryCard(
              chartData: _downloadHistory!.chartData,
              totalGB: _downloadHistory!.totalGB,
              periodLabel: _downloadHistoryPeriodLabel(
                context,
                _downloadHistoryWeeks,
              ),
            ),
          if (_arrayInfo?.capacity != null) _buildArrayCapacityCard(),
          if (_systemInfo?.memory != null || _metricsInfo != null)
            _buildMemoryCard(),
          if (_upsInfo?.hasUps == true) _buildPowerCard(),
        ],
      ),
    );
  }

  Widget _buildServerInfoCard() {
    final info = _systemInfo!;
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;

    final titleStyle = (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: theme.textTheme.titleMedium?.color ??
          (isLightTheme ? Colors.black87 : Colors.white),
    );

    final bodyStyle = (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontSize: 14,
      color: theme.textTheme.bodyMedium?.color ??
          (isLightTheme ? Colors.black87 : Colors.white),
    );

    final iconColor =
        theme.iconTheme.color?.withOpacity(isLightTheme ? 0.6 : 0.5) ??
            (isLightTheme ? Colors.black45 : Colors.grey.shade500);

    return Container(
      margin: const EdgeInsets.only(
        left: ZagUI.DEFAULT_MARGIN_SIZE,
        right: ZagUI.DEFAULT_MARGIN_SIZE,
        bottom: ZagUI.DEFAULT_MARGIN_SIZE,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: isLightTheme ? Border.all(color: Colors.black12) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.name.toUpperCase(),
            style: titleStyle,
          ),
          const SizedBox(height: 10),
          // Version
          Text(
            'unraid.ServerVersion'.tr(args: [info.version]),
            style: bodyStyle,
          ),
          const SizedBox(height: 8),
          // Registration
          if (info.registrationType != null) ...[
            Row(
              children: [
                Icon(Icons.badge, size: 16, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  'unraid.Registration'.tr(args: [info.formattedRegistrationType]),
                  style: bodyStyle,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          // Uptime
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(
                'unraid.Uptime'.tr(args: [info.os.formattedUptime]),
                style: bodyStyle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Array status
          Row(
            children: [
              Icon(Icons.dns, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text('unraid.ArrayLabel'.tr(), style: bodyStyle),
              Text(
                _arrayInfo?.state ?? 'zagreus.Unknown'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: _arrayInfo?.isStarted == true
                      ? Colors.green
                      : (bodyStyle.color?.withOpacity(isLightTheme ? 0.65 : 0.6) ??
                          (isLightTheme ? Colors.black45 : Colors.grey)),
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

    final usageLabel = 'unraid.UsedFree'.tr(args: [
      percentUsed.toStringAsFixed(0),
      formatStorage(capacity.freeTB),
    ]);

    final iconColor = _sectionIconColor(context);

    return ZagBlock(
      title: 'unraid.ArrayCapacity'.tr(),
      leading: Icon(
        Icons.storage,
        size: 32,
        color: iconColor,
      ),
      body: [
        TextSpan(
          text: 'unraid.TotalStorage'.tr(args: [formatStorage(capacity.totalTB)]),
        ),
        TextSpan(
          text: usageLabel,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
      bottomHeight: ZagLinearPercentIndicator.height,
      bottom: ZagLinearPercentIndicator(
        percent: percentUsed / 100,
        progressColor: percentUsed > 90
            ? ZagColours.red
            : percentUsed > 75
                ? ZagColours.orange
                : ZagColours.orange,
      ),
    );
  }

  Widget _buildMemoryCard() {
    final memory = _systemInfo?.memory;
    final metricsMemory = _metricsInfo?.memory;

    if (memory == null && metricsMemory == null) {
      return const SizedBox.shrink();
    }

    double? percentUsed = metricsMemory?.percentUsed ?? memory?.percentUsed;
    if (percentUsed != null) {
      percentUsed = percentUsed.clamp(0, 100);
    }

    final totalGB = metricsMemory?.totalGB ?? memory?.totalGB;
    final freeGB = metricsMemory?.availableGB ?? memory?.freeGB;
    final memoryTypeSpeed = memory?.formattedTypeAndSpeed ?? '';

    // Build the memory info string
    String memoryInfo;
    if (totalGB != null) {
      memoryInfo = 'unraid.TotalMemory'
          .tr(args: ['${totalGB.toStringAsFixed(1)} GB']);
    } else {
      memoryInfo = 'unraid.TotalMemory'.tr(args: ['zagreus.Unknown'.tr()]);
    }
    if (memoryTypeSpeed.isNotEmpty) {
      memoryInfo += ' $memoryTypeSpeed';
    }

    final progressPercent =
        ((percentUsed ?? 0) / 100).clamp(0.0, 1.0).toDouble();
    final percentLabel = percentUsed != null
        ? 'unraid.UsagePercent'.tr(args: [percentUsed.toStringAsFixed(0)])
        : 'unraid.UsageUnavailable'.tr();
    final freeLabel = freeGB != null
        ? 'unraid.FreeMemory'.tr(args: [freeGB.toStringAsFixed(1)])
        : 'unraid.FreeMemoryUnknown'.tr();

    final usageText = '$percentLabel ($freeLabel)';

    final iconColor = _sectionIconColor(context);

    return ZagBlock(
      title: 'unraid.Memory'.tr(),
      leading: Icon(
        Icons.memory,
        size: 32,
        color: iconColor,
      ),
      body: [
        TextSpan(text: memoryInfo),
        TextSpan(
          text: usageText,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
      bottomHeight: ZagLinearPercentIndicator.height,
      bottom: ZagLinearPercentIndicator(
        percent: progressPercent,
        progressColor: percentUsed != null && percentUsed > 90
            ? ZagColours.red
            : percentUsed != null && percentUsed > 75
                ? ZagColours.orange
                : Colors.green,
      ),
    );
  }

  Widget _buildPowerCard() {
    final ups = _upsInfo!;

    final iconColor = _sectionIconColor(context);

    return ZagBlock(
      title: 'unraid.Power'.tr(),
      leading: Icon(
        Icons.power,
        size: 32,
        color: iconColor,
      ),
      body: [
        TextSpan(text: 'unraid.UpsModel'.tr(args: [ups.displayName])),
        const TextSpan(text: '\n\n'),
        TextSpan(text: 'unraid.StatusLabel'.tr()),
        TextSpan(
          text: ups.status ?? 'zagreus.Unknown'.tr(),
          style: TextStyle(
            color: ups.isOnline ? Colors.green : Colors.orange,
          ),
        ),
        if (ups.power?.loadPercentage != null) ...[
          const TextSpan(text: '\n'),
          TextSpan(
            text: 'unraid.UpsLoad'
                .tr(args: [ups.power!.loadPercentage.toString()]),
          ),
        ],
        if (ups.battery?.chargeLevel != null) ...[
          const TextSpan(text: '\n'),
          TextSpan(
            text: 'unraid.BatteryCharge'
                .tr(args: [ups.battery!.chargeLevel.toString()]),
          ),
        ],
        if (ups.battery?.estimatedRuntime != null) ...[
          const TextSpan(text: '\n'),
          TextSpan(
            text: 'unraid.RuntimeLeftMinutes'
                .tr(args: [ups.battery!.estimatedRuntime.toString()]),
          ),
        ],
      ],
      customBodyMaxLines: 7,
    );
  }

  String _downloadHistoryPeriodLabel(BuildContext context, int weeksLookBack) {
    switch (weeksLookBack) {
      case 1:
        return 'unraid.DownloadHistoryPeriodWeek'.tr();
      case 2:
        return 'unraid.DownloadHistoryPeriodTwoWeeks'.tr();
      case 4:
        return 'unraid.DownloadHistoryPeriodMonth'.tr();
      default:
        return 'unraid.DownloadHistoryPeriodWeeks'
            .tr(args: [weeksLookBack.toString()]);
    }
  }
}
