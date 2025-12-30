import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/bazarr/bazarr.dart';
import 'package:zagreus/api/bazarr/models.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class SonarrBazarrSubtitleTile extends StatefulWidget {
  final int sonarrSeriesId;

  const SonarrBazarrSubtitleTile({
    Key? key,
    required this.sonarrSeriesId,
  }) : super(key: key);

  @override
  State<SonarrBazarrSubtitleTile> createState() => _State();
}

class _State extends State<SonarrBazarrSubtitleTile> {
  BazarrSeries? _bazarrSeries;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBazarrData();
  }

  BazarrAPI? _getApi() {
    if (!ZagreusPro.isEnabled) return null;
    final profile = ZagProfile.current;
    if (!profile.bazarrEnabled) return null;
    final host = profile.effectiveBazarrHost();
    if (host.isEmpty || profile.bazarrKey.isEmpty) return null;
    return BazarrAPI(
      host: host,
      apiKey: profile.bazarrKey,
      headers: Map<String, dynamic>.from(profile.bazarrHeaders),
    );
  }

  Future<void> _loadBazarrData() async {
    final api = _getApi();
    if (api == null) {
      setState(() {
        _loading = false;
        _error = null;
      });
      return;
    }

    try {
      final series = await api.series.get(seriesId: widget.sonarrSeriesId);
      setState(() {
        _bazarrSeries = series;
        _loading = false;
        _error = null;
      });
    } catch (e, stack) {
      ZagLogger().error('Failed to load Bazarr series data', e, stack);
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if Bazarr is not enabled
    if (!ZagProfile.current.bazarrEnabled) {
      return const SizedBox.shrink();
    }

    return _buildContent();
  }

  Widget _buildContent() {
    // Show lock for non-Pro users
    if (!ZagreusPro.isEnabled) {
      return _proLockedTile();
    }

    // Show not configured if Bazarr is not set up
    final host = ZagProfile.current.effectiveBazarrHost();
    if (host.isEmpty || ZagProfile.current.bazarrKey.isEmpty) {
      return _notConfiguredTile();
    }

    if (_loading) {
      return _loadingTile();
    }

    if (_error != null) {
      return _errorTile();
    }

    if (_bazarrSeries == null) {
      return _noDataTile();
    }

    return _subtitleContent();
  }

  Widget _notConfiguredTile() {
    return ZagBlock(
      title: 'Bazarr Not Configured',
      body: const [
        TextSpan(text: 'Set up Bazarr in Settings to manage subtitles'),
      ],
      trailing: ZagIconButton(
        icon: Icons.settings_rounded,
        onPressed: () => ZagModule.BAZARR.settingsRoute?.go(),
      ),
    );
  }

  Widget _loadingTile() {
    return const ZagBlock(
      title: 'Loading Subtitles',
      body: [TextSpan(text: 'Fetching subtitle data from Bazarr...')],
      trailing: ZagLoader(),
    );
  }

  Widget _errorTile() {
    return ZagBlock(
      title: 'Connection Error',
      body: const [
        TextSpan(text: 'Could not load subtitle data from Bazarr'),
      ],
      trailing: ZagIconButton(
        icon: Icons.refresh_rounded,
        onPressed: () {
          setState(() => _loading = true);
          _loadBazarrData();
        },
      ),
    );
  }

  Widget _noDataTile() {
    return ZagBlock(
      title: 'Not Found in Bazarr',
      body: const [
        TextSpan(text: 'This wasn\'t found in your Bazarr library'),
      ],
      trailing: ZagIconButton(
        icon: Icons.refresh_rounded,
        onPressed: () {
          setState(() => _loading = true);
          _loadBazarrData();
        },
      ),
    );
  }

  Widget _subtitleContent() {
    final episodeCount = _bazarrSeries?.episodeFileCount ?? 0;
    final missingCount = _bazarrSeries?.episodesMissing ?? 0;
    final downloadedCount = episodeCount - missingCount;
    final hasMissing = missingCount > 0;

    String title;
    String subtitle;

    if (episodeCount == 0) {
      title = 'No Episodes With Files';
      subtitle = 'Episodes need files before subtitles can be downloaded';
    } else if (hasMissing) {
      title = '$downloadedCount/$episodeCount Episodes Complete';
      subtitle = '$missingCount episodes missing subtitles';
    } else {
      title = 'All Episodes Complete';
      subtitle = 'Subtitles available for all $episodeCount episodes';
    }

    return ZagBlock(
      title: title,
      body: [TextSpan(text: subtitle)],
    );
  }

  Widget _proLockedTile() {
    return ZagBlock(
      title: 'Zagreus Pro Required',
      body: const [
        TextSpan(text: 'Upgrade to Pro to manage subtitles with Bazarr'),
      ],
      trailing: const ZagIconButton(icon: Icons.lock_rounded),
      onTap: () => showZagInfoSnackBar(
        title: 'Zagreus Pro Required',
        message: 'Upgrade to access Bazarr subtitle management',
      ),
    );
  }
}

