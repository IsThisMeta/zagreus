import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/duration/timestamp.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliMediaDetailsMetadataMetadata extends StatelessWidget {
  final TautulliMetadata? metadata;

  const TautulliMediaDetailsMetadataMetadata({
    Key? key,
    required this.metadata,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      content: [
        if (metadata!.originallyAvailableAt != null &&
            metadata!.originallyAvailableAt!.isNotEmpty)
          ZagTableContent(
            title: 'released',
            body: metadata!.originallyAvailableAt,
          ),
        if (metadata!.addedAt != null)
          ZagTableContent(
            title: 'added',
            body: metadata!.addedAt!.asPoleDate(),
          ),
        if (metadata!.duration != null)
          ZagTableContent(
            title: 'duration',
            body: metadata!.duration!.asNumberTimestamp(),
          ),
        if (metadata?.mediaInfo?.isNotEmpty ?? false)
          ZagTableContent(
            title: 'bitrate',
            body:
                '${metadata!.mediaInfo![0].bitrate ?? ZagUI.TEXT_EMDASH} kbps',
          ),
        if (metadata!.rating != null)
          ZagTableContent(
              title: 'rating',
              body: '${(((metadata?.rating ?? 0) * 10).truncate())}%'),
        if (metadata!.studio != null && metadata!.studio!.isNotEmpty)
          ZagTableContent(
            title: 'studio',
            body: metadata!.studio,
          ),
        if (metadata?.genres?.isNotEmpty ?? false)
          ZagTableContent(
            title: 'genres',
            body: metadata!.genres!.take(5).join('\n'),
          ),
        if (metadata?.directors?.isNotEmpty ?? false)
          ZagTableContent(
            title: 'directors',
            body: metadata!.directors!.take(5).join('\n'),
          ),
        if (metadata?.writers?.isNotEmpty ?? false)
          ZagTableContent(
            title: 'writers',
            body: metadata!.writers!.take(5).join('\n'),
          ),
        if (metadata?.actors?.isNotEmpty ?? false)
          ZagTableContent(
            title: 'actors',
            body: metadata!.actors!.take(5).join('\n'),
          ),
      ],
    );
  }
}
