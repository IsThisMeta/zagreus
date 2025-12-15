import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

class RadarrQueueTile extends StatelessWidget {
  final RadarrQueueRecord record;
  final RadarrMovie? movie;

  const RadarrQueueTile({
    Key? key,
    required this.record,
    required this.movie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<RadarrState>().movies,
      builder: (context, AsyncSnapshot<List<RadarrMovie>> snapshot) {
        RadarrMovie? movie;
        if (snapshot.hasData)
          movie = snapshot.data!.firstWhereOrNull(
            (element) => element.id == record.movieId,
          );
        return ZagExpandableListTile(
          title: record.title ?? movie?.title ?? ZagUI.TEXT_EMDASH,
          collapsedSubtitles: [
            _subtitle1(movie),
            _subtitle2(),
          ],
          expandedHighlightedNodes: _highlightedNodes(),
          expandedTableContent: _tableContent(movie),
          expandedTableButtons: _tableButtons(context),
          collapsedTrailing: ZagIconButton(
            icon: record.zagStatusIcon,
            color: record.zagStatusColor,
          ),
          onLongPress: record.movieId != null
              ? () => RadarrRoutes.MOVIE.go(params: {
                    'movie': record.movieId!.toString(),
                  })
              : null,
        );
      },
    );
  }

  TextSpan _subtitle1(RadarrMovie? movie) {
    final text = movie != null
        ? record.zagMovieTitle(movie)
        : (record.title ?? ZagUI.TEXT_EMDASH);
    return TextSpan(text: text);
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(
          text: record.zagQuality,
          style: TextStyle(
            color: ZagColours.currentAccent,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: record.timeLeft ?? ZagUI.TEXT_EMDASH),
      ],
    );
  }

  List<ZagTableContent> _tableContent(RadarrMovie? movie) {
    final sizeText = record.size != null
        ? record.size!.toInt().asBytes()
        : ZagUI.TEXT_EMDASH;
    final remainingText = record.sizeLeft != null
        ? record.sizeLeft!.toInt().asBytes()
        : ZagUI.TEXT_EMDASH;
    final timeLeft = record.timeLeft ?? ZagUI.TEXT_EMDASH;

    return [
      if (movie != null)
        ZagTableContent(
            title: 'radarr.Movie'.tr(), body: record.zagMovieTitle(movie)),
      ZagTableContent(
          title: 'radarr.Languages'.tr(), body: record.zagLanguage),
      ZagTableContent(title: 'Client', body: record.zagDownloadClient),
      ZagTableContent(title: 'Indexer', body: record.zagIndexer),
      ZagTableContent(title: 'radarr.Size'.tr(), body: sizeText),
      ZagTableContent(title: 'Remaining', body: remainingText),
      ZagTableContent(title: 'Time Left', body: timeLeft),
    ];
  }

  List<ZagHighlightedNode> _highlightedNodes() {
    return [
      ZagHighlightedNode(
        text: record.protocol?.readable ?? ZagUI.TEXT_EMDASH,
        backgroundColor: ZagColours.blue,
      ),
      ZagHighlightedNode(
        text: record.zagQuality,
        backgroundColor: ZagColours.currentAccent,
      ),
      if ((record.customFormats?.length ?? 0) != 0)
        for (int i = 0; i < record.customFormats!.length; i++)
          ZagHighlightedNode(
            text: record.customFormats![i].name!,
            backgroundColor: ZagColours.orange,
          ),
      ZagHighlightedNode(
        text: '${record.zagPercentageComplete}%',
        backgroundColor: ZagColours.blueGrey,
      ),
      ZagHighlightedNode(
        text: record.status?.readable ?? ZagUI.TEXT_EMDASH,
        backgroundColor: ZagColours.blueGrey,
      ),
    ];
  }

  List<ZagButton> _tableButtons(BuildContext context) {
    return [
      if ((record.statusMessages ?? []).isNotEmpty)
        ZagButton.text(
          icon: Icons.messenger_outline_rounded,
          color: ZagColours.orange,
          text: 'Messages',
          onTap: () async {
            ZagDialogs().showMessages(
              context,
              record.statusMessages!
                  .map<String>((status) => status.messages!.join('\n'))
                  .toList(),
            );
          },
        ),
      if (record.status == RadarrQueueRecordStatus.COMPLETED &&
          record.trackedDownloadStatus == RadarrTrackedDownloadStatus.WARNING &&
          (record.outputPath ?? '').isNotEmpty)
        ZagButton.text(
          icon: Icons.download_done_rounded,
          text: 'radarr.Import'.tr(),
          onTap: () => RadarrRoutes.MANUAL_IMPORT_DETAILS.go(queryParams: {
            'path': record.outputPath!,
          }),
        ),
      ZagButton.text(
        icon: Icons.delete_rounded,
        color: ZagColours.red,
        text: 'Remove',
        onTap: () async {
          if (context.read<RadarrState>().enabled) {
            bool result = await RadarrDialogs().confirmDeleteQueue(context);
            if (result) {
              await context
                  .read<RadarrState>()
                  .api!
                  .queue
                  .delete(
                    id: record.id!,
                    blacklist: RadarrDatabase.QUEUE_BLACKLIST.read(),
                    removeFromClient:
                        RadarrDatabase.QUEUE_REMOVE_FROM_CLIENT.read(),
                  )
                  .then((_) {
                showZagSuccessSnackBar(
                  title: 'Removed From Queue',
                  message: record.title,
                );
                context
                    .read<RadarrState>()
                    .api!
                    .command
                    .refreshMonitoredDownloads()
                    .then((_) => context.read<RadarrState>().fetchQueue());
              }).catchError((error, stack) {
                ZagLogger().error(
                    'Failed to remove queue record: ${record.id}',
                    error,
                    stack);
                showZagErrorSnackBar(
                  title: 'Failed to Remove',
                  error: error,
                );
              });
            }
          }
        },
      ),
    ];
  }
}
