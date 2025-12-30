import 'package:flutter/material.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules/prowlarr/core.dart';
import 'package:zagreus/modules/prowlarr/routes/subcategories/route.dart';
import 'package:zagreus/modules/prowlarr/routes/search/route.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

export 'subcategories/route.dart';
export 'search/route.dart';

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

class _ProwlarrHomePageState extends State<ProwlarrHomePage>
    with ZagScrollControllerMixin {
  late ProwlarrAPIWrapper _apiWrapper;
  late ProwlarrState _state;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _searchFocusNode = FocusNode();

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
    _searchFocusNode.dispose();
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      if (_searchController.text.isEmpty) {
                        // Dismiss keyboard if text is already empty
                        _searchFocusNode.unfocus();
                      } else {
                        _searchController.clear();
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                onSubmitted: (query) {
                  if (query.isEmpty) return;
                  // Navigate to search page with query
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProwlarrSearchPage(
                        apiWrapper: _apiWrapper,
                        state: _state,
                        categoryId: _state.selectedCategory?.id,
                        categoryName: _state.selectedCategory?.name,
                        initialQuery: query,
                      ),
                    ),
                  );
                  _searchController.clear();
                },
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Consumer<ProwlarrState>(
            builder: (context, state, child) {
              if (state.isLoading) {
                return const ZagLoader();
              }

              if (state.error != null) {
                return ZagMessage.error(
                  onTap: _loadCategories,
                );
              }

              return _buildCategoriesView(state.categories);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesView(List<ProwlarrCategory> categories) {
    if (categories.isEmpty) {
      return ZagMessage(text: 'No categories available');
    }

    return ZagListView(
      controller: scrollController,
      children: categories.map((category) {
        final hasSubcategories = category.subCategories != null &&
                                 category.subCategories!.isNotEmpty;

        return ZagBlock(
          title: category.name ?? 'Unknown',
          body: category.description != null
              ? [TextSpan(text: category.description!)]
              : hasSubcategories
                  ? [TextSpan(text: '${category.subCategories!.length} subcategories')]
                  : null,
          trailing: const ZagIconButton.arrow(),
          onTap: () {
            _state.setSelectedCategory(category);

            if (hasSubcategories) {
              // Navigate to subcategories page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProwlarrSubcategoriesPage(
                    parentCategory: category,
                    apiWrapper: _apiWrapper,
                    state: _state,
                  ),
                ),
              );
            } else {
              // Navigate to search page with this category
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProwlarrSearchPage(
                    apiWrapper: _apiWrapper,
                    state: _state,
                    categoryId: category.id,
                    categoryName: category.name,
                  ),
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }
}
