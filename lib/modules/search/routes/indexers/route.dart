import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/search.dart';
import 'package:zagreus/modules/search/prowlarr/routes/prowlarr_home.dart';
import 'package:zagreus/router/routes/search.dart';
import 'package:zagreus/utils/zagreus_pro.dart';
import 'package:zagreus/database/models/indexer.dart';

class SearchRoute extends StatefulWidget {
  const SearchRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchRoute> createState() => _State();
}

class _State extends State<SearchRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      drawer: _drawer(),
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      useDrawer: true,
      title: ZagModule.SEARCH.title,
      scrollControllers: [scrollController],
    );
  }

  Widget _drawer() => ZagDrawer(page: ZagModule.SEARCH.key);

  Widget _body() {
    final allIndexers = ZagBox.indexers.data.toList();
    final availableIndexers = allIndexers.where((indexer) {
      if (!ZagreusPro.isEnabled && indexer.isProwlarr) {
        return false;
      }
      return true;
    }).toList();

    if (availableIndexers.isEmpty) {
      final hasProwlarrOnly =
          allIndexers.isNotEmpty && allIndexers.every((i) => i.isProwlarr);

      if (hasProwlarrOnly && !ZagreusPro.isEnabled) {
        return ZagMessage(
          text: 'search.ProwlarrProRequiredMessage'.tr(),
        );
      }

      return ZagMessage.moduleNotEnabled(
        context: context,
        module: ZagModule.SEARCH.title,
      );
    }

    // If only one indexer is available, go directly to it
    if (availableIndexers.length == 1) {
      final singleIndexer = availableIndexers.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final searchState = context.read<SearchState>();
        searchState.isSingleIndexerMode = true;
        if (singleIndexer.isProwlarr) {
          // Prowlarr search requires Pro - should already be filtered but check just in case
          if (ZagreusPro.isEnabled) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ProwlarrHomePage(indexer: singleIndexer),
              ),
            );
          }
        } else {
          searchState.indexer = singleIndexer;
          SearchRoutes.CATEGORIES.go();
        }
      });
      // Return empty container while navigation happens
      return const SizedBox.shrink();
    }

    return ZagListView(
      controller: scrollController,
      children: _buildList(availableIndexers),
    );
  }

  List<Widget> _buildList(List<ZagIndexer> indexers) {
    final list = indexers
        .map((indexer) => SearchIndexerTile(indexer: indexer))
        .toList();
    list.sort((a, b) => a.indexer!.displayName
        .toLowerCase()
        .compareTo(b.indexer!.displayName.toLowerCase()));

    return list;
  }
}
