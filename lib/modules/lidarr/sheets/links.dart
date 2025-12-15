import 'package:flutter/material.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/lidarr/core/api.dart';
import 'package:zagreus/utils/links.dart';
import 'package:zagreus/widgets/ui.dart';

class LinksSheet extends ZagBottomModalSheet {
  LidarrCatalogueData artist;

  LinksSheet({
    required this.artist,
  });

  @override
  Widget builder(BuildContext context) {
    return ZagListViewModal(
      children: [
        if (artist.bandsintownURI?.isNotEmpty ?? false)
          ZagBlock(
            title: 'Bandsintown',
            leading: const ZagIconButton(
              icon: ZagIcons.BANDSINTOWN,
              iconSize: ZagUI.ICON_SIZE - 4.0,
            ),
            onTap: artist.bandsintownURI!.openLink,
          ),
        if (artist.discogsURI?.isNotEmpty ?? false)
          ZagBlock(
            title: 'Discogs',
            leading: const ZagIconButton(
              icon: ZagIcons.DISCOGS,
              iconSize: ZagUI.ICON_SIZE - 2.0,
            ),
            onTap: artist.discogsURI!.openLink,
          ),
        if (artist.lastfmURI?.isNotEmpty ?? false)
          ZagBlock(
            title: 'Last.fm',
            leading: const ZagIconButton(icon: ZagIcons.LASTFM),
            onTap: artist.lastfmURI!.openLink,
          ),
        ZagBlock(
          title: 'MusicBrainz',
          leading: const ZagIconButton(icon: ZagIcons.MUSICBRAINZ),
          onTap:
              ZagLinkedContent.musicBrainz(artist.foreignArtistID)!.openLink,
        ),
      ],
    );
  }
}
