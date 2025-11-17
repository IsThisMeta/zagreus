import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrBookDetailsOverviewInformationBlock extends StatefulWidget {
  final ReadarrBookData book;
  final Future<void> Function() onRefresh;

  const ReadarrBookDetailsOverviewInformationBlock({
    Key? key,
    required this.book,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<ReadarrBookDetailsOverviewInformationBlock> createState() => _State();
}

class _State extends State<ReadarrBookDetailsOverviewInformationBlock> {
  late ReadarrAPI _api;

  @override
  void initState() {
    super.initState();
    _api = ReadarrAPI.from(ZagProfile.current);
  }

  String? _formatDate(String? dateString) {
    if (dateString == null) return null;
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String? _getPageCount() {
    if (widget.book.editionsData?.isNotEmpty == true) {
      final firstEdition = widget.book.editionsData!.first;
      final pageCount = firstEdition['pageCount'] as int?;
      if (pageCount != null) {
        return '$pageCount Pages';
      }
    }
    return null;
  }

  String? _getReleaseDate() {
    if (widget.book.editionsData?.isNotEmpty == true) {
      final firstEdition = widget.book.editionsData!.first;
      final releaseDate = firstEdition['releaseDate'] as String?;
      return _formatDate(releaseDate);
    }
    return null;
  }

  String? _getRating() {
    if (widget.book.rating != null) {
      return '${widget.book.rating!.toStringAsFixed(1)}/10';
    }
    return null;
  }

  Future<void> _toggleMonitoring() async {
    final currentStatus = widget.book.monitored;
    final newStatus = !currentStatus;

    try {
      await _api.setBookMonitored([widget.book.bookID], newStatus);

      setState(() {
        widget.book.monitored = newStatus;
      });

      showZagSuccessSnackBar(
        title: newStatus
            ? 'Book is now being monitored'
            : 'Book is no longer being monitored',
        message: '',
      );

      // Refresh the parent to update the data
      await widget.onRefresh();
    } catch (error, stack) {
      ZagLogger().error('Failed to toggle monitoring', error, stack);
      showZagErrorSnackBar(
        title: 'Failed to Update',
        error: error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      content: [
        ZagTableContent(
          title: 'monitoring',
          body: widget.book.monitored ? 'Yes' : 'No',
          trailing: ZagIconButton(
            icon: widget.book.monitored
                ? Icons.bookmark_rounded
                : Icons.bookmark_outline_rounded,
            onPressed: _toggleMonitoring,
          ),
        ),
        ZagTableContent(
          title: 'author',
          body: widget.book.authorName,
        ),
        ZagTableContent(title: '', body: ''),
        ZagTableContent(
          title: 'release date',
          body: _getReleaseDate(),
        ),
        ZagTableContent(
          title: 'page count',
          body: _getPageCount(),
        ),
        ZagTableContent(
          title: 'rating',
          body: _getRating(),
        ),
        ZagTableContent(
          title: 'editions',
          body: widget.book.editionCount.toString(),
        ),
      ],
    );
  }
}
