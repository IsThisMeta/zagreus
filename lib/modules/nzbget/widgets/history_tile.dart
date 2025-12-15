import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/nzbget.dart';

class NZBGetHistoryTile extends StatefulWidget {
  final NZBGetHistoryData data;
  final Function() refresh;

  const NZBGetHistoryTile({
    Key? key,
    required this.data,
    required this.refresh,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<NZBGetHistoryTile> {
  @override
  Widget build(BuildContext context) {
    return ZagExpandableListTile(
      title: widget.data.name,
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      expandedHighlightedNodes: _expandedHighlightedNodes(),
      expandedTableContent: _expandedTableContent(),
      expandedTableButtons: _expandedTableButtons(),
      onLongPress: () async => _handlePopup(),
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        TextSpan(text: widget.data.completeTime),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.data.sizeReadable),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(
            text: (widget.data.category ?? '').isEmpty
                ? 'No Category'
                : widget.data.category),
      ],
    );
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

  List<ZagHighlightedNode> _expandedHighlightedNodes() {
    return [
      ZagHighlightedNode(
        text: widget.data.statusString,
        backgroundColor: widget.data.statusColor,
      ),
      ZagHighlightedNode(
        text: widget.data.healthString,
        backgroundColor: ZagColours.blueGrey,
      )
    ];
  }

  List<ZagTableContent> _expandedTableContent() {
    return [
      ZagTableContent(title: 'age', body: widget.data.completeTime),
      ZagTableContent(title: 'size', body: widget.data.sizeReadable),
      ZagTableContent(
          title: 'category',
          body: (widget.data.category ?? '').isEmpty
              ? 'No Category'
              : widget.data.category),
      ZagTableContent(title: 'speed', body: widget.data.downloadSpeed),
      ZagTableContent(title: 'path', body: widget.data.storageLocation),
    ];
  }

  List<ZagButton> _expandedTableButtons() {
    return [
      ZagButton.text(
        text: 'Delete',
        icon: Icons.delete_rounded,
        color: ZagColours.red,
        onTap: () async => _deleteButton(),
      ),
    ];
  }

  Future<void> _handlePopup() async {
    List values =
        await NZBGetDialogs.historySettings(context, widget.data.name);
    if (values[0])
      switch (values[1]) {
        case 'retry':
          {
            await NZBGetAPI.from(ZagProfile.current)
                .retryHistoryEntry(widget.data.id)
                .then((_) {
              widget.refresh();
              showZagSuccessSnackBar(
                title: 'Retrying Job...',
                message: widget.data.name,
              );
            }).catchError((error) {
              showZagErrorSnackBar(
                title: 'Failed to Retry Job',
                error: error,
              );
            });
            break;
          }
        case 'hide':
          await NZBGetAPI.from(ZagProfile.current)
              .deleteHistoryEntry(widget.data.id, hide: true)
              .then((_) => _handleDelete('History Hidden'))
              .catchError((error) => showZagErrorSnackBar(
                    title: 'Failed to Hide History',
                    error: error,
                  ));
          break;
        case 'delete':
          await NZBGetAPI.from(ZagProfile.current)
              .deleteHistoryEntry(widget.data.id, hide: true)
              .then((_) => _handleDelete('History Deleted'))
              .catchError((error) => showZagErrorSnackBar(
                    title: 'Failed to Delete History',
                    error: error,
                  ));
      }
  }

  Future<void> _deleteButton() async {
    List<dynamic> values = await NZBGetDialogs.deleteHistory(context);
    if (values[0])
      await NZBGetAPI.from(ZagProfile.current)
          .deleteHistoryEntry(
            widget.data.id,
            hide: values[1],
          )
          .then((_) =>
              _handleDelete(values[1] ? 'History Hidden' : 'History Deleted'))
          .catchError((error) => showZagErrorSnackBar(
                title: 'Failed to Delete History',
                error: error,
              ));
  }

  void _handleDelete(String title) {
    showZagSuccessSnackBar(
      title: title,
      message: widget.data.name,
    );
    widget.refresh();
  }
}
