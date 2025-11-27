import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules/search.dart';
import 'package:zagreus/router/routes/search.dart';
import 'package:zagreus/modules/prowlarr/routes/prowlarr_home.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class SearchIndexerTile extends StatelessWidget {
  final ZagIndexer? indexer;

  const SearchIndexerTile({
    Key? key,
    required this.indexer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: indexer!.displayName,
      body: [TextSpan(text: indexer!.host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        if (indexer!.isProwlarr) {
          // Prowlarr search requires Pro
          if (!ZagreusPro.isEnabled) {
            ZagDialogs().showOkDialog(
              context: context,
              title: 'zagreus.Pro'.tr(),
              content: 'Prowlarr search is a Pro feature. Upgrade to Pro to search with Prowlarr.',
            );
            return;
          }
          // Use the richer Prowlarr UI when the indexer is marked as Prowlarr
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProwlarrHomePage(indexer: indexer!),
            ),
          );
        } else {
          context.read<SearchState>().indexer = indexer!;
          SearchRoutes.CATEGORIES.go();
        }
      },
    );
  }
}
