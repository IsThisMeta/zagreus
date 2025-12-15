import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/router/routes/lidarr.dart';

class LidarrCatalogueTile extends StatefulWidget {
  final LidarrCatalogueData data;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function refresh;
  final Function refreshState;

  const LidarrCatalogueTile({
    Key? key,
    required this.data,
    required this.scaffoldKey,
    required this.refresh,
    required this.refreshState,
  }) : super(key: key);

  @override
  State<LidarrCatalogueTile> createState() => _State();
}

class _State extends State<LidarrCatalogueTile> {
  @override
  Widget build(BuildContext context) {
    return Selector<LidarrState, LidarrCatalogueSorting>(
      selector: (_, state) => state.sortCatalogueType,
      builder: (context, sortingType, _) => ZagBlock(
        title: widget.data.title,
        disabled: !widget.data.monitored!,
        body: [
          TextSpan(
            children: [
              TextSpan(text: widget.data.albums),
              TextSpan(text: ZagUI.TEXT_BULLET.pad()),
              TextSpan(text: widget.data.tracks),
            ],
          ),
          TextSpan(text: widget.data.subtitle(sortingType)),
        ],
        trailing: ZagIconButton(
          icon: widget.data.monitored!
              ? ZagIcons.MONITOR_ON
              : ZagIcons.MONITOR_OFF,
          onPressed: _toggleMonitoredStatus,
        ),
        posterPlaceholderIcon: ZagIcons.USER,
        posterUrl: widget.data.posterURI(),
        posterHeaders: ZagProfile.current.lidarrHeaders,
        backgroundUrl: widget.data.fanartURI(),
        backgroundHeaders: ZagProfile.current.lidarrHeaders,
        posterIsSquare: true,
        onTap: () async => _enterArtist(),
        onLongPress: () async => _handlePopup(),
      ),
    );
  }

  Future<void> _toggleMonitoredStatus() async {
    final _api = LidarrAPI.from(ZagProfile.current);
    await _api
        .toggleArtistMonitored(widget.data.artistID, !widget.data.monitored!)
        .then((_) {
      if (mounted)
        setState(() => widget.data.monitored = !widget.data.monitored!);
      widget.refreshState();
      showZagSuccessSnackBar(
        title: widget.data.monitored! ? 'Monitoring' : 'No Longer Monitoring',
        message: widget.data.title,
      );
    }).catchError((error) {
      showZagErrorSnackBar(
        title: widget.data.monitored!
            ? 'Failed to Stop Monitoring'
            : 'Failed to Monitor',
        error: error,
      );
    });
  }

  Future<void> _enterArtist() async {
    LidarrRoutes.ARTIST.go(
      extra: widget.data,
      params: {
        'artist': widget.data.artistID.toString(),
      },
    );
  }

  Future<void> _handlePopup() async {
    List<dynamic> values = await LidarrDialogs.editArtist(context, widget.data);
    if (values[0])
      switch (values[1]) {
        case 'refresh_artist':
          _refreshArtist();
          break;
        case 'edit_artist':
          _enterEditArtist();
          break;
        case 'remove_artist':
          _removeArtist();
          break;
        default:
          ZagLogger()
              .warning('Invalid method passed through popup. (${values[1]})');
      }
  }

  Future<void> _enterEditArtist() async {
    LidarrRoutes.ARTIST_EDIT.go(
      extra: widget.data,
      params: {
        'artist': widget.data.artistID.toString(),
      },
    );
  }

  Future<void> _refreshArtist() async {
    final _api = LidarrAPI.from(ZagProfile.current);
    await _api
        .refreshArtist(widget.data.artistID)
        .then((_) => showZagSuccessSnackBar(
            title: 'Refreshing...', message: widget.data.title))
        .catchError((error) =>
            showZagErrorSnackBar(title: 'Failed to Refresh', error: error));
  }

  Future<void> _removeArtist() async {
    final _api = LidarrAPI.from(ZagProfile.current);
    List values = await LidarrDialogs.deleteArtist(context);
    if (values[0]) {
      if (values[1]) {
        values = await ZagDialogs()
            .deleteCatalogueWithFiles(context, widget.data.title);
        if (values[0]) {
          await _api
              .removeArtist(widget.data.artistID, deleteFiles: true)
              .then((_) {
            showZagSuccessSnackBar(
                title: 'Removed (With Data)', message: widget.data.title);
            widget.refresh();
          }).catchError((error) {
            showZagErrorSnackBar(
              title: 'Failed to Remove (With Data)',
              error: error,
            );
          });
        }
      } else {
        await _api
            .removeArtist(widget.data.artistID, deleteFiles: false)
            .then((_) {
          showZagSuccessSnackBar(title: 'Removed', message: widget.data.title);
          widget.refresh();
        }).catchError((error) {
          showZagErrorSnackBar(
            title: 'Failed to Remove',
            error: error,
          );
        });
      }
    }
  }
}
