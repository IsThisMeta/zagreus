import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zagreus/widgets/ui/colors.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/services/subscription_service.dart';

class RadarrAddMovieStreamingProvidersTile extends StatefulWidget {
  final RadarrMovie? movie;

  const RadarrAddMovieStreamingProvidersTile({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  State<RadarrAddMovieStreamingProvidersTile> createState() =>
      _RadarrAddMovieStreamingProvidersTileState();
}

class _RadarrAddMovieStreamingProvidersTileState
    extends State<RadarrAddMovieStreamingProvidersTile> {
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
    final tmdbId = widget.movie?.tmdbId;
    if (tmdbId == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      // Get user's region from locale
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final results = await TMDBApi.getMovieWatchProviders(
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
              alignLeft: true,
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
              alignLeft: false,
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
    required bool alignLeft,
  }) {
    final visibleProviders = providers.take(_maxVisibleIcons).toList();
    final hasMore = providers.length > _maxVisibleIcons;
    final hiddenCount = providers.length - _maxVisibleIcons;
    final isEmpty = providers.isEmpty;

    return Column(
      crossAxisAlignment: alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
              ? Align(
                  alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
                  child: const _ThreeDotsLoading(),
                )
              : (hasError || isEmpty)
                  ? Align(
                      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
                      child: const Text(
                        'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Wrap(
                      alignment: alignLeft ? WrapAlignment.start : WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...visibleProviders.map((provider) {
                          final logoPath = provider['logo_path'] as String?;
                          if (logoPath == null || logoPath.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return GestureDetector(
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
                          );
                        }),
                        if (hasMore)
                          GestureDetector(
                            onTap: () => _showAllProviders(title, providers),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '+$hiddenCount',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
        ),
      ],
    );
  }

  void _showAllProviders(String title, List<Map<String, dynamic>> providers) {
    final providerNames = providers
        .map((p) => p['provider_name'] as String?)
        .where((name) => name != null && name.isNotEmpty)
        .join(', ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $providerNames'),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openProvider(Map<String, dynamic> provider) async {
    final movie = widget.movie;
    if (movie == null) return;

    final providerId = provider['provider_id'] as int;
    final providerName = provider['provider_name'] as String? ?? 'Unknown';
    final title = movie.title;
    final tmdbId = movie.tmdbId;

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
      mediaType: 'movie',
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
