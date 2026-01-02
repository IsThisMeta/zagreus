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

    if (_bazarrMovie == null) {
      return _noDataTile();
    }

    return _subtitleContent();
  }

  Widget _notConfiguredTile() {
    return ZagBlock(
      title: 'radarr.BazarrNotConfigured'.tr(),
      body: [
        TextSpan(text: 'radarr.BazarrNotConfiguredDescription'.tr()),
      ],
      trailing: ZagIconButton(
        icon: Icons.settings_rounded,
        onPressed: () => ZagModule.BAZARR.settingsRoute?.go(),
      ),
    );
  }

  Widget _loadingTile() {
    return ZagBlock(
      title: 'radarr.BazarrLoadingSubtitles'.tr(),
      body: [TextSpan(text: 'radarr.BazarrLoadingSubtitlesDescription'.tr())],
      trailing: const ZagLoader(),
    );
  }

  Widget _errorTile() {
    return ZagBlock(
      title: 'radarr.BazarrConnectionError'.tr(),
      body: [
        TextSpan(text: 'radarr.BazarrConnectionErrorDescription'.tr()),
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
      title: 'radarr.BazarrNotFound'.tr(),
      body: [
        TextSpan(text: 'radarr.BazarrNotFoundDescription'.tr()),
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

    if (existing.isEmpty && missing.isEmpty) {
      return ZagBlock(
        title: 'radarr.BazarrNoSubtitleRequirements'.tr(),
        body: [
          TextSpan(text: 'radarr.BazarrNoSubtitleRequirementsDescription'.tr()),
        ],
      );
    }

    // Build list of subtitle tags (existing first, then missing)
    List<Widget> tags = [];

    for (final subtitle in existing) {
      tags.add(_SubtitleTag(subtitle: subtitle, isDownloaded: true));
    }

    for (final subtitle in missing) {
      tags.add(_SubtitleTag(subtitle: subtitle, isDownloaded: false));
    }

    return ZagBlock(
      title: 'radarr.Subtitles'.tr(),
      body: const [],
      bottom: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: tags
              .expand((tag) => [tag, const SizedBox(width: 4.0)])
              .take(tags.length * 2 - 1)
              .toList(),
        ),
      ),
    );
  }

  Widget _proLockedTile() {
    return ZagBlock(
      title: 'radarr.ZagreusProRequired'.tr(),
      body: [
        TextSpan(text: 'radarr.BazarrProRequiredDescription'.tr()),
      ],
      trailing: const ZagIconButton(icon: Icons.lock_rounded),
      onTap: () => showZagInfoSnackBar(
        title: 'radarr.ZagreusProRequired'.tr(),
        message: 'radarr.BazarrProRequiredMessage'.tr(),
      ),
    );
  }
}

class _SubtitleTag extends StatelessWidget {
  final BazarrSubtitle subtitle;
  final bool isDownloaded;

  const _SubtitleTag({
    Key? key,
    required this.subtitle,
    required this.isDownloaded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String label =
        subtitle.name ?? subtitle.code2 ?? 'zagreus.Unknown'.tr();

    // Downloaded: accent color border, Missing: gray border
    final borderColor = isDownloaded
        ? ZagColours.currentAccent
        : (isDark ? ZagColours.grey : Colors.grey.shade500);

    final textColor = isDownloaded
        ? (isDark ? Colors.white : Colors.black87)
        : (isDark ? ZagColours.grey : Colors.grey.shade600);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.0,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          color: textColor,
        ),
      ),
    );
  }
}
