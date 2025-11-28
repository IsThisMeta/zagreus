import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationSearchAddProwlarrRoute extends StatefulWidget {
  const ConfigurationSearchAddProwlarrRoute({Key? key}) : super(key: key);

  @override
  State<ConfigurationSearchAddProwlarrRoute> createState() => _State();
}

class _State extends State<ConfigurationSearchAddProwlarrRoute>
    with ZagScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ZagIndexer _indexer =
      ZagIndexer(displayName: 'Prowlarr', isProwlarr: true);

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'search.AddProwlarr'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        ZagButton.text(
          text: 'search.AddProwlarr'.tr(),
          icon: Icons.add_rounded,
          onTap: () async {
            if (_indexer.host.isEmpty || _indexer.apiKey.isEmpty) {
              showZagErrorSnackBar(
                title: 'search.FailedToAddIndexer'.tr(),
                message: 'settings.AllFieldsAreRequired'.tr(),
              );
              return;
            }
            await ZagBox.indexers.create(_indexer);
            showZagSuccessSnackBar(
              title: 'search.IndexerAdded'.tr(),
              message: _indexer.displayName,
            );
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        _displayName(),
        _apiURL(),
        _apiKey(),
        _headers(),
      ],
    );
  }

  Widget _displayName() {
    final name = _indexer.displayName;
    return ZagBlock(
      title: 'settings.DisplayName'.tr(),
      body: [TextSpan(text: name.isEmpty ? 'zagreus.NotSet'.tr() : name)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final values = await ZagDialogs().editText(
          context,
          'settings.DisplayName'.tr(),
          prefill: name,
        );
        if (values.item1 && mounted) {
          setState(() => _indexer.displayName = values.item2);
        }
      },
    );
  }

  Widget _apiURL() {
    final host = _indexer.host;
    return ZagBlock(
      title: 'search.ProwlarrURL'.tr(),
      body: [TextSpan(text: host.isEmpty ? 'zagreus.NotSet'.tr() : host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final values = await ZagDialogs().editText(
          context,
          'search.ProwlarrURL'.tr(),
          prefill: host,
        );
        if (values.item1 && mounted) {
          setState(() => _indexer.host = values.item2);
        }
      },
    );
  }

  Widget _apiKey() {
    final key = _indexer.apiKey;
    return ZagBlock(
      title: 'search.ProwlarrAPIKey'.tr(),
      body: [TextSpan(text: key.isEmpty ? 'zagreus.NotSet'.tr() : key)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        final values = await ZagDialogs().editText(
          context,
          'search.ProwlarrAPIKey'.tr(),
          prefill: key,
        );
        if (values.item1 && mounted) {
          setState(() => _indexer.apiKey = values.item2);
        }
      },
    );
  }

  Widget _headers() {
    return ZagBlock(
      title: 'settings.CustomHeaders'.tr(),
      body: [TextSpan(text: 'settings.CustomHeadersDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: () => SettingsRoutes.CONFIGURATION_SEARCH_ADD_INDEXER_HEADERS.go(
        extra: _indexer,
      ),
    );
  }
}
