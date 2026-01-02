import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/routes/readarr.dart';

class ReadarrUnifiedSearchResultTile extends StatelessWidget {
  final bool alreadyAdded;
  final ReadarrUnifiedSearchResult data;

  const ReadarrUnifiedSearchResultTile({
    Key? key,
    required this.alreadyAdded,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBook = data.type == ReadarrSearchResultType.book;

    return ZagBlock(
      title: data.displayTitle,
      disabled: alreadyAdded,
      body: _buildBody(isBook),
      customBodyMaxLines: 3,
      trailing: const ZagIconButton.arrow(),
      posterIsSquare: !isBook, // Books use rectangular covers
      posterHeaders: ZagProfile.forModule('readarr').readarrHeaders,
      posterPlaceholderIcon: isBook ? ZagIcons.DOCUMENTATION : ZagIcons.USER,
      posterUrl: data.posterURI,
      onTap: () async => _enterDetails(context),
      onLongPress: () async {
        if (data.goodreadsLink == null || data.goodreadsLink == '') {
          showZagInfoSnackBar(
            title: 'readarr.NoGoodreadsPageAvailable'.tr(),
            message: 'readarr.NoGoodreadsUrlAvailable'.tr(),
          );
        } else {
          data.goodreadsLink!.openLink();
        }
      },
    );
  }

  List<TextSpan> _buildBody(bool isBook) {
    final List<TextSpan> spans = [];

    // First line: Type indicator (and author for books)
    spans.add(TextSpan(
      text: data.typeLabel,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ));

    // For books, add author name on the same line
    if (isBook && data.subtitle != null) {
      spans.add(const TextSpan(text: ' - '));
      spans.add(TextSpan(text: data.subtitle));
    }

    return spans;
  }

  Future<void> _enterDetails(BuildContext context) async {
    if (data.type == ReadarrSearchResultType.author) {
      // Use existing author add flow
      final searchData = data.toSearchData();
      if (searchData != null) {
        ReadarrRoutes.ADD_AUTHOR_DETAILS.go(extra: searchData);
      }
    } else {
      // Use book add flow
      ReadarrRoutes.ADD_BOOK_DETAILS.go(extra: data);
    }
  }
}
