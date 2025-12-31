import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/modules/readarr/routes/details_book/widgets/navigation_bar.dart';
import 'package:zagreus/modules/readarr/routes/details_book/widgets/page_overview.dart';
import 'package:zagreus/modules/readarr/routes/details_book/widgets/page_files.dart';
import 'package:zagreus/router/routes/readarr.dart';

class AuthorBookDetailsRoute extends StatefulWidget {
  final int authorId;
  final int bookId;
  final bool monitored;

  const AuthorBookDetailsRoute({
    Key? key,
    required this.authorId,
    required this.bookId,
    required this.monitored,
  }) : super(key: key);

  @override
  State<AuthorBookDetailsRoute> createState() => _State();
}

class _State extends State<AuthorBookDetailsRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController? _pageController;

  ReadarrBookData? _book;
  List<ReadarrBookFileData> _bookFiles = [];
  bool _isLoading = true;

  late ReadarrAPI _api;

  @override
  void initState() {
    super.initState();
    _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
    _pageController = PageController(initialPage: 0);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      // Fetch book details
      final book = await _api.getBook(widget.bookId);

      // Fetch book files for this author
      final allFiles = await _api.getBookFilesForAuthor(widget.authorId);

      // Filter files for this specific book
      final bookFiles = allFiles.where((f) => f.bookID == widget.bookId).toList();

      setState(() {
        _book = book;
        _bookFiles = bookFiles;
        _isLoading = false;
      });
    } catch (error, stack) {
      ZagLogger().error('Failed to load book details', error, stack);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    return _loadData(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body,
      appBar: _appBar,
      bottomNavigationBar: _book != null ? _bottomNavigationBar() : null,
    );
  }

  PreferredSizeWidget get _appBar {
    return ZagAppBar(
      title: 'Book Details',
      pageController: _pageController,
      scrollControllers: ReadarrBookDetailsNavigationBar.scrollControllers,
      actions: _book != null
          ? [
              ZagIconButton(
                icon: Icons.public_rounded,
                onPressed: () => _openGoodreads(),
              ),
            ]
          : null,
    );
  }

  Widget? _bottomNavigationBar() {
    if (_book == null) return null;
    return ReadarrBookDetailsNavigationBar(
      pageController: _pageController,
      book: _book!,
      authorId: widget.authorId,
      onManualSearch: _manualSearch,
    );
  }

  Widget get _body {
    if (_isLoading) {
      return const ZagLoader();
    }

    if (_book == null) {
      return ZagMessage.error(onTap: _loadData);
    }

    return _pages();
  }

  Widget _pages() {
    return ZagPageView(
      controller: _pageController,
      children: [
        ReadarrBookDetailsOverviewPage(
          book: _book!,
          authorId: widget.authorId,
          onRefresh: _refreshData,
        ),
        ReadarrBookDetailsFilesPage(
          bookFiles: _bookFiles,
          onRefresh: _refreshData,
          onDeleteFile: _deleteFile,
        ),
      ],
    );
  }

  void _manualSearch() {
    ReadarrRoutes.AUTHOR_BOOK_RELEASES.go(params: {
      'author': widget.authorId.toString(),
      'book': widget.bookId.toString(),
    });
  }

  Future<void> _openGoodreads() async {
    final book = _book!;

    // Try to find Goodreads link
    String? goodreadsUrl;

    if (book.links != null) {
      for (var link in book.links!) {
        final linkName = link['name'] as String?;
        final linkUrl = link['url'] as String?;
        if (linkName?.toLowerCase().contains('goodreads') ?? false) {
          goodreadsUrl = linkUrl;
          break;
        }
      }
    }

    if (goodreadsUrl != null) {
      final uri = Uri.parse(goodreadsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showZagErrorSnackBar(
          title: 'Failed to Open',
          message: 'Could not open Goodreads link',
        );
      }
    } else {
      showZagErrorSnackBar(
        title: 'No Link Found',
        message: 'No Goodreads link available for this book',
      );
    }
  }

  Future<void> _deleteFile(ReadarrBookFileData file) async {
    // TODO: Implement file deletion with confirmation dialog
    // For now, just show a message that it's not implemented
    showZagInfoSnackBar(
      title: 'Delete Not Implemented',
      message: 'File deletion API not yet implemented',
    );

    // Future implementation:
    // 1. Show confirmation dialog
    // 2. Call delete API
    // 3. Refresh data: await _loadData();
    // 4. Show success message
  }
}
