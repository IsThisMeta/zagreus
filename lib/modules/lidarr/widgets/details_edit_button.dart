import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/router/routes/lidarr.dart';

class LidarrDetailsEditButton extends StatefulWidget {
  final LidarrCatalogueData? data;

  const LidarrDetailsEditButton({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<LidarrDetailsEditButton> createState() => _State();
}

class _State extends State<LidarrDetailsEditButton> {
  @override
  Widget build(BuildContext context) => Consumer<LidarrState>(
        builder: (context, model, widget) => ZagIconButton(
          icon: Icons.edit_rounded,
          onPressed: () async => _enterEditArtist(context),
        ),
      );

  Future<void> _enterEditArtist(BuildContext context) async {
    LidarrRoutes.ARTIST_EDIT.go(
      extra: widget.data,
      params: {
        'artist': widget.data!.artistID.toString(),
      },
    );
  }
}
