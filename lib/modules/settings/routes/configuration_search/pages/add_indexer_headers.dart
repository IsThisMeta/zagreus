import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/indexer.dart';
import 'package:zagreus/modules/settings.dart';
import 'package:zagreus/widgets/pages/invalid_route.dart';

class ConfigurationSearchAddIndexerHeadersRoute extends StatefulWidget {
  final ZagIndexer? indexer;

  const ConfigurationSearchAddIndexerHeadersRoute({
    Key? key,
    required this.indexer,
  }) : super(key: key);

  @override
  State<ConfigurationSearchAddIndexerHeadersRoute> createState() => _State();
}

class _State extends State<ConfigurationSearchAddIndexerHeadersRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (widget.indexer == null) {
      return InvalidRoutePage(
        title: 'settings.CustomHeaders'.tr(),
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
          onTap: () async {
            await HeaderUtility()
                .addHeader(context, headers: widget.indexer!.headers);
            if (mounted) setState(() {});
          },
        ),
      ],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        if (widget.indexer!.headers.isEmpty)
          ZagMessage.inList(text: 'settings.NoHeadersAdded'.tr()),
        ..._list(),
      ],
    );
  }

  List<Widget> _list() {
    final headers = widget.indexer!.headers.cast<String, dynamic>();
    List<String> _sortedKeys = headers.keys.toList()..sort();
    return _sortedKeys
        .map<ZagBlock>((key) => _headerTile(key, headers[key]))
        .toList();
  }

  ZagBlock _headerTile(String key, String? value) {
    return ZagBlock(
      title: key.toString(),
      body: [TextSpan(text: value.toString())],
      trailing: ZagIconButton(
        icon: ZagIcons.DELETE,
        color: ZagColours.red,
        onPressed: () async {
          await HeaderUtility().deleteHeader(
            context,
            headers: widget.indexer!.headers,
            key: key,
          );
          if (mounted) setState(() {});
        },
      ),
    );
  }
}
