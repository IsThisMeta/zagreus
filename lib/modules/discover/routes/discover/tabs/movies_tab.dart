import 'package:flutter/material.dart';

class DiscoverMoviesTabViewModel {
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final ScrollController scrollController;
  final bool showHeroCarousel;
  final Widget Function() heroCarousel;
  final List<Widget> Function() buildSections;
  final bool showAiSignInGate;
  final Widget Function() aiSignInGate;
  final Widget Function() customSectionsArea;
  final Widget Function() discoverSectionsButton;
  final Widget Function() autoRefreshNote;
  final Widget Function() metadataCredits;

  const DiscoverMoviesTabViewModel({
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.scrollController,
    required this.showHeroCarousel,
    required this.heroCarousel,
    required this.buildSections,
    required this.showAiSignInGate,
    required this.aiSignInGate,
    required this.customSectionsArea,
    required this.discoverSectionsButton,
    required this.autoRefreshNote,
    required this.metadataCredits,
  });
}

class DiscoverMoviesTab extends StatelessWidget {
  final DiscoverMoviesTabViewModel viewModel;

  const DiscoverMoviesTab({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6688FF)),
        ),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load recently downloaded',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.error!,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey
                    : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6688FF),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        controller: viewModel.scrollController,
        padding: EdgeInsets.zero,
        children: [
          if (viewModel.showHeroCarousel) viewModel.heroCarousel(),
          ...viewModel.buildSections(),
          if (viewModel.showAiSignInGate) viewModel.aiSignInGate(),
          viewModel.customSectionsArea(),
          viewModel.discoverSectionsButton(),
          viewModel.autoRefreshNote(),
          viewModel.metadataCredits(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
