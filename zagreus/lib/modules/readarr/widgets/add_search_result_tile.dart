import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/routes/readarr.dart';

class ReadarrAddSearchResultTile extends StatelessWidget {
  final bool alreadyAdded;
  final ReadarrSearchData data;

  const ReadarrAddSearchResultTile({
    Key? key,
    required this.alreadyAdded,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ZagBlock(
        title: data.title,
        disabled: alreadyAdded,
        body: [
          ZagTextSpan.extended(text: data.overview?.trim() ?? 'No overview available'),
        ],
        customBodyMaxLines: 3,
        trailing: alreadyAdded ? null : const ZagIconButton.arrow(),
        posterIsSquare: true,
        posterHeaders: ZagProfile.current.readarrHeaders,
        posterPlaceholderIcon: ZagIcons.USER,
        posterUrl: data.posterURI,
        onTap: () async => _enterDetails(context),
        onLongPress: () async {
          if (data.goodreadsLink == null || data.goodreadsLink == '')
            showZagInfoSnackBar(
              title: 'No Goodreads Page Available',
              message: 'No Goodreads URL is available',
            );
          else
            data.goodreadsLink!.openLink();
        },
      );

  Future<void> _enterDetails(BuildContext context) async {
    if (alreadyAdded) {
      showZagInfoSnackBar(
        title: 'Author Already in Readarr',
        message: data.title,
      );
    } else {
      ReadarrRoutes.ADD_AUTHOR_DETAILS.go(extra: data);
    }
  }
}
