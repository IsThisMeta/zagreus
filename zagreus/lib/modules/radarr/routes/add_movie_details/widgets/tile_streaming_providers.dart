import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // Max icons to show before "+" overflow indicator
  static const int _maxVisibleIcons = 6;

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
    if (!_isPremium ||
        _loading ||
        _hasError ||
        (_streamingProviders.isEmpty && _buyRentProviders.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_streamingProviders.isNotEmpty) ...[
            _buildProviderSection(
              'Streaming On',
              _streamingProviders,
            ),
            if (_buyRentProviders.isNotEmpty) const SizedBox(height: 12),
          ],
          if (_buyRentProviders.isNotEmpty)
            _buildProviderSection(
              'Buy/Rent On',
              _buyRentProviders,
            ),
        ],
      ),
    );
  }

  Widget _buildProviderSection(
    String title,
    List<Map<String, dynamic>> providers,
  ) {
    final visibleProviders = providers.take(_maxVisibleIcons).toList();
    final hasMore = providers.length > _maxVisibleIcons;
    final hiddenCount = providers.length - _maxVisibleIcons;

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
          height: 32,
          child: Row(
            children: [
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: visibleProviders.length + (hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (hasMore && index == visibleProviders.length) {
                      // Show "+N more" indicator
                      return GestureDetector(
                        onTap: () => _showAllProviders(title, providers),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
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
                      );
                    }

                    final provider = visibleProviders[index];
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
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    );
                  },
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
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // If deep link fails, try the fallback link
        if (_fallbackLink != null) {
          final fallbackUri = Uri.parse(_fallbackLink!);
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
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
