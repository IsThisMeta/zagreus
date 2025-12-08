import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zagreus/widgets/ui/colors.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/services/subscription_service.dart';

class SonarrAddSeriesStreamingProvidersTile extends StatefulWidget {
  final SonarrSeries? series;

  const SonarrAddSeriesStreamingProvidersTile({
    Key? key,
    required this.series,
  }) : super(key: key);

  @override
  State<SonarrAddSeriesStreamingProvidersTile> createState() =>
      _SonarrAddSeriesStreamingProvidersTileState();
}

class _SonarrAddSeriesStreamingProvidersTileState
    extends State<SonarrAddSeriesStreamingProvidersTile> {
  List<Map<String, dynamic>> _streamingProviders = [];
  List<Map<String, dynamic>> _buyRentProviders = [];
  String? _fallbackLink;
  bool _loading = true;
  bool _hasError = false;
  late final bool _isPremium;

  // Max icons per section (side by side layout)
  static const int _maxVisibleIcons = 4;

  @override
  void initState() {
    super.initState();
    _isPremium = SubscriptionService.isPremium;

    if (_isPremium) {
      _loadProviders();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadProviders() async {
    final imdbId = widget.series?.imdbId;
    if (imdbId == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      // Look up TMDB ID from IMDb ID
      final tmdbId = await TMDBApi.getTmdbIdFromImdb(imdbId);
      if (tmdbId == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      // Get user's region from locale
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final results = await TMDBApi.getTVShowWatchProviders(
        tmdbId,
        region: region,
      );

      setState(() {
        _streamingProviders = results['streaming'] ?? [];
        _buyRentProviders = results['buyRent'] ?? [];
        _fallbackLink = results['link'] as String?;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPremium) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streaming On (left side)
          Expanded(
            child: _buildProviderSection(
              'Streaming On',
              _streamingProviders,
              isLoading: _loading,
              hasError: _hasError,
            ),
          ),
          const SizedBox(width: 24),
          // Buy/Rent On (right side)
          Expanded(
            child: _buildProviderSection(
              'Buy/Rent On',
              _buyRentProviders,
              isLoading: _loading,
              hasError: _hasError,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSection(
    String title,
    List<Map<String, dynamic>> providers, {
    required bool isLoading,
    required bool hasError,
  }) {
    final visibleProviders = providers.take(_maxVisibleIcons).toList();
    final isEmpty = providers.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: isLoading
              ? const Align(
                  alignment: Alignment.centerLeft,
                  child: _ThreeDotsLoading(),
                )
              : (hasError || isEmpty)
                  ? const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: visibleProviders
                          .where((provider) {
                            final logoPath = provider['logo_path'] as String?;
                            return logoPath != null && logoPath.isNotEmpty;
                          })
                          .map((provider) {
                            final logoPath = provider['logo_path'] as String;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => _openProvider(provider),
                                child: Tooltip(
                                  message: provider['provider_name'] ?? '',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      TMDBApi.getImageUrl(logoPath, size: 'w92'),
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
        ),
      ],
    );
  }

  Future<void> _openProvider(Map<String, dynamic> provider) async {
    final series = widget.series;
    if (series == null) return;

    final providerId = provider['provider_id'] as int;
    final providerName = provider['provider_name'] as String? ?? 'Unknown';
    final title = series.title;
    final imdbId = series.imdbId;

    if (title == null || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open $providerName: Missing title'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // For TV shows we need to look up TMDB ID from IMDb ID
    int? tmdbId;
    try {
      if (imdbId != null) {
        tmdbId = await TMDBApi.getTmdbIdFromImdb(imdbId);
      }
    } catch (e) {
      // Failed to get TMDB ID
    }

    if (tmdbId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open $providerName: Missing TMDB ID'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Build deep link for this provider
    final deepLink = TMDBApi.buildProviderDeepLink(
      providerId: providerId,
      providerName: providerName,
      tmdbId: tmdbId,
      title: title,
      mediaType: 'tv',
      fallbackLink: _fallbackLink,
    );

    if (deepLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No link available for $providerName'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(deepLink);

      // Determine launch mode: open web links (e.g. JustWatch) in-app, deep links externally
      final isWebUrl = uri.scheme == 'http' || uri.scheme == 'https';
      final mode =
          isWebUrl ? LaunchMode.inAppWebView : LaunchMode.externalApplication;

      final launched = await launchUrl(uri, mode: mode);

      if (!launched) {
        // If deep link fails, try the fallback JustWatch link in an in-app browser
        if (_fallbackLink != null) {
          final fallbackUri = Uri.parse(_fallbackLink!);
          await launchUrl(fallbackUri, mode: LaunchMode.inAppWebView);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unable to open $providerName'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      // If deep link throws an exception, try the fallback JustWatch link
      if (_fallbackLink != null) {
        try {
          final fallbackUri = Uri.parse(_fallbackLink!);
          await launchUrl(fallbackUri, mode: LaunchMode.inAppWebView);
        } catch (fallbackError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error opening link: $fallbackError'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening $providerName: $e'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

/// Three bouncing dots loading indicator
class _ThreeDotsLoading extends StatelessWidget {
  const _ThreeDotsLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
          child: _BouncingDot(delay: index * 200),
        ),
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;

  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: ZagColours.currentAccent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
