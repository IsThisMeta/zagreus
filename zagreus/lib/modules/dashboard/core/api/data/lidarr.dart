import 'package:flutter/material.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/router/routes/lidarr.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/modules/lidarr/core/api/api.dart';
import 'package:zagreus/modules/dashboard/core/api/data/abstract.dart';

class CalendarLidarrData extends CalendarData {
  String albumTitle;
  int artistId;
  int totalTrackCount;
  bool hasAllFiles;

  CalendarLidarrData({
    required int id,
    required String title,
    required this.albumTitle,
    required this.artistId,
    required this.hasAllFiles,
    required this.totalTrackCount,
  }) : super(id, title);

  @override
  List<TextSpan> get body {
    return [
      TextSpan(
        text: albumTitle,
        style: TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
      TextSpan(
        text: totalTrackCount == 1 ? '1 Track' : '$totalTrackCount Tracks',
      ),
      if (!hasAllFiles)
        TextSpan(
          text: 'Not Downloaded',
          style: TextStyle(
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: ZagColours.red,
          ),
        ),
      if (hasAllFiles)
        TextSpan(
          text: 'Downloaded',
          style: TextStyle(
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: ZagColours.currentAccent,
          ),
        )
    ];
  }

  @override
  Future<void> enterContent(BuildContext context) async {
    LidarrRoutes.ARTIST.go(params: {
      'artist': artistId.toString(),
    });
  }

  @override
  Widget trailing(BuildContext context) => ZagIconButton(
        icon: Icons.search_rounded,
        onPressed: () async => trailingOnPress(context),
        onLongPress: () async => trailingOnLongPress(context),
      );

  @override
  Future<void> trailingOnPress(BuildContext context) async {
    await LidarrAPI.from(ZagProfile.current)
        .searchAlbums([id])
        .then((_) =>
            showZagSuccessSnackBar(title: 'Searching...', message: albumTitle))
        .catchError((error) =>
            showZagErrorSnackBar(title: 'Failed to Search', error: error));
  }

  @override
  Future<void> trailingOnLongPress(BuildContext context) async {
    LidarrRoutes.ARTIST_ALBUM_RELEASES.go(params: {
      'artist': artistId.toString(),
      'album': id.toString(),
    });
  }

  @override
  String backgroundUrl(BuildContext context) {
    final host = ZagProfile.current.lidarrHost;
    final key = ZagProfile.current.lidarrKey;
    if (ZagProfile.current.lidarrEnabled) {
      String _base = host.endsWith('/')
          ? '${host}api/v1/MediaCover/Artist'
          : '$host/api/v1/MediaCover/Artist';
      return '$_base/$artistId/fanart-360.jpg?apikey=$key';
    }
    return '';
  }

  @override
  String posterUrl(BuildContext context) {
    final host = ZagProfile.current.lidarrHost;
    final key = ZagProfile.current.lidarrKey;
    if (ZagProfile.current.lidarrEnabled) {
      String _base = host.endsWith('/')
          ? '${host}api/v1/MediaCover/Artist'
          : '$host/api/v1/MediaCover/Artist';
      return '$_base/$artistId/poster-500.jpg?apikey=$key';
    }
    return '';
  }
}
