import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/sabnzbd.dart';
import 'package:zagreus/router/routes/sabnzbd.dart';

class SABnzbdHistoryTile extends StatefulWidget {
  final SABnzbdHistoryData data;
  final Function() refresh;

  const SABnzbdHistoryTile({
    Key? key,
    required this.data,
    required this.refresh,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SABnzbdHistoryTile> {
  @override
  Widget build(BuildContext context) {
    return ZagExpandableListTile(
      title: widget.data.name,
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      expandedTableContent: _expandedTableContent(),
      expandedHighlightedNodes: _expandedHighlightedNodes(),
      expandedTableButtons: _expandedButtons(),
      onLongPress: () async => _handlePopup(),
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(children: [
      TextSpan(text: widget.data.completeTimeString),
      TextSpan(text: ZagUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.data.sizeReadable),
      TextSpan(text: ZagUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.data.category),
    ]);
  }

  TextSpan _subtitle2() {
    return TextSpan(
      text: widget.data.statusString,
      style: TextStyle(
        color: widget.data.statusColor,
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
      ),
    );
  }

  List<ZagTableContent> _expandedTableContent() {
    return [
      ZagTableContent(title: 'age', body: widget.data.completeTimeString),
      ZagTableContent(title: 'size', body: widget.data.sizeReadable),
      ZagTableContent(title: 'category', body: widget.data.category),
      ZagTableContent(title: 'path', body: widget.data.storageLocation),
    ];
  }

  List<ZagHighlightedNode> _expandedHighlightedNodes() {
    return [
      ZagHighlightedNode(
        text: widget.data.status,
        backgroundColor: widget.data.statusColor,
      ),
    ];
  }

  List<ZagButton> _expandedButtons() {
    return [
      ZagButton.text(
        text: 'Stages',
        icon: Icons.subject_rounded,
        onTap: () async => _enterStages(),
      ),
      ZagButton.text(
        text: 'Delete',
        icon: Icons.delete_rounded,
        color: ZagColours.red,
        onTap: () async => _delete(),
      ),
    ];
  }

  Future<void> _enterStages() async {
    return SABnzbdRoutes.HISTORY_STAGES.go(
      extra: widget.data,
    );
  }

  Future<void> _handlePopup() async {
    List values = await SABnzbdDialogs.historySettings(
        context, widget.data.name, widget.data.failed);
    if (values[0])
      switch (values[1]) {
        case 'retry':
          _retry();
          break;
        case 'password':
          _password();
          break;
        case 'delete':
          _delete();
          break;
        default:
          ZagLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  Future<void> _delete() async {
    List values = await SABnzbdDialogs.deleteHistory(context);
    if (values[0]) {
      SABnzbdAPI.from(ZagProfile.current)
          .deleteHistory(widget.data.nzoId)
          .then((_) => _handleRefresh('History Deleted'))
          .catchError((error) => showZagErrorSnackBar(
                title: 'Failed to Delete History',
                error: error,
              ));
    }
  }

  Future<void> _password() async {
    List values = await SABnzbdDialogs.setPassword(context);
    if (values[0])
      SABnzbdAPI.from(ZagProfile.current)
          .retryFailedJobPassword(widget.data.nzoId, values[1])
          .then((_) => _handleRefresh('Password Set / Retrying...'))
          .catchError((error) => showZagErrorSnackBar(
                title: 'Failed to Set Password / Retry Job',
                error: error,
              ));
  }

  Future<void> _retry() async {
    SABnzbdAPI.from(ZagProfile.current)
        .retryFailedJob(widget.data.nzoId)
        .then((_) => _handleRefresh('Retrying Job'))
        .catchError((error) => showZagErrorSnackBar(
              title: 'Failed to Retry Job',
              error: error,
            ));
  }

  void _handleRefresh(String title) {
    showZagSuccessSnackBar(
      title: title,
      message: widget.data.name,
    );
    widget.refresh();
  }
}
