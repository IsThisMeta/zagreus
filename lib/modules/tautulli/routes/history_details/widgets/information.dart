import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/duration/timestamp.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliHistoryDetailsInformation extends StatelessWidget {
  final TautulliHistoryRecord history;
  final ScrollController scrollController;

  const TautulliHistoryDetailsInformation({
    Key? key,
    required this.history,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagListView(
      controller: scrollController,
      children: [
        const ZagHeader(text: 'Metadata'),
        _metadataBlock(),
        const ZagHeader(text: 'Session'),
        _sessionBlock(),
        const ZagHeader(text: 'Player'),
        _playerBlock(),
      ],
    );
  }

  Widget _metadataBlock() {
    return ZagTableCard(
      content: [
        ZagTableContent(title: 'status', body: history.lsStatus),
        ZagTableContent(title: 'title', body: history.lsFullTitle),
        if (history.year != null)
          ZagTableContent(title: 'year', body: history.year.toString()),
        ZagTableContent(title: 'user', body: history.friendlyName),
      ],
    );
  }

  Widget _sessionBlock() {
    return ZagTableCard(
      content: [
        ZagTableContent(title: 'state', body: history.lsState),
        ZagTableContent(
            title: 'date',
            body: DateFormat('yyyy-MM-dd').format(history.date!)),
        ZagTableContent(title: 'started', body: history.date!.asTimeOnly()),
        ZagTableContent(
            title: 'stopped',
            body: history.state == null
                ? history.stopped!.asTimeOnly()
                : ZagUI.TEXT_EMDASH),
        ZagTableContent(
            title: 'paused', body: history.pausedCounter!.asWordsTimestamp()),
      ],
    );
  }

  Widget _playerBlock() {
    return ZagTableCard(
      content: [
        ZagTableContent(title: 'location', body: history.ipAddress),
        ZagTableContent(title: 'platform', body: history.platform),
        ZagTableContent(title: 'product', body: history.product),
        ZagTableContent(title: 'player', body: history.player),
      ],
    );
  }
}
