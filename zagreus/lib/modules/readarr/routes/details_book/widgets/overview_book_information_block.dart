import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrBookDetailsOverviewInformationBlock extends StatelessWidget {
  final ReadarrBookData book;
  final Future<void> Function() onRefresh;

  const ReadarrBookDetailsOverviewInformationBlock({
    Key? key,
    required this.book,
    required this.onRefresh,
  }) : super(key: key);

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
    if (book.editionsData?.isNotEmpty == true) {
      final firstEdition = book.editionsData!.first;
      final pageCount = firstEdition['pageCount'] as int?;
      if (pageCount != null) {
        return '$pageCount Pages';
      }
    }
    return null;
  }

  String? _getReleaseDate() {
    if (book.editionsData?.isNotEmpty == true) {
      final firstEdition = book.editionsData!.first;
      final releaseDate = firstEdition['releaseDate'] as String?;
      return _formatDate(releaseDate);
    }
    return null;
  }

  String? _getRating() {
    if (book.rating != null) {
      return '${book.rating!.toStringAsFixed(1)}/10';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      content: [
        ZagTableContent(
          title: 'monitoring',
          body: book.monitored ? 'Yes' : 'No',
        ),
        ZagTableContent(
          title: 'author',
          body: book.authorName,
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
          body: book.editionCount.toString(),
        ),
      ],
    );
  }
}
