import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/search.dart';
import 'package:zagreus/router/routes/search.dart';

class SearchSubcategoryAllTile extends StatelessWidget {
  const SearchSubcategoryAllTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SearchState, NewznabCategoryData?>(
      selector: (_, state) => state.activeCategory,
      builder: (context, category, _) => ZagBlock(
        title: 'search.AllSubcategories'.tr(),
        body: [TextSpan(text: category?.name ?? 'zagreus.Unknown'.tr())],
        trailing: ZagIconButton(
            icon: context.read<SearchState>().activeCategory?.icon,
            color: ZagColours().byListIndex(0)),
        onTap: () async {
          context.read<SearchState>().activeSubcategory = null;
          SearchRoutes.RESULTS.go();
        },
      ),
    );
  }
}
