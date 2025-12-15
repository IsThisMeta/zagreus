import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/modules/readarr/routes/details_book/widgets/navigation_bar.dart';

class ReadarrBookDetailsFilesPage extends StatefulWidget {
  final List<ReadarrBookFileData> bookFiles;
  final Future<void> Function() onRefresh;
  final Function(ReadarrBookFileData) onDeleteFile;

  const ReadarrBookDetailsFilesPage({
    Key? key,
    required this.bookFiles,
    required this.onRefresh,
    required this.onDeleteFile,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ReadarrBookDetailsFilesPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: widget.onRefresh,
      child: _list(),
    );
  }

  Widget _list() {
    if (widget.bookFiles.isEmpty) {
      return ZagMessage(
        text: 'No Files Found',
        buttonText: 'Refresh',
        onTap: () => _refreshKey.currentState?.show(),
      );
    }

    return ZagListView(
      controller: ReadarrBookDetailsNavigationBar.scrollControllers[1],
      children: widget.bookFiles.map((file) => _fileBlock(file)).toList(),
    );
  }

  Widget _fileBlock(ReadarrBookFileData file) {
    final fileName = file.path?.split('/').last ?? 'Unknown File';
    final quality = file.quality ?? 'Unknown Quality';
    final size = _formatFileSize(file.size ?? 0);
    final dateAdded = file.dateAdded != null
        ? DateFormat('MMM dd, yyyy').format(file.dateAdded!)
        : 'Unknown Date';

    return ZagBlock(
      title: fileName,
      body: [
        ZagTextSpan.extended(
          text: '$size • $quality\nAdded: $dateAdded',
        ),
      ],
      posterPlaceholderIcon: Icons.insert_drive_file_outlined,
      trailing: ZagIconButton(
        icon: Icons.delete_rounded,
        onPressed: () => widget.onDeleteFile(file),
      ),
    );
  }
}
