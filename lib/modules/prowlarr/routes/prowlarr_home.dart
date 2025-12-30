import 'package:flutter/material.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules/prowlarr/core.dart';
import 'package:zagreus/modules/prowlarr/widgets/widgets.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

/// Prowlarr home page - main search interface
class ProwlarrHomePage extends StatefulWidget {
  final ZagIndexer indexer;

  const ProwlarrHomePage({
    super.key,
    required this.indexer,
  });

  @override
  State<ProwlarrHomePage> createState() => _ProwlarrHomePageState();
}

class _ProwlarrHomePageState extends State<ProwlarrHomePage> {
  late ProwlarrAPIWrapper _apiWrapper;
  late ProwlarrState _state;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _apiWrapper = ProwlarrAPIWrapper(widget.indexer);
    _state = ProwlarrState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _state.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    _state.setLoading(true);
    try {
      final categories = await _apiWrapper.getCategories();
      if (!mounted) return;
      _state.setCategories(categories.cast<ProwlarrCategory>());
      _state.clearError();
    } catch (e) {
      if (!mounted) return;
      _state.setError(e.toString());
    } finally {
      if (mounted) {
        _state.setLoading(false);
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    _state.setLoading(true);
    _state.addSearchToHistory(query);

    try {
      final results = await _apiWrapper.search(
        query,
        categoryId: _state.selectedCategory?.id,
      );
      if (!mounted) return;
      _state.setSearchResults(results.cast<ProwlarrItem>());
      _state.clearError();
    } catch (e) {
      if (!mounted) return;
      _state.setError(e.toString());
    } finally {
      if (mounted) {
        _state.setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user has Pro access
    if (!ZagreusPro.isEnabled) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(widget.indexer.displayName),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 64, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  'zagreus.Pro'.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Prowlarr search is a Pro feature. Upgrade to Pro to search with Prowlarr.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider<ProwlarrState>.value(
      value: _state,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(widget.indexer.displayName),
          actions: [
            Consumer<ProwlarrState>(
              builder: (context, state, _) {
                // Only show sort/filter when we have results
                if (state.searchResults.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sort button
                    IconButton(
                      icon: const Icon(Icons.sort_rounded),
                      tooltip: 'Sort',
                      onPressed: () => _showSortSheet(context),
                    ),
                    // Filter button with badge
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.filter_list_rounded),
                          tooltip: 'Filter',
                          onPressed: () => _showFilterSheet(context),
                        ),
                        if (state.filterConfig.hasActiveFilters)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: ZagColours.accentColor(context),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${state.filterConfig.activeFilterCount}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                onSubmitted: _performSearch,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Consumer<ProwlarrState>(
            builder: (context, state, child) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCategories,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state.searchResults.isEmpty && _searchController.text.isEmpty) {
                return _buildCategoriesView(state.categories);
              }

              return _buildSearchResults(state);
            },
          ),
        ),
      ),
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
        return Consumer<ProwlarrState>(
          builder: (context, state, _) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        return Consumer<ProwlarrState>(
          builder: (context, state, _) {
            return DraggableScrollableSheet(
              expand: false,
              maxChildSize: 0.85,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              builder: (context, scrollController) {
                return _FilterSheetContent(
                  scrollController: scrollController,
                  state: state,
                  onClose: () => Navigator.of(sheetContext).pop(),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesView(List<ProwlarrCategory> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Text('No categories available'),
      );
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final hasSubcategories = category.subCategories != null &&
                                 category.subCategories!.isNotEmpty;

        return ListTile(
          title: Text(category.name ?? 'Unknown'),
          subtitle: category.description != null
              ? Text(category.description!)
              : hasSubcategories
                  ? Text('${category.subCategories!.length} subcategories')
                  : null,
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async {
            _state.setSelectedCategory(category);

            if (hasSubcategories) {
              // Show subcategories
              _showSubcategoriesSheet(category);
            } else {
              // Perform a search with empty query to get all results for this category
              _state.setLoading(true);
              try {
                final results = await _apiWrapper.search(
                  '', // Empty query to get all results in category
                  categoryId: category.id,
                );
                if (!mounted) return;
                _state.setSearchResults(results.cast<ProwlarrItem>());
                _state.clearError();
              } catch (e) {
                if (!mounted) return;
                _state.setError(e.toString());
              } finally {
                if (mounted) {
                  _state.setLoading(false);
                }
              }
            }
          },
        );
      },
    );
  }

  void _showSubcategoriesSheet(ProwlarrCategory parentCategory) {
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
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  parentCategory.name ?? 'Subcategories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: parentCategory.subCategories!.length,
                  itemBuilder: (context, index) {
                    final subcategory = parentCategory.subCategories![index];
                    return ListTile(
                      title: Text(subcategory.name ?? 'Unknown'),
                      subtitle: subcategory.description != null
                          ? Text(subcategory.description!)
                          : null,
                      onTap: () async {
                        Navigator.of(sheetContext).pop();
                        _state.setLoading(true);
                        try {
                          final results = await _apiWrapper.search(
                            '', // Empty query to get all results in subcategory
                            categoryId: subcategory.id,
                          );
                          if (!mounted) return;
                          _state.setSearchResults(results.cast<ProwlarrItem>());
                          _state.clearError();
                        } catch (e) {
                          if (!mounted) return;
                          _state.setError(e.toString());
                        } finally {
                          if (mounted) {
                            _state.setLoading(false);
                          }
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(ProwlarrState state) {
    final results = state.filteredAndSortedResults;

    if (results.isEmpty) {
      return ZagMessage(
        text: state.searchResults.isEmpty
            ? 'search.NoResultsFound'.tr()
            : 'No results match your filters',
        buttonText: state.filterConfig.hasActiveFilters ? 'Clear Filters' : null,
        onTap: state.filterConfig.hasActiveFilters ? state.clearFilters : null,
      );
    }

    return ListView.builder(
      padding: MediaQuery.of(context).padding.add(ZagUI.MARGIN_HALF_VERTICAL),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ProwlarrResultTile(
          item: item,
          apiWrapper: _apiWrapper,
        );
      },
    );
  }
}

/// Stateful filter sheet content to manage local filter state
class _FilterSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final ProwlarrState state;
  final VoidCallback onClose;

  const _FilterSheetContent({
    required this.scrollController,
    required this.state,
    required this.onClose,
  });

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
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
          // Header
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
          // Filter content
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Indexer filter
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
                        selectedColor:
                            ZagColours.accentColor(context).withValues(alpha: 0.3),
                        checkmarkColor: ZagColours.accentColor(context),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                // Min seeders filter
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
                // Max age filter
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
          // Apply button
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
