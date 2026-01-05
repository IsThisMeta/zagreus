import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/search.dart';

class SearchResultTile extends StatefulWidget {
  final NewznabResultData data;

  const SearchResultTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile> {
  ZagLoadingState _downloadState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZagExpandableListTile(
      title: widget.data.title,
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      collapsedTrailing: Icon(
        widget.data.categoryIcon,
        color: widget.data.categoryIconColor,
        size: 20,
      ),
      expandedHighlightedNodes: _highlightedNodes(),
      expandedTableContent: _tableContent(),
      expandedTableButtons: _tableButtons(),
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        TextSpan(
          text: 'search.Usenet'.tr(),
          style: TextStyle(
            color: ZagColours.blue,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.data.category),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.data.age),
      ],
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(text: widget.data.size.asBytes()),
        if (widget.data.grabs != null) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(
            text: 'search.GrabsCount'.tr(
              args: [widget.data.grabs.toString()],
            ),
          ),
        ],
      ],
    );
  }

  List<ZagHighlightedNode> _highlightedNodes() {
    return [
      ZagHighlightedNode(
        text: 'search.Usenet'.tr(),
        backgroundColor: ZagColours.blue,
      ),
    ];
  }

  List<ZagTableContent> _tableContent() {
    return [
      ZagTableContent(title: 'search.Age'.tr(), body: widget.data.age),
      ZagTableContent(title: 'search.Size'.tr(), body: widget.data.size.asBytes()),
      ZagTableContent(title: 'search.Category'.tr(), body: widget.data.category),
      ZagTableContent(title: 'search.Protocol'.tr(), body: 'search.Usenet'.tr()),
      if (widget.data.grabs != null)
        ZagTableContent(
          title: 'search.Grabs'.tr(),
          body: '${widget.data.grabs}',
        ),
    ];
  }

  List<ZagButton> _tableButtons() {
    return [
      ZagButton(
        type: ZagButtonType.TEXT,
        text: 'search.Download'.tr(),
        icon: Icons.download_rounded,
        onTap: _sendToClient,
        loadingState: _downloadState,
      ),
      if (widget.data.linkInfo.isNotEmpty)
        ZagButton.text(
          text: 'search.Info'.tr(),
          icon: Icons.info_outline_rounded,
          color: ZagColours.blue,
          onTap: widget.data.linkInfo.openLink,
        ),
      if (widget.data.linkComments.isNotEmpty)
        ZagButton.text(
          text: 'search.Comments'.tr(),
          icon: Icons.comment_outlined,
          color: ZagColours.blueGrey,
          onTap: widget.data.linkComments.openLink,
        ),
    ];
  }

  Future<void> _sendToClient() async {
    setState(() => _downloadState = ZagLoadingState.ACTIVE);

    Tuple2<bool, SearchDownloadType?> result =
        await SearchDialogs().downloadResult(context);

    if (result.item1 && result.item2 != null) {
      try {
        await result.item2!.execute(context, widget.data);
        if (mounted) {
          setState(() => _downloadState = ZagLoadingState.INACTIVE);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _downloadState = ZagLoadingState.ERROR);
        }
      }
    } else {
      // User cancelled
      if (mounted) {
        setState(() => _downloadState = ZagLoadingState.INACTIVE);
      }
    }
  }
}
