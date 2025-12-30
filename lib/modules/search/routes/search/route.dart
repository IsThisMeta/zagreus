import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/search.dart';

class SearchIndexerRoute extends StatefulWidget {
  const SearchIndexerRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SearchIndexerRoute> with ZagScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  final PagingController<int, NewznabResultData> _pagingController =
      PagingController(firstPageKey: 0);
  bool _firstSearched = false;

  @override
  void initState() {
    super.initState();
    context.read<SearchState>().resetQuery();
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
    );
  }

  Future<void> _searchCallback(String value) async {
    if (value.isEmpty) return;
    _pagingController.refresh();
    if (mounted) setState(() => _firstSearched = true);
  }

  Future<void> _fetchPage(int pageKey) async {
    SearchState state = context.read<SearchState>();
    NewznabCategoryData? category = state.activeCategory;
    NewznabSubcategoryData? subcategory = state.activeSubcategory;
    await state.api
        .getResults(
      categoryId: subcategory?.id ?? category?.id,
      query: state.searchQuery,
      offset: pageKey,
    )
        .then((data) {
      if (data.isEmpty) return _pagingController.appendLastPage([]);
      return _pagingController.appendPage(data, pageKey + 1);
    }).catchError((error, stack) {
      ZagLogger().error(
        'Unable to fetch search results page: $pageKey',
        error,
        stack,
      );
      _pagingController.error = error;
    });
  }

  Widget _appBar() {
    String title = context.read<SearchState>().indexer.displayName;
    NewznabCategoryData? category = context.read<SearchState>().activeCategory;
    NewznabSubcategoryData? subcategory =
        context.read<SearchState>().activeSubcategory;
    if (category != null) title = category.name!;
    if (category != null && subcategory != null) {
      title = '$title > ${subcategory.name ?? 'zagreus.Unknown'.tr()}';
    }
    return ZagAppBar(
      title: title,
      scrollControllers: [scrollController],
      bottom: SearchSearchBar(
        submitCallback: _searchCallback,
        scrollController: scrollController,
      ),
    );
  }

  Widget _body() {
    if (_firstSearched)
      return ZagPagedListView<NewznabResultData>(
        refreshKey: _refreshKey,
        pagingController: _pagingController,
        scrollController: scrollController,
        listener: _fetchPage,
        noItemsFoundMessage: 'search.NoResultsFound'.tr(),
        itemBuilder: (context, result, index) => SearchResultTile(data: result),
      );
    return Container();
  }
}
