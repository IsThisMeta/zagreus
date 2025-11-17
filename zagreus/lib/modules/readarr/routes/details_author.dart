import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/router.dart';

class AuthorDetailsRoute extends StatefulWidget {
  final ReadarrCatalogueData? data;
  final int? authorId;

  const AuthorDetailsRoute({
    required this.data,
    required this.authorId,
    Key? key,
  }) : super(key: key);

  @override
  State<AuthorDetailsRoute> createState() => _State();
}

class _State extends State<AuthorDetailsRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _pageController = ZagPageController(initialPage: 1);

  ReadarrCatalogueData? data;
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
    final api = ReadarrAPI.from(ZagProfile.current);
    await api.getAuthor(widget.authorId).then((newData) {
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
        appBar: ZagAppBar(title: 'Author Details'),
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
        ReadarrDetailsEditButton(data: data),
        ReadarrDetailsSettingsButton(
          data: data,
          remove: _removeCallback,
        ),
      ];
    }

    return ZagAppBar(
      title: 'Author Details',
      pageController: _pageController,
      scrollControllers: ReadarrAuthorNavigationBar.scrollControllers,
      actions: _actions,
    );
  }

  Widget get _bottomNavigationBar =>
      ReadarrAuthorNavigationBar(pageController: _pageController);

  List<Widget> get _tabs => [
        ReadarrDetailsOverview(data: data!),
        ReadarrDetailsBookList(authorId: data!.authorID),
      ];

  Widget get _body => ZagPageView(
        controller: _pageController,
        children: _tabs,
      );

  Future<void> _removeCallback(bool withData) async {
    showZagSuccessSnackBar(
      title: 'Author Removed',
      message: data!.title,
    );
    ZagRouter.router.pop();
  }
}
