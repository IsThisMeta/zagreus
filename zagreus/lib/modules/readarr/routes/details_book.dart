import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
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

class _State extends State<AuthorBookDetailsRoute>
    with ZagScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  ReadarrBookData? _book;
  List<ReadarrBookFileData> _bookFiles = [];
  bool _isLoading = true;

  late ReadarrAPI _api;

  @override
  void initState() {
    super.initState();
    _api = ReadarrAPI.from(ZagProfile.current);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

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

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      body: _body,
      appBar: _appBar,
    );
  }

  PreferredSizeWidget get _appBar {
    return ZagAppBar(
      title: 'Book Details',
      scrollControllers: [scrollController],
      actions: _book != null
          ? [
              ZagIconButton(
                icon: Icons.search_rounded,
                onPressed: () => _automaticSearch(),
                onLongPress: () => _manualSearch(),
              ),
            ]
          : null,
    );
  }

  Widget get _body {
    if (_isLoading) {
      return const ZagLoader();
    }

    if (_book == null) {
      return ZagMessage.error(onTap: _loadData);
    }

    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: _loadData,
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(0),
        children: [
          _buildHeroSection(),
          _buildOverviewSection(),
          _buildActionButtons(),
          _buildFileStatusCard(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    final book = _book!;
    final imageUrl = _getBookCoverUrl();

    // Get headers for image requests
    final headers = ZagProfile.current.readarrHeaders;

    // Get first edition data if available
    final firstEdition = book.editions?.isNotEmpty == true ? book.editions!.first : null;
    final pageCount = firstEdition?['pageCount'] as int?;
    final releaseDate = firstEdition?['releaseDate'] as String?;

    return Stack(
      children: [
        // Blurred background
        if (imageUrl != null)
          Container(
            height: 350,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl, headers: headers),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ),

        // Content
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Book cover image
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    headers: headers,
                    width: 170,
                    height: 264,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
                  ),
                )
              else
                _buildPlaceholderCover(),

              const SizedBox(height: 16),

              // Book title
              Text(
                book.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Author name button
              if (book.authorName != null)
                TextButton(
                  onPressed: () => _navigateToAuthor(),
                  child: Text(
                    book.authorName!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Metadata row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (pageCount != null) ...[
                    Text(
                      '$pageCount Pages',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const Text(' • ', style: TextStyle(color: Colors.white70)),
                  ],
                  if (releaseDate != null) ...[
                    Text(
                      _formatDate(releaseDate),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                  if (book.rating != null) ...[
                    const Text(' • ', style: TextStyle(color: Colors.white70)),
                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      book.rating!.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      width: 170,
      height: 264,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        size: 80,
        color: Colors.white30,
      ),
    );
  }

  Widget _buildOverviewSection() {
    final book = _book!;
    final overview = book.overview;

    if (overview == null || overview.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ZagBlock(
          title: 'Overview',
          body: const [
            ZagTextSpan.extended(
              text: 'No description was found for this book.',
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ZagBlock(
        title: 'Overview',
        body: [
          ZagTextSpan.extended(
            text: overview,
          ),
        ],
        onTap: () async => ZagDialogs().textPreview(
          context,
          'Overview',
          overview,
        ),
        customBodyMaxLines: 5,
      ),
    );
  }

  Widget _buildActionButtons() {
    final book = _book!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Monitor button
          Expanded(
            flex: 25,
            child: ElevatedButton(
              onPressed: () => _toggleMonitoring(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Icon(
                book.monitored
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Search button
          Expanded(
            flex: 50,
            child: ElevatedButton(
              onPressed: () => _manualSearch(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Search'),
            ),
          ),

          const SizedBox(width: 8),

          // Goodreads button
          Expanded(
            flex: 25,
            child: ElevatedButton(
              onPressed: () => _openGoodreads(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Icon(Icons.public_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileStatusCard() {
    if (_bookFiles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ZagBlock(
          title: 'Files',
          body: const [
            ZagTextSpan.extended(
              text: 'No files downloaded',
            ),
          ],
          posterPlaceholderIcon: Icons.menu_book_rounded,
        ),
      );
    }

    final file = _bookFiles.first;
    final fileName = file.path?.split('/').last ?? 'Unknown File';
    final quality = file.quality ?? 'Unknown Quality';
    final size = _formatFileSize(file.size ?? 0);
    final dateAdded = file.dateAdded != null
        ? DateFormat('MMM dd, yyyy').format(file.dateAdded!)
        : 'Unknown Date';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ZagBlock(
        title: 'Files',
        body: [
          ZagTextSpan.extended(
            text: '$fileName\n$size • $quality\n$dateAdded',
          ),
        ],
        trailing: ZagIconButton(
          icon: Icons.delete_rounded,
          onPressed: () => _deleteFile(file),
        ),
      ),
    );
  }

  String? _getBookCoverUrl() {
    if (_book?.bookID == null) return null;

    // Construct cover URL directly as per nzb360 implementation
    final profile = ZagProfile.current;
    final baseUrl = profile.effectiveReadarrHost().endsWith('/')
        ? profile.effectiveReadarrHost()
        : '${profile.effectiveReadarrHost()}/';

    return '${baseUrl}api/v1/mediacover/book/${_book!.bookID}/cover.jpg';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _navigateToAuthor() {
    ReadarrRoutes.AUTHOR.go(params: {
      'author': widget.authorId.toString(),
    });
  }

  Future<void> _toggleMonitoring() async {
    final currentStatus = _book!.monitored;
    final newStatus = !currentStatus;

    try {
      await _api.setBookMonitored([widget.bookId], newStatus);

      setState(() {
        _book!.monitored = newStatus;
      });

      showZagSuccessSnackBar(
        title: newStatus
            ? 'Book is now being monitored'
            : 'Book is no longer being monitored',
        message: '',
      );
    } catch (error, stack) {
      ZagLogger().error('Failed to toggle monitoring', error, stack);
      showZagErrorSnackBar(
        title: 'Failed to Update',
        error: error,
      );
    }
  }

  Future<void> _automaticSearch() async {
    try {
      await _api.searchBooks([widget.bookId]);
      showZagSuccessSnackBar(
        title: 'Searching...',
        message: 'Automatic search started',
      );
    } catch (error, stack) {
      ZagLogger().error('Failed to search for book', error, stack);
      showZagErrorSnackBar(
        title: 'Failed to Search',
        error: error,
      );
    }
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
