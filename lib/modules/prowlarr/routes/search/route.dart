import 'package:flutter/material.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/prowlarr/core.dart';
import 'package:zagreus/modules/prowlarr/widgets/widgets.dart';

/// Prowlarr search page - search bar and results
class ProwlarrSearchPage extends StatefulWidget {
  final ProwlarrAPIWrapper apiWrapper;
  final ProwlarrState state;
  final int? categoryId;
  final String? categoryName;
  final String? initialQuery;

  const ProwlarrSearchPage({
    super.key,
    required this.apiWrapper,
    required this.state,
    this.categoryId,
    this.categoryName,
    this.initialQuery,
  });

  @override
  State<ProwlarrSearchPage> createState() => _State();
}

class _State extends State<ProwlarrSearchPage> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController _searchController;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    // Auto-load results if category is provided or initial query exists
    if (widget.categoryId != null ||
        (widget.initialQuery != null && widget.initialQuery!.isNotEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery ?? '');
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    // Allow empty query if category is provided (loads all results for category)
    if (query.isEmpty && widget.categoryId == null) return;

    widget.state.setLoading(true);
    if (query.isNotEmpty) {
      widget.state.addSearchToHistory(query);
    }

    try {
      final results = await widget.apiWrapper.search(
        query,
        categoryId: widget.categoryId,
      );
      if (!mounted) return;
      widget.state.setSearchResults(results.cast<ProwlarrItem>());
      widget.state.clearError();
      setState(() => _hasSearched = true);
    } catch (e) {
      if (!mounted) return;
      widget.state.setError(e.toString());
    } finally {
      if (mounted) {
        widget.state.setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProwlarrState>.value(
      value: widget.state,
      child: ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar(),
        body: _body(),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    String title = widget.categoryName ?? 'Search';
    return ZagAppBar(
      title: title,
      scrollControllers: [scrollController],
      bottom: ProwlarrSearchBar(
        controller: _searchController,
        scrollController: scrollController,
        onSubmitted: _performSearch,
      ),
      actions: [
        Consumer<ProwlarrState>(
          builder: (context, state, _) {
            if (state.searchResults.isEmpty) {
              return const SizedBox.shrink();
            }
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZagIconButton(
                  icon: Icons.sort_rounded,
                  onPressed: () => _showSortSheet(context),
                ),
                ZagIconButton(
                  icon: Icons.filter_list_rounded,
                  onPressed: () => _showFilterSheet(context),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _body() {
    return Consumer<ProwlarrState>(
      builder: (context, state, _) {
        if (state.isLoading) {
          return const ZagLoader();
        }

        if (state.error != null) {
          return ZagMessage.error(
            onTap: () => _performSearch(_searchController.text),
          );
        }

        if (!_hasSearched) {
          return Container();
        }

        final results = state.filteredAndSortedResults;

        if (results.isEmpty) {
          return ZagMessage(
            text: state.searchResults.isEmpty
                ? 'search.NoResultsFound'.tr()
                : 'No results match your filters',
            buttonText:
                state.filterConfig.hasActiveFilters ? 'Clear Filters' : null,
            onTap:
                state.filterConfig.hasActiveFilters ? state.clearFilters : null,
          );
        }

        return ZagListViewBuilder(
          controller: scrollController,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            return ProwlarrResultTile(
              item: item,
              apiWrapper: widget.apiWrapper,
            );
          },
        );
      },
    );
  }

  void _showSortSheet(BuildContext context) {
    final backgroundColor = ZagTheme.themeMode == 'light'
        ? ZagColours.primaryLight
        : (ZagTheme.isAMOLEDTheme ? Colors.black : ZagColours.primary);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Provide state to the sheet since it's in a new overlay context
        return ChangeNotifierProvider<ProwlarrState>.value(
          value: widget.state,
          child: Consumer<ProwlarrState>(
            builder: (context, state, _) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Sort By',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    ...ProwlarrSortOption.values.map((option) {
                      final isSelected = state.sortOption == option;
                      return ListTile(
                        leading: Icon(
                          option.icon,
                          color: isSelected
                              ? ZagColours.accentColor(context)
                              : null,
                        ),
                        title: Text(
                          option.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : null,
                            color: isSelected
                                ? ZagColours.accentColor(context)
                                : null,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: ZagColours.accentColor(context),
                              )
                            : null,
                        onTap: () {
                          state.setSortOption(option);
                          Navigator.of(sheetContext).pop();
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    final backgroundColor = ZagTheme.themeMode == 'light'
        ? ZagColours.primaryLight
        : (ZagTheme.isAMOLEDTheme ? Colors.black : ZagColours.primary);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Provide state to the sheet since it's in a new overlay context
        return ChangeNotifierProvider<ProwlarrState>.value(
          value: widget.state,
          child: Consumer<ProwlarrState>(
            builder: (context, state, _) {
              return DraggableScrollableSheet(
                expand: false,
                maxChildSize: 0.85,
                initialChildSize: 0.6,
                minChildSize: 0.4,
                builder: (context, scrollController) {
                  return ProwlarrFilterSheetContent(
                    scrollController: scrollController,
                    state: state,
                    onClose: () => Navigator.of(sheetContext).pop(),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// Search bar widget for Prowlarr
class ProwlarrSearchBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final ScrollController scrollController;
  final Function(String) onSubmitted;

  const ProwlarrSearchBar({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.onSubmitted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      child: ZagTextInputBar(
        controller: controller,
        scrollController: scrollController,
        autofocus: true,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

/// Filter sheet content widget
class ProwlarrFilterSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final ProwlarrState state;
  final VoidCallback onClose;

  const ProwlarrFilterSheetContent({
    super.key,
    required this.scrollController,
    required this.state,
    required this.onClose,
  });

  @override
  State<ProwlarrFilterSheetContent> createState() =>
      _ProwlarrFilterSheetContentState();
}

class _ProwlarrFilterSheetContentState
    extends State<ProwlarrFilterSheetContent> {
  late Set<String> _selectedIndexers;
  late TextEditingController _minSeedersController;
  late TextEditingController _maxAgeController;

  @override
  void initState() {
    super.initState();
    _selectedIndexers = Set.from(widget.state.filterConfig.selectedIndexers);
    _minSeedersController = TextEditingController(
      text: widget.state.filterConfig.minSeeders?.toString() ?? '',
    );
    _maxAgeController = TextEditingController(
      text: widget.state.filterConfig.maxAgeDays?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _minSeedersController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.state.setFilterConfig(
      ProwlarrFilterConfig(
        selectedIndexers: _selectedIndexers,
        minSeeders: int.tryParse(_minSeedersController.text),
        maxAgeDays: int.tryParse(_maxAgeController.text),
      ),
    );
    widget.onClose();
  }

  void _clearAll() {
    setState(() {
      _selectedIndexers.clear();
      _minSeedersController.clear();
      _maxAgeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableIndexers = widget.state.availableIndexers.toList()..sort();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Filter Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Indexers',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (availableIndexers.isEmpty)
                  Text(
                    'No indexers available',
                    style: TextStyle(color: Colors.grey[600]),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableIndexers.map((indexer) {
                      final isSelected = _selectedIndexers.contains(indexer);
                      return FilterChip(
                        label: Text(indexer),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedIndexers.add(indexer);
                            } else {
                              _selectedIndexers.remove(indexer);
                            }
                          });
                        },
                        selectedColor: ZagColours.accentColor(context)
                            .withValues(alpha: 0.3),
                        checkmarkColor: ZagColours.accentColor(context),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Minimum Seeders',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _minSeedersController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 5',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.arrow_upward_rounded),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Maximum Age (days)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _maxAgeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 30',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.schedule_rounded),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZagColours.accentColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
