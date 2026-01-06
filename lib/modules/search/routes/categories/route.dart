import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/search.dart';
import 'package:zagreus/router/routes/search.dart';

class CategoriesRoute extends StatefulWidget {
  const CategoriesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<CategoriesRoute> createState() => _State();
}

class _State extends State<CategoriesRoute>
    with ZagLoadCallbackMixin, ZagScrollControllerMixin {
  static const ADULT_CATEGORIES = ['xxx', 'adult', 'porn'];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Future<void> loadCallback() async {
    context.read<SearchState>().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final isSingleIndexerMode = context.read<SearchState>().isSingleIndexerMode;
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(isSingleIndexerMode) as PreferredSizeWidget?,
      drawer: isSingleIndexerMode ? ZagDrawer(page: ZagModule.SEARCH.key) : null,
      body: _body(),
    );
  }

  Widget _appBar(bool useDrawer) {
    return ZagAppBar(
      useDrawer: useDrawer,
      title: context.read<SearchState>().indexer.displayName,
      scrollControllers: [scrollController],
      actions: <Widget>[
        ZagIconButton(
          icon: Icons.search_rounded,
          onPressed: _enterSearch,
        ),
      ],
    );
  }

  Widget _body() {
    final categoriesFuture = context.watch<SearchState>().categories;
    
    // If categories future is null, the indexer might not be properly configured
    if (categoriesFuture == null) {
      return ZagMessage.error(
        onTap: () {
          context.read<SearchState>().fetchCategories();
        },
      );
    }
    
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: loadCallback,
      child: FutureBuilder(
        future: categoriesFuture,
        builder: (context, AsyncSnapshot<List<NewznabCategoryData>> snapshot) {
          if (snapshot.hasError) {
            ZagLogger().error(
              'Unable to fetch categories',
              snapshot.error,
              snapshot.stackTrace,
            );
            return ZagMessage.error(onTap: () {
              context.read<SearchState>().fetchCategories();
            });
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) return _list(snapshot.data!);
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _list(List<NewznabCategoryData> categories) {
    if (categories.isEmpty) {
      return ZagMessage.goBack(
        context: context,
        text: 'search.NoCategoriesFound'.tr(),
      );
    }
    List<NewznabCategoryData> filtered = _filter(categories);
    return ZagListViewBuilder(
      controller: scrollController,
      itemCount: filtered.length,
      itemBuilder: (context, index) => SearchCategoryTile(
        category: filtered[index],
        index: index,
      ),
    );
  }

  List<NewznabCategoryData> _filter(List<NewznabCategoryData> categories) {
    return categories.where((category) {
      if (!SearchDatabase.HIDE_XXX.read()) return true;
      if (category.id >= 6000 && category.id <= 6999) return false;
      if (ADULT_CATEGORIES.contains(category.name!.toLowerCase().trim())) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _enterSearch() async {
    context.read<SearchState>().activeCategory = null;
    context.read<SearchState>().activeSubcategory = null;
    SearchRoutes.SEARCH.go();
  }
}
