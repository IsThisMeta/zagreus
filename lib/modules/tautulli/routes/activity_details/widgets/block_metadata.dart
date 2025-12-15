import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliActivityDetailsMetadataBlock extends StatelessWidget {
  final TautulliSession session;

  const TautulliActivityDetailsMetadataBlock({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      content: [
        ZagTableContent(
            title: 'tautulli.Title'.tr(), body: session.zagFullTitle),
        if (session.year != null)
          ZagTableContent(title: 'tautulli.Year'.tr(), body: session.zagYear),
        ZagTableContent(
            title: 'tautulli.Duration'.tr(), body: session.zagDuration),
        ZagTableContent(title: 'tautulli.ETA'.tr(), body: session.zagETA),
        ZagTableContent(
            title: 'tautulli.Library'.tr(), body: session.zagLibraryName),
        ZagTableContent(
            title: 'tautulli.User'.tr(), body: session.zagFriendlyName),
      ],
    );
  }
}
