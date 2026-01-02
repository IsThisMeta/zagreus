import 'package:flutter/material.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules/search/prowlarr/core.dart';
import 'package:zagreus/modules/search/prowlarr/routes/subcategories/route.dart';
import 'package:zagreus/modules/search/prowlarr/routes/search/route.dart';
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
                Text(
                  'search.ProwlarrProFeatureMessage'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
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
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                // Clear any previously selected category for global search
                _state.setSelectedCategory(null);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProwlarrSearchPage(
                      apiWrapper: _apiWrapper,
                      state: _state,
                    ),
                  ),
                );
              },
            ),
          ],
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
      return ZagMessage(text: 'search.NoCategoriesAvailable'.tr());
    }

    return ZagListView(
      controller: scrollController,
      children: categories.map((category) {
        final hasSubcategories = category.subCategories != null &&
                                 category.subCategories!.isNotEmpty;

        return ZagBlock(
          title: category.name ?? 'zagreus.Unknown'.tr(),
          body: category.description != null
              ? [TextSpan(text: category.description!)]
              : hasSubcategories
                  ? [
                      TextSpan(
                        text: 'search.SubcategoryCount'.tr(
                          args: [category.subCategories!.length.toString()],
                        ),
                      )
                    ]
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
