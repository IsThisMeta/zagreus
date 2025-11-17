import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/routes/readarr.dart';

class ReadarrCatalogueTile extends StatelessWidget {
  final ReadarrCatalogueData data;

  const ReadarrCatalogueTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagCard(
      context: context,
      child: InkWell(
        borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
        onTap: () => ReadarrRoutes.AUTHOR.go(params: {
          'author': data.authorID.toString(),
        }),
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
      url: data.posterURI(),
      height: 90.0,
      width: 60.0,
      headers: ZagProfile.current.readarrHeaders,
    );
  }

  Widget _details(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author name
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          // Subtitle based on sort type
          Consumer<ReadarrState>(
            builder: (context, state, _) {
              String? subtitle = data.subtitle(state.sortCatalogueType);
              return Text(
                subtitle ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.0,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              );
            },
          ),
          const SizedBox(height: 4.0),
          // Book statistics
          Row(
            children: [
              Icon(
                Icons.book,
                size: 14.0,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  data.bookStats,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
              // Monitored indicator
              if (data.monitored == true)
                Icon(
                  Icons.visibility,
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
