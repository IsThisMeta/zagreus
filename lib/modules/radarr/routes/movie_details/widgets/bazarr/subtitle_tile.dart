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
    // Don't show anything if Bazarr is not enabled
    if (!ZagProfile.current.bazarrEnabled) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZagHeader(text: 'Subtitles'),
        _buildContent(),
      ],
    );
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

    if (_bazarrMovie == null) {
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
    final existing = _bazarrMovie?.existingSubtitles ?? [];
    final missing = _bazarrMovie?.missingSubtitles ?? [];
    final hasMissing = missing.isNotEmpty;

    return Column(
      children: [
        // Status block with search action
        ZagBlock(
          title: existing.isEmpty && missing.isEmpty
              ? 'No Subtitle Requirements'
              : '${existing.length} Downloaded${hasMissing ? ', ${missing.length} Missing' : ''}',
          body: [
            TextSpan(
              text: existing.isEmpty && missing.isEmpty
                  ? 'Configure subtitle languages in Bazarr'
                  : hasMissing
                      ? 'Tap search to find missing subtitles'
                      : 'All required subtitles are available',
            ),
          ],
          trailing: _searchingSubtitles
              ? const ZagLoader()
              : ZagIconButton(
                  icon: Icons.search_rounded,
                  color: hasMissing ? ZagColours.currentAccent : null,
                  onPressed: hasMissing ? _autoSearchSubtitles : null,
                ),
        ),
        // Downloaded subtitles list
        if (existing.isNotEmpty)
          ZagTableCard(
            title: 'Downloaded',
            content: existing.map((s) => ZagTableContent(
              title: s.name ?? s.code2 ?? 'Unknown',
              body: _formatSubtitleFlags(s),
            )).toList(),
          ),
        // Missing subtitles list
        if (missing.isNotEmpty)
          ZagTableCard(
            title: 'Missing',
            content: missing.map((s) => ZagTableContent(
              title: s.name ?? s.code2 ?? 'Unknown',
              body: _formatSubtitleFlags(s),
            )).toList(),
          ),
      ],
    );
  }

  String? _formatSubtitleFlags(BazarrSubtitle s) {
    final flags = <String>[];
    if (s.forced == true) flags.add('Forced');
    if (s.hearingImpaired == true) flags.add('HI');
    return flags.isEmpty ? null : flags.join(' • ');
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

