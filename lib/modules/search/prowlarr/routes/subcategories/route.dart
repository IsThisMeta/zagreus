import 'package:flutter/material.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/search/prowlarr/core.dart';
import 'package:zagreus/modules/search/prowlarr/routes/search/route.dart';

/// Prowlarr subcategories page - shows subcategories for a parent category
class ProwlarrSubcategoriesPage extends StatefulWidget {
  final ProwlarrCategory parentCategory;
  final ProwlarrAPIWrapper apiWrapper;
  final ProwlarrState state;

  const ProwlarrSubcategoriesPage({
    super.key,
    required this.parentCategory,
    required this.apiWrapper,
    required this.state,
  });

  @override
  State<ProwlarrSubcategoriesPage> createState() => _State();
}

class _State extends State<ProwlarrSubcategoriesPage>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    return ZagAppBar(
      title: widget.parentCategory.name ?? 'search.Subcategories'.tr(),
      scrollControllers: [scrollController],
      actions: [
        ZagIconButton(
          icon: Icons.search_rounded,
          onPressed: () => _navigateToSearch(
            categoryId: widget.parentCategory.id,
            showSearchBar: true,
          ),
        ),
      ],
    );
  }

  Widget _body() {
    final subcategories = widget.parentCategory.subCategories ?? [];

    if (subcategories.isEmpty) {
      return ZagMessage(text: 'search.NoSubcategoriesFound'.tr());
    }

    return ZagListView(
      controller: scrollController,
      children: [
        // "All" option to search entire parent category
        ZagBlock(
          title: 'search.AllSubcategories'.tr(),
          trailing: ZagIconButton(
            icon: widget.parentCategory.icon,
            color: ZagColours().byListIndex(0),
          ),
          onTap: () => _navigateToSearch(categoryId: widget.parentCategory.id),
        ),
        ZagDivider(),
        ...List.generate(subcategories.length, (index) {
          final subcategory = subcategories[index];
          return ZagBlock(
            title: subcategory.name ?? 'zagreus.Unknown'.tr(),
            trailing: ZagIconButton(
              icon: subcategory.icon,
              color: ZagColours().byListIndex(index + 1),
            ),
            onTap: () => _navigateToSearch(categoryId: subcategory.id),
          );
        }),
      ],
    );
  }

  void _navigateToSearch({int? categoryId, bool showSearchBar = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProwlarrSearchPage(
          apiWrapper: widget.apiWrapper,
          state: widget.state,
          categoryId: categoryId,
          categoryName: categoryId == widget.parentCategory.id
              ? widget.parentCategory.name
              : widget.parentCategory.subCategories
                  ?.firstWhere((c) => c.id == categoryId,
                      orElse: () => ProwlarrCategory())
                  .name,
          showSearchBar: showSearchBar,
        ),
      ),
    );
  }
}
