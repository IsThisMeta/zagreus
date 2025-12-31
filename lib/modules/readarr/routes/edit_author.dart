import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/router.dart';

class AuthorEditRoute extends StatefulWidget {
  final ReadarrCatalogueData? data;
  final int? authorId;

  const AuthorEditRoute({
    Key? key,
    required this.data,
    required this.authorId,
  }) : super(key: key);

  @override
  State<AuthorEditRoute> createState() => _State();
}

class _State extends State<AuthorEditRoute> with ZagScrollControllerMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<bool>? _future;

  Map<int?, ReadarrQualityProfile> _qualityProfiles = {};
  Map<int?, ReadarrMetadataProfile> _metadataProfiles = {};
  ReadarrQualityProfile? _qualityProfile;
  ReadarrMetadataProfile? _metadataProfile;
  String? _path;
  bool? _monitored;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  Widget build(BuildContext context) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        body: _body,
        appBar: _appBar,
        bottomNavigationBar: _bottomActionBar(),
      );

  Future<void> _refresh() async {
    setState(() {
      _future = _fetch();
    });
  }

  Future<bool> _fetch() async {
    final _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
    return _fetchProfiles(_api).then((_) => _fetchMetadata(_api)).then((_) {
      _path = widget.data!.path;
      _monitored = widget.data!.monitored;
      return true;
    });
  }

  Future<void> _fetchProfiles(ReadarrAPI api) async {
    return await api.getQualityProfiles().then((profiles) {
      _qualityProfiles = profiles;
      if (_qualityProfiles.isNotEmpty) {
        _qualityProfile = _qualityProfiles[widget.data!.qualityProfile];
      }
    });
  }

  Future<void> _fetchMetadata(ReadarrAPI api) async {
    return await api.getMetadataProfiles().then((metadatas) {
      _metadataProfiles = metadatas;
      if (_metadataProfiles.isNotEmpty) {
        _metadataProfile = _metadataProfiles[widget.data!.metadataProfile];
      }
    });
  }

  PreferredSizeWidget get _appBar {
    return ZagAppBar(
      title: widget.data?.title ?? 'Edit Author',
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        ZagButton.text(
          text: 'zagreus.Update'.tr(),
          icon: Icons.edit_rounded,
          onTap: _save,
        ),
      ],
    );
  }

  Widget get _body => FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                if (snapshot.hasError || snapshot.data == null)
                  return ZagMessage.error(onTap: _refresh);
                return _list;
              }
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
            default:
              return const ZagLoader();
          }
        },
      );

  Widget get _list => ZagListView(
        controller: scrollController,
        children: <Widget>[
          ZagBlock(
            title: 'Monitored',
            trailing: ZagSwitch(
              value: _monitored!,
              onChanged: (value) => setState(() => _monitored = value),
            ),
          ),
          ZagBlock(
            title: 'Quality Profile',
            body: [TextSpan(text: _qualityProfile?.name ?? 'Unknown')],
            trailing: const ZagIconButton.arrow(),
            onTap: _changeProfile,
          ),
          ZagBlock(
            title: 'Metadata Profile',
            body: [TextSpan(text: _metadataProfile?.name ?? 'Unknown')],
            trailing: const ZagIconButton.arrow(),
            onTap: _changeMetadata,
          ),
          ZagBlock(
            title: 'Author Path',
            body: [TextSpan(text: _path ?? 'Unknown')],
            trailing: const ZagIconButton.arrow(),
            onTap: _changePath,
          ),
        ],
      );

  Future<void> _changePath() async {
    Tuple2<bool, String> _values =
        await ZagDialogs().editText(context, 'Author Path', prefill: _path!);
    if (_values.item1 && mounted) setState(() => _path = _values.item2);
  }

  Future<void> _changeProfile() async {
    List<dynamic> _values =
        await ReadarrDialogs.editQualityProfile(context, _qualityProfiles.values.toList());
    if (_values[0] && mounted) setState(() => _qualityProfile = _values[1]);
  }

  Future<void> _changeMetadata() async {
    List<dynamic> _values =
        await ReadarrDialogs.editMetadataProfile(context, _metadataProfiles.values.toList());
    if (_values[0] && mounted) setState(() => _metadataProfile = _values[1]);
  }

  Future<void> _save() async {
    final _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
    await _api
        .editAuthor(
      widget.data!.authorID,
      _qualityProfile!,
      _metadataProfile!,
      _path,
      _monitored,
    )
        .then((_) {
      widget.data!.qualityProfile = _qualityProfile!.id;
      widget.data!.quality = _qualityProfile!.name;
      widget.data!.metadataProfile = _metadataProfile!.id;
      widget.data!.metadata = _metadataProfile!.name;
      widget.data!.path = _path;
      widget.data!.monitored = _monitored;
      showZagSuccessSnackBar(
        title: 'Author Updated',
        message: widget.data!.title,
      );
      ZagRouter.router.pop();
    }).catchError((error, stack) {
      ZagLogger().error('Failed to update author', error, stack);
      showZagErrorSnackBar(
        title: 'Failed to Update',
        error: error,
      );
    });
  }
}
