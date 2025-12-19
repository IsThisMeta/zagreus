import 'package:flutter/material.dart';

class DiscoverShowsTabViewModel {
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

  const DiscoverShowsTabViewModel({
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

class DiscoverShowsTab extends StatelessWidget {
  final DiscoverShowsTabViewModel viewModel;

  const DiscoverShowsTab({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 16),
          viewModel.discoverSectionsButton(),
          viewModel.autoRefreshNote(),
          viewModel.metadataCredits(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
