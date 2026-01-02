import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrBookDetailsOverviewDescriptionTile extends StatelessWidget {
  final ReadarrBookData book;
  final int authorId;

  const ReadarrBookDetailsOverviewDescriptionTile({
    Key? key,
    required this.book,
    required this.authorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headers = ZagProfile.forModule('readarr').readarrHeaders;

    // For books, we'll use the cover as both poster and background
    // since Readarr doesn't provide separate fanart for books
    final coverUrl = book.bookCoverURI();

    return ZagBlock(
      posterPlaceholderIcon: Icons.menu_book_rounded,
      backgroundUrl: coverUrl,
      posterUrl: coverUrl,
      posterHeaders: headers,
      title: book.title,
      body: [
        ZagTextSpan.extended(
          text: book.overview == null || book.overview!.isEmpty
              ? 'readarr.NoDescriptionAvailable'.tr()
              : book.overview,
        ),
      ],
      customBodyMaxLines: 3,
      onTap: () async {
        if (book.overview != null && book.overview!.isNotEmpty) {
          ZagDialogs().textPreview(
            context,
            book.title,
            book.overview!,
          );
        }
      },
    );
  }
}
