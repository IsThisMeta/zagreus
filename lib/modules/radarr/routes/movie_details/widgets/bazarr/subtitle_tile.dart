import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

enum _SearchType { auto, manual }

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

    final missing = _bazarrMovie?.missingSubtitles ?? [];

    // If there are missing subtitles, let user pick which language to search
    if (missing.isNotEmpty) {
      final selected = await _showLanguageSelectionDialog(missing);
      if (selected == null) return; // User cancelled

      setState(() => _searchingSubtitles = true);
      try {
        await api.movie.autoSearch(
          radarrId: widget.radarrId,
          language: selected.code2,
          hearingImpaired: selected.hearingImpaired,
          forced: selected.forced,
        );
        showZagSuccessSnackBar(
          title: 'Subtitle Search Started',
          message: 'Searching for ${selected.name ?? selected.code2}...',
        );
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
    } else {
      // No missing subtitles - search anyway (user explicitly requested)
      setState(() => _searchingSubtitles = true);
      try {
        await api.movie.autoSearch(radarrId: widget.radarrId);
        showZagSuccessSnackBar(
          title: 'Subtitle Search Started',
          message: 'Bazarr is searching for subtitles...',
        );
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
  }

  Future<BazarrSubtitle?> _showLanguageSelectionDialog(
      List<BazarrSubtitle> languages) async {
    return showDialog<BazarrSubtitle>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              final flags = <String>[];
              if (lang.hearingImpaired == true) flags.add('HI');
              if (lang.forced == true) flags.add('Forced');
              return ListTile(
                title: Text(lang.name ?? lang.code2 ?? 'Unknown'),
                subtitle: flags.isNotEmpty ? Text(flags.join(' • ')) : null,
                onTap: () => Navigator.pop(ctx, lang),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: ZagColours.textColor(ctx))),
          ),
        ],
      ),
    );
  }

  Future<void> _manualSearchSubtitles() async {
    final api = _getApi();
    if (api == null) return;

    setState(() => _searchingSubtitles = true);

    try {
      final results = await api.provider.searchMovieSubtitles(
        radarrId: widget.radarrId,
      );
      setState(() => _searchingSubtitles = false);

      if (!mounted) return;

      if (results.isEmpty) {
        showZagInfoSnackBar(
          title: 'No Subtitles Found',
          message: 'No subtitles available from providers',
        );
        return;
      }

      await _showManualSearchResults(results);
    } catch (e, stack) {
      ZagLogger().error('Failed to search subtitles', e, stack);
      showZagErrorSnackBar(
        title: 'Subtitle Search Failed',
        error: e,
      );
      setState(() => _searchingSubtitles = false);
    }
  }

  Future<void> _showManualSearchResults(
      List<BazarrSubtitleSearchResult> results) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Subtitles (${results.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final result = results[index];
                  return _SubtitleResultTile(
                    result: result,
                    onDownload: () => _downloadSubtitle(result),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadSubtitle(BazarrSubtitleSearchResult result) async {
    final api = _getApi();
    if (api == null) return;

    Navigator.of(context).pop(); // Close the bottom sheet

    try {
      await api.provider.downloadMovieSubtitle(
        radarrId: widget.radarrId,
        language: result.language ?? '',
        provider: result.provider ?? '',
        subtitle: result.subtitle ?? '',
        hearingImpaired: result.hearingImpaired == 'True',
        forced: result.forced == 'True',
      );
      showZagSuccessSnackBar(
        title: 'Subtitle Downloaded',
        message: '${result.language} subtitle from ${result.provider}',
      );
      // Reload data
      await _loadBazarrData();
    } catch (e, stack) {
      ZagLogger().error('Failed to download subtitle', e, stack);
      showZagErrorSnackBar(
        title: 'Download Failed',
        error: e,
      );
    }
  }

  void _showSearchMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    HapticFeedback.selectionClick();
    showMenu<_SearchType>(
      context: context,
      position: position,
      shape: ZagUI.shapeBorder,
      items: [
        PopupMenuItem(
          value: _SearchType.auto,
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 20, color: ZagColours.currentAccent),
              const SizedBox(width: 12),
              const Text('Auto Search'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _SearchType.manual,
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  size: 20, color: ZagColours.currentAccent),
              const SizedBox(width: 12),
              const Text('Manual Search'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == _SearchType.auto) {
        _autoSearchSubtitles();
      } else if (value == _SearchType.manual) {
        _manualSearchSubtitles();
      }
    });
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
                  onPressed: _showSearchMenu,
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

class _SubtitleResultTile extends StatelessWidget {
  final BazarrSubtitleSearchResult result;
  final VoidCallback onDownload;

  const _SubtitleResultTile({
    required this.result,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final flags = <String>[];
    if (result.hearingImpaired == 'True') flags.add('HI');
    if (result.forced == 'True') flags.add('Forced');

    final releaseInfo = result.releaseInfo?.join(' ') ?? '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Row(
        children: [
          Expanded(
            child: Text(
              result.language ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (result.score != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _scoreColor(result.score!).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${result.score}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _scoreColor(result.score!),
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.cloud_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  result.provider ?? 'Unknown provider',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (flags.isNotEmpty)
                Text(
                  flags.join(' • '),
                  style: TextStyle(
                    fontSize: 11,
                    color: ZagColours.currentAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          // Matches info (like nzb360)
          if ((result.matches?.isNotEmpty ?? false) ||
              (result.dontMatches?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 12, color: Colors.green[400]),
                const SizedBox(width: 4),
                Text(
                  '${result.matches?.length ?? 0} Matches',
                  style: TextStyle(fontSize: 11, color: Colors.green[400]),
                ),
                const SizedBox(width: 8),
                Icon(Icons.cancel_outlined, size: 12, color: Colors.red[400]),
                const SizedBox(width: 4),
                Text(
                  '${result.dontMatches?.length ?? 0} Missing',
                  style: TextStyle(fontSize: 11, color: Colors.red[400]),
                ),
              ],
            ),
          ],
          if (releaseInfo.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              releaseInfo,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (result.uploader != null && result.uploader!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.person_outline, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    result.uploader!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.download_rounded, color: ZagColours.currentAccent),
        onPressed: onDownload,
      ),
      onTap: onDownload,
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}

