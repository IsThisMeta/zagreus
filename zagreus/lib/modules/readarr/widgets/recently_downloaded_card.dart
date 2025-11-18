import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrRecentlyDownloadedBook {
  final int bookId;
  final int authorId;
  final String bookTitle;
  final String? authorName;
  final String? coverUrl;
  final double? rating;
  final DateTime downloadedAt;

  ReadarrRecentlyDownloadedBook({
    required this.bookId,
    required this.authorId,
    required this.bookTitle,
    this.authorName,
    this.coverUrl,
    this.rating,
    required this.downloadedAt,
  });
}

class ReadarrRecentlyDownloadedCard extends StatelessWidget {
  final List<ReadarrRecentlyDownloadedBook> books;
  final VoidCallback? onSeeAll;
  final Function(ReadarrRecentlyDownloadedBook)? onBookTap;

  const ReadarrRecentlyDownloadedCard({
    Key? key,
    required this.books,
    this.onSeeAll,
    this.onBookTap,
  }) : super(key: key);

  Color _sectionIconColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.light ? Colors.black54 : Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;
    const readarrColor = Color(0xFF8E2222); // Readarr red

    return Container(
      margin: const EdgeInsets.only(
        left: ZagUI.DEFAULT_MARGIN_SIZE,
        right: ZagUI.DEFAULT_MARGIN_SIZE,
        bottom: ZagUI.DEFAULT_MARGIN_SIZE,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: isLightTheme ? Border.all(color: Colors.black12) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                ZagIcons.READARR,
                size: 18,
                color: readarrColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recently Downloaded Books',
                  style: (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: readarrColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Book list
          if (books.isEmpty)
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'No recently downloaded books',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return _BookCard(
                    book: book,
                    onTap: onBookTap != null ? () => onBookTap!(book) : null,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final ReadarrRecentlyDownloadedBook book;
  final VoidCallback? onTap;

  const _BookCard({
    Key? key,
    required this.book,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Container(
              height: 120,
              width: 110,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.coverUrl != null
                    ? Image.network(
                        book.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _placeholder(theme);
                        },
                      )
                    : _placeholder(theme),
              ),
            ),
            const SizedBox(height: 6),
            // Book title
            Text(
              book.bookTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Author name
            if (book.authorName != null)
              Text(
                book.authorName!,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            // Rating
            if (book.rating != null && book.rating! > 0)
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    book.rating!.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Icon(
          Icons.book_rounded,
          size: 40,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
