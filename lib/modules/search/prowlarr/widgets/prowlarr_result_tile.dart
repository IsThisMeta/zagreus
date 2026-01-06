import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/api/prowlarr/models.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/search.dart';

class ProwlarrResultTile extends StatefulWidget {
  final ProwlarrItem item;

  const ProwlarrResultTile({
    required this.item,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ProwlarrResultTile> {
  ZagLoadingState _downloadState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    final showPosters = SearchDatabase.SHOW_POSTERS.read();
    return ZagExpandableListTile(
      title: widget.item.title ?? 'zagreus.Unknown'.tr(),
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      posterUrl: showPosters ? widget.item.posterUrl : null,
      posterPlaceholderIcon: showPosters ? _categoryPlaceholderIcon : null,
      expandedHighlightedNodes: _highlightedNodes(),
      expandedTableContent: _tableContent(),
      expandedTableButtons: _tableButtons(),
    );
  }

  Widget? _categoryIcon() {
    final categories = widget.item.categories;
    if (categories == null || categories.isEmpty) return null;
    return Icon(
      categories.first.icon,
      color: categories.first.iconColor,
      size: 20,
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        TextSpan(
          text: _protocolText,
          style: TextStyle(
            color: _protocolColor,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.item.indexer ?? 'zagreus.Unknown'.tr()),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: _formatAge()),
      ],
    );
  }

  TextSpan _subtitle2() {
    final isTorrent = _isTorrent;
    return TextSpan(
      children: [
        TextSpan(text: _formatSize()),
        if (isTorrent) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(
            text: '${widget.item.seeders ?? 0}',
            style: TextStyle(
              color: _seedersColor,
              fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            ),
          ),
          const TextSpan(text: '/'),
          TextSpan(
            text: '${widget.item.leechers ?? 0}',
            style: const TextStyle(
              color: ZagColours.orange,
            ),
          ),
        ],
        if (!isTorrent && widget.item.grabs != null) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(
            text: 'search.GrabsCount'.tr(
              args: [widget.item.grabs.toString()],
            ),
          ),
        ],
      ],
    );
  }

  List<ZagHighlightedNode> _highlightedNodes() {
    return [
      ZagHighlightedNode(
        text: _protocolText,
        backgroundColor: _protocolColor,
      ),
    ];
  }

  List<ZagTableContent> _tableContent() {
    return [
      ZagTableContent(
        title: 'search.Age'.tr(),
        body: _formatAge(),
      ),
      ZagTableContent(
        title: 'search.Indexer'.tr(),
        body: widget.item.indexer ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'search.Size'.tr(),
        body: _formatSize(),
      ),
      ZagTableContent(
        title: 'search.Protocol'.tr(),
        body: _protocolText,
      ),
      if (_isTorrent) ...[
        ZagTableContent(
          title: 'search.Seeders'.tr(),
          body: '${widget.item.seeders ?? 0}',
        ),
        ZagTableContent(
          title: 'search.Leechers'.tr(),
          body: '${widget.item.leechers ?? 0}',
        ),
      ],
      if (widget.item.grabs != null)
        ZagTableContent(
          title: 'search.Grabs'.tr(),
          body: '${widget.item.grabs}',
        ),
      if (widget.item.files != null)
        ZagTableContent(
          title: 'search.Files'.tr(),
          body: '${widget.item.files}',
        ),
      if (widget.item.categories?.isNotEmpty ?? false)
        ZagTableContent(
          title: 'search.Category'.tr(),
          body: widget.item.categories!
              .map((c) => c.name ?? 'zagreus.Unknown'.tr())
              .join(', '),
        ),
    ];
  }

  List<ZagButton> _tableButtons() {
    return [
      ZagButton(
        type: ZagButtonType.TEXT,
        text: 'search.Download'.tr(),
        icon: Icons.download_rounded,
        onTap: _startDownload,
        loadingState: _downloadState,
      ),
      if (widget.item.infoUrl?.isNotEmpty ?? false)
        ZagButton.text(
          text: 'search.Info'.tr(),
          icon: Icons.info_outline_rounded,
          color: ZagColours.blue,
          onTap: widget.item.infoUrl!.openLink,
        ),
      if (widget.item.commentUrl?.isNotEmpty ?? false)
        ZagButton.text(
          text: 'search.Comments'.tr(),
          icon: Icons.comment_outlined,
          color: ZagColours.blueGrey,
          onTap: widget.item.commentUrl!.openLink,
        ),
    ];
  }

  Future<void> _startDownload() async {
    if (widget.item.downloadUrl == null || widget.item.downloadUrl!.isEmpty) {
      showZagInfoSnackBar(
        title: 'zagreus.Error'.tr(),
        message: 'search.MissingDownloadInformation'.tr(),
      );
      return;
    }

    setState(() => _downloadState = ZagLoadingState.ACTIVE);

    try {
      // Show download dialog - hide "Download to Device" for torrents (Apple restriction)
      final result = await SearchDialogs().downloadResult(
        context,
        isTorrent: _isTorrent,
      );

      if (result.item1 && result.item2 != null) {
        await result.item2!.executeProwlarr(context, widget.item);
      }

      if (mounted) {
        setState(() => _downloadState = ZagLoadingState.INACTIVE);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloadState = ZagLoadingState.ERROR);
        showZagErrorSnackBar(
          title: 'search.FailedToSend'.tr(),
          error: e,
        );
      }
    }
  }

  // Helper getters
  IconData? get _categoryPlaceholderIcon {
    final categories = widget.item.categories;
    if (categories == null || categories.isEmpty) return ZagIcons.VIDEO_CAM;
    return categories.first.icon;
  }

  bool get _isTorrent =>
      widget.item.protocol?.toLowerCase() == 'torrent' ||
      widget.item.seeders != null;

  String get _protocolText {
    final protocol = widget.item.protocol?.toLowerCase() ?? '';
    if (protocol == 'torrent' || widget.item.seeders != null) {
      return 'search.Torrent'.tr();
    }
    if (protocol == 'usenet' || protocol == 'nzb') {
      return 'search.Usenet'.tr();
    }
    return widget.item.protocol ?? 'zagreus.Unknown'.tr();
  }

  Color get _protocolColor {
    if (_isTorrent) {
      return ZagColours.purple;
    }
    return ZagColours.blue;
  }

  Color get _seedersColor {
    final seeders = widget.item.seeders ?? 0;
    if (seeders >= 50) return ZagColours.accent;
    if (seeders >= 10) return ZagColours.blue;
    if (seeders >= 1) return ZagColours.orange;
    return ZagColours.red;
  }

  String _formatAge() {
    final days = widget.item.age;
    final hours = widget.item.ageHours;

    if (days == null) return 'zagreus.Unknown'.tr();
    if (days == 0) {
      if (hours != null && hours < 1) return 'search.LessThanHour'.tr();
      if (hours != null) {
        return 'search.HoursShort'.tr(args: [hours.round().toString()]);
      }
      return 'search.Today'.tr();
    }
    if (days == 1) return 'search.OneDay'.tr();
    return 'search.DaysCount'.tr(args: [days.toString()]);
  }

  String _formatSize() {
    final bytes = widget.item.size ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
