import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/bazarr/bazarr.dart';
import 'package:zagreus/api/bazarr/models.dart';

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
  bool _searchingSubtitles = false;

  @override
  void initState() {
    super.initState();
    _loadBazarrData();
  }

  BazarrAPI? _getApi() {
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

  Future<void> _autoSearchSubtitles() async {
    final api = _getApi();
    if (api == null) return;

    setState(() => _searchingSubtitles = true);

    try {
      await api.series.autoSearch(seriesId: widget.sonarrSeriesId);
      showZagSuccessSnackBar(
        title: 'Subtitle Search Started',
        message: 'Bazarr is searching for subtitles for all episodes...',
      );
      // Reload data after a short delay
      await Future.delayed(const Duration(seconds: 2));
      await _loadBazarrData();
    } catch (e, stack) {
      ZagLogger().error('Failed to search subtitles', e, stack);
      showZagErrorSnackBar(
        title: 'Subtitle Search Failed',
        error: e,
      );
    } finally {
      setState(() => _searchingSubtitles = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show if Bazarr is not enabled
    if (!ZagProfile.current.bazarrEnabled) {
      return const SizedBox.shrink();
    }

    // Don't show if Bazarr is not configured
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

    return _subtitleTile();
  }

  Widget _notConfiguredTile() {
    return ZagBlock(
      title: 'Subtitles (Bazarr)',
      body: const [
        TextSpan(text: 'Bazarr is not configured. Configure it in Settings.'),
      ],
      trailing: ZagIconButton(
        icon: Icons.settings_rounded,
        onPressed: () => ZagModule.BAZARR.settingsRoute?.go(),
      ),
    );
  }

  Widget _loadingTile() {
    return const ZagBlock(
      title: 'Subtitles (Bazarr)',
      body: [TextSpan(text: 'Loading subtitle data...')],
      trailing: ZagLoader(),
    );
  }

  Widget _errorTile() {
    return ZagBlock(
      title: 'Subtitles (Bazarr)',
      body: const [
        TextSpan(text: 'Failed to load subtitle data'),
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
      title: 'Subtitles (Bazarr)',
      body: const [
        TextSpan(text: 'Series not found in Bazarr'),
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

  Widget _subtitleTile() {
    final episodeCount = _bazarrSeries?.episodeFileCount ?? 0;
    final missingCount = _bazarrSeries?.episodesMissing ?? 0;
    final downloadedCount = episodeCount - missingCount;

    return ZagBlock(
      title: 'Subtitles (Bazarr)',
      body: [
        TextSpan(
          text: episodeCount == 0
              ? 'No episodes with files'
              : '$downloadedCount/$episodeCount episodes have subtitles',
        ),
      ],
      trailing: _searchingSubtitles
          ? const ZagLoader()
          : ZagIconButton(
              icon: Icons.search_rounded,
              onPressed: missingCount == 0 ? null : _autoSearchSubtitles,
            ),
    );
  }
}
