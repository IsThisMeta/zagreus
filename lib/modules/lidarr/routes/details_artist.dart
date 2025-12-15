import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/modules/lidarr/sheets/links.dart';
import 'package:zagreus/router/router.dart';

class ArtistDetailsRoute extends StatefulWidget {
  final LidarrCatalogueData? data;
  final int? artistId;

  const ArtistDetailsRoute({
    required this.data,
    required this.artistId,
    Key? key,
  }) : super(key: key);

  @override
  State<ArtistDetailsRoute> createState() => _State();
}

class _State extends State<ArtistDetailsRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _pageController = ZagPageController(initialPage: 1);

  LidarrCatalogueData? data;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetch();
    });
  }

  Future<void> _fetch() async {
    if (mounted) setState(() => _error = false);
    final api = LidarrAPI.from(ZagProfile.current);
    await api.getArtist(widget.artistId).then((newData) {
      if (mounted) {
        setState(() {
          data = newData;
          _error = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _error = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: ZagAppBar(title: 'Artist Details'),
        body: ZagMessage.error(onTap: _fetch),
      );
    }

    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar,
      bottomNavigationBar: data != null ? _bottomNavigationBar : null,
      body: data != null ? _body : const ZagLoader(),
    );
  }

  PreferredSizeWidget get _appBar {
    List<Widget>? _actions;

    if (data != null) {
      _actions = [
        ZagIconButton(
          icon: ZagIcons.LINK,
          onPressed: () async {
            LinksSheet(artist: data!).show();
          },
        ),
        LidarrDetailsEditButton(data: data),
        LidarrDetailsSettingsButton(
          data: data,
          remove: _removeCallback,
        ),
      ];
    }

    return ZagAppBar(
      title: 'Artist Details',
      pageController: _pageController,
      scrollControllers: LidarrArtistNavigationBar.scrollControllers,
      actions: _actions,
    );
  }

  Widget get _bottomNavigationBar =>
      LidarrArtistNavigationBar(pageController: _pageController);

  List<Widget> get _tabs => [
        LidarrDetailsOverview(data: data!),
        LidarrDetailsAlbumList(artistID: data!.artistID),
      ];

  Widget get _body => ZagPageView(
        controller: _pageController,
        children: _tabs,
      );

  Future<void> _removeCallback(bool withData) async {
    showZagSuccessSnackBar(
      title: 'Artist Removed',
      message: data!.title,
    );
    ZagRouter.router.pop();
  }
}
