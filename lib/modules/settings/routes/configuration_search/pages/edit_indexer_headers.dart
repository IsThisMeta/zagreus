import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/widgets/pages/invalid_route.dart';

class ConfigurationSearchEditIndexerHeadersRoute extends StatefulWidget {
  final int id;

  const ConfigurationSearchEditIndexerHeadersRoute({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<ConfigurationSearchEditIndexerHeadersRoute> createState() => _State();
}

class _State extends State<ConfigurationSearchEditIndexerHeadersRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagIndexer? _indexer;

  @override
  Widget build(BuildContext context) {
    if (widget.id < 0 || !ZagBox.indexers.contains(widget.id)) {
      return InvalidRoutePage(
        title: 'settings.CustomHeaders'.tr(),
        message: 'search.IndexerNotFound'.tr(),
      );
    }

    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'settings.CustomHeaders'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        ZagButton.text(
          text: 'settings.AddHeader'.tr(),
          icon: Icons.add_rounded,
          onTap: () async => HeaderUtility().addHeader(context,
              headers: _indexer!.headers, indexer: _indexer),
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
            if (_indexer!.headers.isEmpty)
              ZagMessage.inList(text: 'settings.NoHeadersAdded'.tr()),
            ..._list(),
          ],
        );
      },
    );
  }

  List<Widget> _list() {
    final headers = _indexer!.headers.cast<String, dynamic>();
    List<String> _sortedKeys = headers.keys.toList()..sort();
    return _sortedKeys
        .map<ZagBlock>((key) => _headerBlock(key, headers[key]))
        .toList();
  }

  ZagBlock _headerBlock(String key, String? value) {
    return ZagBlock(
      title: key.toString(),
      body: [TextSpan(text: value.toString())],
      trailing: ZagIconButton(
        icon: ZagIcons.DELETE,
        color: ZagColours.red,
        onPressed: () async => HeaderUtility().deleteHeader(
          context,
          headers: _indexer!.headers,
          key: key,
          indexer: _indexer,
        ),
      ),
    );
  }
}
