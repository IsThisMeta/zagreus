import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/search.dart';
import 'package:zagreus/router/routes/search.dart';

class SearchSubcategoryTile extends StatelessWidget {
  final int index;

  const SearchSubcategoryTile({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SearchState, NewznabCategoryData?>(
      selector: (_, state) => state.activeCategory,
      builder: (context, category, _) {
        NewznabSubcategoryData subcategory = category!.subcategories[index];
        return ZagBlock(
          title: subcategory.name ?? 'zagreus.Unknown'.tr(),
          body: [
            TextSpan(
              text: [
                category.name ?? 'zagreus.Unknown'.tr(),
                subcategory.name ?? 'zagreus.Unknown'.tr(),
              ].join(' > '),
            )
          ],
          trailing: ZagIconButton(
            icon: category.icon,
            color: ZagColours().byListIndex(index + 1),
          ),
          onTap: () async {
            context.read<SearchState>().activeSubcategory = subcategory;
            SearchRoutes.RESULTS.go();
          },
        );
      },
    );
  }
}
