import 'package:flutter/material.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules/prowlarr/core.dart';
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
        return ListTile(
          title: Text(category.name ?? 'Unknown'),
          subtitle: category.description != null
              ? Text(category.description!)
              : null,
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            _state.setSelectedCategory(category);
            if (category.subCategories != null &&
                category.subCategories!.isNotEmpty) {
              // Show subcategories
            }
          },
        );
      },
    );
  }

  Widget _buildSearchResults(ProwlarrState state) {
    final results = state.filteredAndSortedResults;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              state.searchResults.isEmpty
                  ? 'No results found'
                  : 'No results match your filters',
              style: const TextStyle(fontSize: 16),
            ),
            if (state.filterConfig.hasActiveFilters) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: state.clearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        // Results count and active sort indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${results.length} result${results.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              if (state.filterConfig.hasActiveFilters) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ZagColours.accentColor(context).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Filtered',
                    style: TextStyle(
                      fontSize: 12,
                      color: ZagColours.accentColor(context),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                state.sortOption.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
        // Results list
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              return _buildResultTile(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultTile(BuildContext context, ProwlarrItem item) {
    final ageText = _formatAge(item.age, item.ageHours);
    final seeders = item.seeders ?? 0;
    final leechers = item.leechers ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              item.title ?? 'Unknown',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            // Indexer and Size row
            Row(
              children: [
                Icon(
                  Icons.dns_rounded,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.indexer ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.storage_rounded,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatBytes(item.size ?? 0),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Stats row: Age, Seeders, Leechers
            Row(
              children: [
                // Age badge
                _buildStatBadge(
                  icon: Icons.schedule_rounded,
                  value: ageText,
                  color: _getAgeColor(item.age),
                ),
                const SizedBox(width: 8),
                // Seeders badge
                _buildStatBadge(
                  icon: Icons.arrow_upward_rounded,
                  value: seeders.toString(),
                  color: _getSeedersColor(seeders),
                  label: 'S',
                ),
                const SizedBox(width: 8),
                // Leechers badge
                _buildStatBadge(
                  icon: Icons.arrow_downward_rounded,
                  value: leechers.toString(),
                  color: Colors.orange,
                  label: 'L',
                ),
                const Spacer(),
                // Download button
                IconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: () async {
                    if (item.guid != null && item.indexerId != null) {
                      final success = await _apiWrapper.downloadToClient(
                        guid: item.guid!,
                        indexerId: item.indexerId!,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Download sent to client'
                                  : 'Failed to send download',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required Color color,
    String? label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          if (label != null) ...[
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 2),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAgeColor(int? age) {
    if (age == null) return Colors.grey;
    if (age <= 1) return Colors.green;
    if (age <= 7) return Colors.blue;
    if (age <= 30) return Colors.orange;
    return Colors.grey;
  }

  Color _getSeedersColor(int seeders) {
    if (seeders >= 50) return Colors.green;
    if (seeders >= 10) return Colors.blue;
    if (seeders >= 1) return Colors.orange;
    return Colors.red;
  }

  String _formatAge(int? days, double? hours) {
    if (days == null) return '?';
    if (days == 0) {
      if (hours != null && hours < 1) return '<1h';
      if (hours != null) return '${hours.round()}h';
      return 'Today';
    }
    if (days == 1) return '1d';
    return '${days}d';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
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
