import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/bazarr/bazarr.dart';
import 'package:zagreus/api/bazarr/models.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class RadarrBazarrSubtitleTile extends StatefulWidget {
  final int radarrId;

  const RadarrBazarrSubtitleTile({
    Key? key,
    required this.radarrId,
  }) : super(key: key);

  @override
  State<RadarrBazarrSubtitleTile> createState() => _State();
}

class _State extends State<RadarrBazarrSubtitleTile> {
  BazarrMovie? _bazarrMovie;
  bool _loading = true;
  String? _error;
  bool _searchingSubtitles = false;

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
      final movie = await api.movie.get(radarrId: widget.radarrId);
      setState(() {
        _bazarrMovie = movie;
        _loading = false;
        _error = null;
      });
    } catch (e, stack) {
      ZagLogger().error('Failed to load Bazarr data', e, stack);
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
      await api.movie.autoSearch(radarrId: widget.radarrId);
      showZagSuccessSnackBar(
        title: 'Subtitle Search Started',
        message: 'Bazarr is searching for subtitles...',
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

    // Show lock for non-Pro users
    if (!ZagreusPro.isEnabled) {
      return _proLockedTile();
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

    if (_bazarrMovie == null) {
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
        TextSpan(text: 'Movie not found in Bazarr'),
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
    final existing = _bazarrMovie?.existingSubtitles ?? [];
    final missing = _bazarrMovie?.missingSubtitles ?? [];

    return Column(
      children: [
        ZagBlock(
          title: 'Subtitles (Bazarr)',
          body: [
            TextSpan(
              text: existing.isEmpty && missing.isEmpty
                  ? 'No subtitle requirements configured'
                  : '${existing.length} downloaded, ${missing.length} missing',
            ),
          ],
          trailing: _searchingSubtitles
              ? const ZagLoader()
              : ZagIconButton(
                  icon: Icons.search_rounded,
                  onPressed: missing.isEmpty ? null : _autoSearchSubtitles,
                ),
        ),
        if (existing.isNotEmpty)
          ZagTableCard(
            title: 'Downloaded Subtitles',
            content: existing.map((s) => ZagTableContent(
              title: s.name ?? s.code2 ?? 'Unknown',
              body: [
                if (s.forced == true) 'Forced',
                if (s.hearingImpaired == true) 'HI',
              ].join(', ').ifEmpty(null),
            )).toList(),
          ),
        if (missing.isNotEmpty)
          ZagTableCard(
            title: 'Missing Subtitles',
            content: missing.map((s) => ZagTableContent(
              title: s.name ?? s.code2 ?? 'Unknown',
              body: [
                if (s.forced == true) 'Forced',
                if (s.hearingImpaired == true) 'HI',
              ].join(', ').ifEmpty(null),
            )).toList(),
          ),
      ],
    );
  }

  Widget _proLockedTile() {
    return ZagBlock(
      title: 'Subtitles (Bazarr)',
      body: const [
        TextSpan(text: 'Zagreus Pro required to manage subtitles with Bazarr.'),
      ],
      trailing: const ZagIconButton(icon: Icons.lock_rounded),
      onTap: () => showZagInfoSnackBar(
        title: 'Zagreus Pro required',
        message: 'Upgrade to access Bazarr subtitle actions.',
      ),
    );
  }
}

extension _StringExtension on String {
  String? ifEmpty(String? replacement) => isEmpty ? replacement : this;
}
