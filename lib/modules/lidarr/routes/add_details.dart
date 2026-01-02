import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/widgets/pages/invalid_route.dart';

class AddArtistDetailsRoute extends StatefulWidget {
  final LidarrSearchData? data;

  const AddArtistDetailsRoute({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<AddArtistDetailsRoute> createState() => _State();
}

class _State extends State<AddArtistDetailsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void>? _future;
  List<LidarrRootFolder> _rootFolders = [];
  List<LidarrQualityProfile> _qualityProfiles = [];
  List<LidarrMetadataProfile> _metadataProfiles = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _refresh();
    });
  }

  void _refresh() => setState(() {
        _future = _fetchParameters();
      });

  Future<void> _fetchParameters() async {
    LidarrAPI _api = LidarrAPI.from(ZagProfile.forModule('lidarr'));
    return _fetchRootFolders(_api)
        .then((_) => _fetchQualityProfiles(_api))
        .then((_) => _fetchMetadataProfiles(_api))
        .then((_) {})
        .catchError((error) => error);
  }

  Future<void> _fetchRootFolders(LidarrAPI api) async {
    return await api.getRootFolders().then((values) {
      final _rootfolder = LidarrDatabase.ADD_ROOT_FOLDER.read();
      _rootFolders = values;
      int index = _rootFolders.indexWhere((value) =>
          value.id == _rootfolder?.id && value.path == _rootfolder?.path);
      LidarrDatabase.ADD_ROOT_FOLDER
          .update(index != -1 ? _rootFolders[index] : _rootFolders[0]);
    }).catchError((error) {
      Future.error(error);
    });
  }

  Future<void> _fetchQualityProfiles(LidarrAPI api) async {
    return await api.getQualityProfiles().then((values) {
      final _profile = LidarrDatabase.ADD_QUALITY_PROFILE.read();
      _qualityProfiles = values.values.toList();
      int index = _qualityProfiles.indexWhere(
          (value) => value.id == _profile?.id && value.name == _profile?.name);
      LidarrDatabase.ADD_QUALITY_PROFILE
          .update(index != -1 ? _qualityProfiles[index] : _qualityProfiles[0]);
    }).catchError((error) => error);
  }

  Future<void> _fetchMetadataProfiles(LidarrAPI api) async {
    return await api.getMetadataProfiles().then((values) {
      final _profile = LidarrDatabase.ADD_METADATA_PROFILE.read();
      _metadataProfiles = values.values.toList();
      int index = _metadataProfiles.indexWhere(
          (value) => value.id == _profile?.id && value.name == _profile?.name);
      LidarrDatabase.ADD_METADATA_PROFILE.update(
          index != -1 ? _metadataProfiles[index] : _metadataProfiles[0]);
    }).catchError((error) => error);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      return InvalidRoutePage(
        title: 'lidarr.AddArtist'.tr(),
        message: 'lidarr.ArtistNotFound'.tr(),
      );
    }

    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _bottomActionBar() {
    return ZagBottomActionBar(
      actions: [
        ZagActionBarCard(
          title: 'zagreus.Options'.tr(),
          subtitle: 'lidarr.StartSearchFor'.tr(),
          onTap: () async => LidarrDialogs().addArtistOptions(context),
        ),
        ZagButton.text(
          text: 'zagreus.Add'.tr(),
          icon: Icons.add_rounded,
          onTap: () async => _addArtist(),
        ),
      ],
    );
  }

  PreferredSizeWidget get _appBar {
    return ZagAppBar(
      title: widget.data!.title,
      scrollControllers: [scrollController],
    );
  }

  Widget get _body {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            {
              if (snapshot.hasError) return ZagMessage.error(onTap: _refresh);
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
  }

  Widget get _list {
    return ZagListView(
      controller: scrollController,
      children: <Widget>[
        LidarrDescriptionBlock(
          title: widget.data?.title ?? 'zagreus.Unknown'.tr(),
          description: (widget.data?.overview ?? '').isEmpty
              ? 'lidarr.NoSummaryAvailable'.tr()
              : widget.data!.overview,
          uri: widget.data?.posterURI ?? '',
          squareImage: true,
          headers: ZagProfile.forModule('lidarr').lidarrHeaders,
          onLongPress: () async {
            if (widget.data?.discogsLink?.isEmpty ?? true) {
              showZagInfoSnackBar(
                title: 'lidarr.NoDiscogsPageAvailable'.tr(),
                message: 'lidarr.NoDiscogsUrlAvailable'.tr(),
              );
            }
            widget.data?.discogsLink?.openLink();
          },
        ),
        LidarrDatabase.ADD_ROOT_FOLDER.listenableBuilder(
          builder: (context, _) {
            final _rootfolder = LidarrDatabase.ADD_ROOT_FOLDER.read();
            return ZagBlock(
              title: 'lidarr.RootFolder'.tr(),
              body: [
                TextSpan(
                    text: _rootfolder?.path ??
                        'lidarr.UnknownRootFolder'.tr()),
              ],
              trailing: const ZagIconButton.arrow(),
              onTap: () async {
                List _values =
                    await LidarrDialogs.editRootFolder(context, _rootFolders);
                if (_values[0])
                  LidarrDatabase.ADD_ROOT_FOLDER.update(_values[1]);
              },
            );
          },
        ),
        LidarrDatabase.ADD_MONITORED_STATUS.listenableBuilder(
            builder: (context, _) {
          const _db = LidarrDatabase.ADD_MONITORED_STATUS;
          final _status = LidarrMonitorStatus.ALL.fromKey(_db.read()) ??
              LidarrMonitorStatus.ALL;

          return ZagBlock(
            title: 'lidarr.Monitor'.tr(),
            trailing: const ZagIconButton.arrow(),
            body: [TextSpan(text: _status.readable)],
            onTap: () async {
              Tuple2<bool, LidarrMonitorStatus?> _result =
                  await LidarrDialogs().selectMonitoringOption(context);
              if (_result.item1) _db.update(_result.item2!.key);
            },
          );
        }),
        LidarrDatabase.ADD_QUALITY_PROFILE.listenableBuilder(
          builder: (context, _) {
            final _profile = LidarrDatabase.ADD_QUALITY_PROFILE.read();
            return ZagBlock(
              title: 'lidarr.QualityProfile'.tr(),
              body: [
                TextSpan(
                    text:
                        _profile?.name ?? 'lidarr.UnknownProfile'.tr()),
              ],
              trailing: const ZagIconButton.arrow(),
              onTap: () async {
                List _values = await LidarrDialogs.editQualityProfile(
                    context, _qualityProfiles);
                if (_values[0])
                  LidarrDatabase.ADD_QUALITY_PROFILE.update(_values[1]);
              },
            );
          },
        ),
        LidarrDatabase.ADD_METADATA_PROFILE.listenableBuilder(
          builder: (context, _) {
            final _profile = LidarrDatabase.ADD_METADATA_PROFILE.read();
            return ZagBlock(
              title: 'lidarr.MetadataProfile'.tr(),
              body: [
                TextSpan(
                    text:
                        _profile?.name ?? 'lidarr.UnknownProfile'.tr()),
              ],
              trailing: const ZagIconButton.arrow(),
              onTap: () async {
                List _values = await LidarrDialogs.editMetadataProfile(
                    context, _metadataProfiles);
                if (_values[0])
                  LidarrDatabase.ADD_METADATA_PROFILE.update(_values[1]);
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _addArtist() async {
    LidarrAPI _api = LidarrAPI.from(ZagProfile.forModule('lidarr'));
    bool? search = LidarrDatabase.ADD_ARTIST_SEARCH_FOR_MISSING.read();
    await _api
        .addArtist(
      widget.data!,
      LidarrDatabase.ADD_QUALITY_PROFILE.read()!,
      LidarrDatabase.ADD_ROOT_FOLDER.read()!,
      LidarrDatabase.ADD_METADATA_PROFILE.read()!,
      LidarrMonitorStatus.ALL
          .fromKey(LidarrDatabase.ADD_MONITORED_STATUS.read())!,
      search: search,
    )
        .then((id) {
      showZagSuccessSnackBar(
        title: 'lidarr.ArtistAdded'.tr(),
        message: widget.data!.title,
      );
      ZagRouter.router.pop();

      /// todo: Add redirect to artist page
    }).catchError((error, stack) {
      ZagLogger().error('Failed to add artist', error, stack);
      showZagErrorSnackBar(
        title: search
            ? 'lidarr.FailedToAddArtistWithSearch'.tr()
            : 'lidarr.FailedToAddArtist'.tr(),
        error: error,
      );
    });
  }
}
