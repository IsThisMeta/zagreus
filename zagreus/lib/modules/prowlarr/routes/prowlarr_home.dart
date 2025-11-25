import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules/prowlarr/core.dart';
import 'package:zagreus/core.dart';

/// Prowlarr home page - main search interface
class ProwlarrHomePage extends StatefulWidget {
  final ZagIndexer indexer;

  const ProwlarrHomePage({
    Key? key,
    required this.indexer,
  }) : super(key: key);

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
      _state.setCategories(categories.cast<ProwlarrCategory>());
      _state.clearError();
    } catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
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
      _state.setSearchResults(results.cast<ProwlarrItem>());
      _state.clearError();
    } catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            IconButton(
              icon: const Icon(Icons.history_rounded),
              tooltip: 'Search History',
              onPressed: _showSearchHistorySheet,
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
        body: Consumer<ProwlarrState>(
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

            return _buildSearchResults(state.searchResults);
          },
        ),
      ),
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

  Widget _buildSearchResults(List<ProwlarrItem> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text('No results found'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(
              item.title ?? 'Unknown',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Indexer: ${item.indexer ?? 'Unknown'}'),
                Text('Size: ${_formatBytes(item.size ?? 0)}'),
                if (item.seeders != null)
                  Text('Seeds: ${item.seeders} | Leechers: ${item.leechers ?? 0}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
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
          ),
        );
      },
    );
  }

  void _showSearchHistorySheet() {
    // Get explicit background color based on theme mode
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
        return ListenableBuilder(
          listenable: _state,
          builder: (context, child) {
            final history = _state.searchHistory;
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Search History',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (history.isNotEmpty)
                          TextButton(
                            onPressed: _state.clearSearchHistory,
                            child: const Text('Clear All'),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: history.isEmpty
                        ? const Center(child: Text('No history yet'))
                        : ListView.separated(
                            itemCount: history.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final query = history[index];
                              return ListTile(
                                title: Text(query),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      _state.removeSearchFromHistory(query),
                                ),
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  _searchController.text = query;
                                  _performSearch(query);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
