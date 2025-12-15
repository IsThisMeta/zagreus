import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/widgets/pages/invalid_route.dart';
import 'package:zagreus/router/routes/settings.dart';

class ConfigurationSearchEditIndexerRoute extends StatefulWidget {
  final int id;

  const ConfigurationSearchEditIndexerRoute({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<ConfigurationSearchEditIndexerRoute> createState() => _State();
}

class _State extends State<ConfigurationSearchEditIndexerRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagIndexer? _indexer;

  @override
  Widget build(BuildContext context) {
    if (widget.id < 0 || !ZagBox.indexers.contains(widget.id)) {
      return InvalidRoutePage(
        title: 'search.EditIndexer'.tr(),
        message: 'search.IndexerNotFound'.tr(),
      );
    }

    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'search.EditIndexer'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        ZagButton.text(
          text: 'search.DeleteIndexer'.tr(),
          icon: Icons.delete_rounded,
          color: ZagColours.red,
          onTap: () async {
            bool result = await SettingsDialogs().deleteIndexer(context);
            if (result) {
              showZagSuccessSnackBar(
                title: 'search.IndexerDeleted'.tr(),
                message: _indexer!.displayName,
              );
              _indexer!.delete();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _body() {
    return ZagBox.indexers.listenableBuilder(
      selectKeys: [widget.id],
      builder: (context, _) {
        if (!ZagBox.indexers.contains(widget.id)) return Container();
        _indexer = ZagBox.indexers.read(widget.id);
        return ZagListView(
          controller: scrollController,
          children: [
            _displayName(),
            _apiURL(),
            _apiKey(),
            _headers(),
          ],
        );
      },
    );
  }

  Widget _displayName() {
    String _name = _indexer!.displayName;
    return ZagBlock(
      title: 'settings.DisplayName'.tr(),
      body: [TextSpan(text: _name.isEmpty ? 'zagreus.NotSet'.tr() : _name)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> values = await ZagDialogs().editText(
          context,
          'settings.DisplayName'.tr(),
          prefill: _indexer!.displayName,
        );
        if (values.item1) {
          _indexer!.displayName = values.item2;
        }
        _indexer!.save();
      },
    );
  }

  Widget _apiURL() {
    String _host = _indexer!.host;
    return ZagBlock(
      title: 'search.IndexerAPIHost'.tr(),
      body: [TextSpan(text: _host.isEmpty ? 'zagreus.NotSet'.tr() : _host)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> values = await ZagDialogs().editText(
          context,
          'search.IndexerAPIHost'.tr(),
          prefill: _host,
        );
        if (values.item1 && mounted) {
          _indexer!.host = values.item2;
        }
        _indexer!.save();
      },
    );
  }

  Widget _apiKey() {
    String _key = _indexer!.apiKey;
    return ZagBlock(
      title: 'search.IndexerAPIKey'.tr(),
      body: [TextSpan(text: _key.isEmpty ? 'zagreus.NotSet'.tr() : _key)],
      trailing: const ZagIconButton.arrow(),
      onTap: () async {
        Tuple2<bool, String> values = await ZagDialogs().editText(
          context,
          'search.IndexerAPIKey'.tr(),
          prefill: _key,
        );
        if (values.item1) {
          _indexer!.apiKey = values.item2;
        }
        _indexer!.save();
      },
    );
  }

  Widget _headers() {
    return ZagBlock(
      title: 'settings.CustomHeaders'.tr(),
      body: [TextSpan(text: 'settings.CustomHeadersDescription'.tr())],
      trailing: const ZagIconButton.arrow(),
      onTap: () => SettingsRoutes.CONFIGURATION_SEARCH_EDIT_INDEXER_HEADERS.go(
        params: {
          'id': widget.id.toString(),
        },
      ),
    );
  }
}
