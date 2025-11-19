import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';

class SettingsResourcesRoute extends StatefulWidget {
  const SettingsResourcesRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsResourcesRoute> createState() => _State();
}

class _State extends State<SettingsResourcesRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'settings.Resources'.tr(),
      scrollControllers: [scrollController],
    );
  }

  Widget _body() {
    return ZagListView(
      controller: scrollController,
      children: [
        ZagBlock(
          title: 'Reddit',
          body: [TextSpan(text: 'Join the community discussion')],
          trailing: const ZagIconButton(icon: Icons.forum_rounded),
          onTap: () => 'https://reddit.com/r/ZagreusApp'.openLink(),
        ),
        ZagBlock(
          title: 'Discord',
          body: [TextSpan(text: 'Join the community chat')],
          trailing: const ZagIconButton(icon: Icons.chat_rounded),
          onTap: () => 'https://discord.gg/RRv63rVtSt'.openLink(),
        ),
        ZagBlock(
          title: 'GitHub',
          body: [TextSpan(text: 'Source code and issue tracking')],
          trailing: const ZagIconButton(icon: Icons.code_rounded),
          onTap: () => 'https://github.com/isthismeta/zagreus'.openLink(),
        ),
        ZagDivider(),
        ZagBlock(
          title: 'Send Feedback / Get Support',
          body: [TextSpan(text: 'support@zebrra.co')],
          trailing: const ZagIconButton(icon: Icons.mail_rounded),
          onTap: () => 'mailto:support@zebrra.co'.openLink(),
        ),
      ],
    );
  }
}
