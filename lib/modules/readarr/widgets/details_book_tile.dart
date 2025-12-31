import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/routes/readarr.dart';

class ReadarrDetailsBookTile extends StatelessWidget {
  final ReadarrBookData data;
  final int authorId;
  final Function? refreshState;

  const ReadarrDetailsBookTile({
    Key? key,
    required this.data,
    required this.authorId,
    this.refreshState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagCard(
      context: context,
      child: InkWell(
        borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
        onTap: () => ReadarrRoutes.AUTHOR_BOOK.go(
          params: {
            'author': authorId.toString(),
            'book': data.bookID.toString(),
          },
          queryParams: {
            'monitored': data.monitored.toString(),
          },
        ),
        child: Row(
          children: [
            _poster(context),
            Expanded(child: _details(context)),
          ],
        ),
      ),
    );
  }

  Widget _poster(BuildContext context) {
    return ZagNetworkImage(
      context: context,
      url: data.bookCoverURI(),
      height: 90.0,
      width: 60.0,
      headers: ZagProfile.forModule('readarr').readarrHeaders,
    );
  }

  Widget _details(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book title
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          // Release date
          Text(
            data.releaseDateString,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.0,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4.0),
          // Edition info and status
          Row(
            children: [
              Icon(
                Icons.collections_bookmark_rounded,
                size: 14.0,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  data.editions,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
              // Monitored indicator
              if (data.monitored)
                Icon(
                  Icons.visibility,
                  size: 14.0,
                  color: ZagColours.currentAccent,
                ),
              const SizedBox(width: 4.0),
              // Grabbed indicator
              if (data.grabbed)
                Icon(
                  Icons.download_done_rounded,
                  size: 14.0,
                  color: ZagColours.currentAccent,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
