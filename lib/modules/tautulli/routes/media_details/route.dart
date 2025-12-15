import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class MediaDetailsRoute extends StatefulWidget {
  final int ratingKey;
  final TautulliMediaType mediaType;

  const MediaDetailsRoute({
    Key? key,
    required this.ratingKey,
    required this.mediaType,
  }) : super(key: key);

  @override
  State<MediaDetailsRoute> createState() => _State();
}

class _State extends State<MediaDetailsRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = ZagPageController(
        initialPage: TautulliDatabase.NAVIGATION_INDEX_MEDIA_DETAILS.read());
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      body: _body(),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'Media Details',
      scrollControllers: TautulliMediaDetailsNavigationBar.scrollControllers,
      pageController: _pageController,
      actions: [
        TautulliMediaDetailsOpenPlexButton(
          ratingKey: widget.ratingKey,
          mediaType: widget.mediaType,
        ),
      ],
    );
  }

  Widget? _bottomNavigationBar() {
    if (widget.mediaType != TautulliMediaType.NULL &&
        widget.mediaType != TautulliMediaType.COLLECTION)
      return TautulliMediaDetailsNavigationBar(pageController: _pageController);
    return null;
  }

  Widget _body() {
    if (widget.mediaType == TautulliMediaType.NULL)
      return const ZagMessage(text: 'No Content Found');
    if (widget.mediaType == TautulliMediaType.COLLECTION)
      return TautulliMediaDetailsMetadata(
        ratingKey: widget.ratingKey,
        type: widget.mediaType,
      );
    return ZagPageView(
      controller: _pageController,
      children: [
        TautulliMediaDetailsMetadata(
          ratingKey: widget.ratingKey,
          type: widget.mediaType,
        ),
        TautulliMediaDetailsHistory(
          ratingKey: widget.ratingKey,
          type: widget.mediaType,
        ),
      ],
    );
  }
}
