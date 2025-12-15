import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliActivityDetailsPlayerBlock extends StatelessWidget {
  final TautulliSession session;

  const TautulliActivityDetailsPlayerBlock({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      content: [
        ZagTableContent(
            title: 'tautulli.Location'.tr(), body: session.zagIPAddress),
        ZagTableContent(
            title: 'tautulli.Platform'.tr(), body: session.zagPlatform),
        ZagTableContent(
            title: 'tautulli.Product'.tr(), body: session.zagProduct),
        ZagTableContent(
            title: 'tautulli.Player'.tr(), body: session.zagPlayer),
        ZagTableContent(
            title: 'tautulli.Quality'.tr(), body: session.zagQuality),
      ],
    );
  }
}
