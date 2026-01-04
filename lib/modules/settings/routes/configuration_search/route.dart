import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules/search/core.dart';
import 'package:zagreus/router/routes/settings.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ConfigurationSearchRoute extends StatefulWidget {
  const ConfigurationSearchRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfigurationSearchRoute> createState() => _State();
}

class _State extends State<ConfigurationSearchRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'search.Search'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomNavigationBar() {
    final isPro = ZagreusPro.isEnabled;
    return ZagBottomActionBar(
      actions: [
        ZagButton.text(
          text: 'search.AddProwlarr'.tr(),
          icon: isPro ? Icons.travel_explore_rounded : Icons.lock_rounded,
          onTap: isPro
              ? SettingsRoutes.CONFIGURATION_SEARCH_ADD_PROWLARR.go
              : () => _showProUpgradeToast('search.AddProwlarr'.tr()),
        ),
        ZagButton.text(
          text: 'search.AddIndexer'.tr(),
          icon: Icons.add_rounded,
          onTap: SettingsRoutes.CONFIGURATION_SEARCH_ADD_INDEXER.go,
        ),
      ],
    );
  }

  Widget _body() {
    return ZagBox.indexers.listenableBuilder(
      builder: (context, _) => ZagListView(
        controller: scrollController,
        children: [
          ZagModule.SEARCH.informationBanner(),
          ..._indexerSection(),
          ..._customization(),
        ],
      ),
    );
  }

  List<Widget> _indexerSection() {
    if (ZagBox.indexers.isEmpty) {
      return [ZagMessage(text: 'search.NoIndexersFound'.tr())];
    }
    return _indexers;
  }

  List<Widget> get _indexers {
    List<ZagIndexer> indexers = ZagBox.indexers.data.toList();
    indexers.sort((a, b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    List<ZagBlock> list = List.generate(
      indexers.length,
      (index) =>
          _indexerTile(indexers[index], indexers[index].key) as ZagBlock,
    );
    return list;
  }

  Widget _indexerTile(ZagIndexer indexer, int index) {
    return ZagBlock(
      title: indexer.displayName,
      body: [TextSpan(text: indexer.host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () => SettingsRoutes.CONFIGURATION_SEARCH_EDIT_INDEXER.go(
        params: {
          'id': index.toString(),
        },
      ),
    );
  }

  List<Widget> _customization() {
    return [
      ZagDivider(),
      _hideAdultCategories(),
      _showLinks(),
    ];
  }

  Widget _hideAdultCategories() {
    const _db = SearchDatabase.HIDE_XXX;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'search.HideAdultCategories'.tr(),
        body: [TextSpan(text: 'search.HideAdultCategoriesDescription'.tr())],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }

  Widget _showLinks() {
    const _db = SearchDatabase.SHOW_LINKS;
    return _db.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'search.ShowLinks'.tr(),
        body: [TextSpan(text: 'search.ShowLinksDescription'.tr())],
        trailing: ZagSwitch(
          value: _db.read(),
          onChanged: _db.update,
        ),
      ),
    );
  }

  void _showProUpgradeToast(String featureName) {
    showZagInfoSnackBar(
      title: 'settings.ZagreusProRequiredTitle'.tr(),
      message: 'settings.ZagreusProRequiredMessage'.tr(
        args: [featureName],
      ),
    );
  }
}
