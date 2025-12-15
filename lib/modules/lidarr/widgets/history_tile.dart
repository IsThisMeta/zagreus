import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/router/routes/lidarr.dart';

class LidarrHistoryTile extends StatefulWidget {
  static final double extent = ZagBlock.calculateItemExtent(2);
  final LidarrHistoryData entry;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function refresh;

  const LidarrHistoryTile({
    Key? key,
    required this.entry,
    required this.scaffoldKey,
    required this.refresh,
  }) : super(key: key);

  @override
  State<LidarrHistoryTile> createState() => _State();
}

class _State extends State<LidarrHistoryTile> {
  @override
  Widget build(BuildContext context) => ZagBlock(
        title: widget.entry.title,
        body: widget.entry.subtitle,
        trailing: const ZagIconButton.arrow(),
        onTap: () async => _enterArtist(),
      );

  Future<void> _enterArtist() async {
    if (widget.entry.artistID == -1) {
      showZagInfoSnackBar(
        title: 'No Artist Available',
        message: 'There is no artist associated with this history entry',
      );
    } else {
      LidarrRoutes.ARTIST.go(
        params: {
          'artist': widget.entry.artistID.toString(),
        },
      );
    }
  }
}
