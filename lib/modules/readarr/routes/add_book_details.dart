import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/tables/readarr.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/readarr.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/widgets/pages/invalid_route.dart';

class AddBookDetailsRoute extends StatefulWidget {
  final ReadarrUnifiedSearchResult? data;

  const AddBookDetailsRoute({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<AddBookDetailsRoute> createState() => _State();
}

class _State extends State<AddBookDetailsRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void>? _future;
  List<ReadarrRootFolder> _rootFolders = [];
  Map<int?, ReadarrQualityProfile> _qualityProfiles = {};
  Map<int?, ReadarrMetadataProfile> _metadataProfiles = {};

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
    ReadarrAPI _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
    return _fetchRootFolders(_api)
        .then((_) => _fetchQualityProfiles(_api))
        .then((_) => _fetchMetadataProfiles(_api))
        .then((_) {})
        .catchError((error) => error);
  }

  Future<void> _fetchRootFolders(ReadarrAPI api) async {
    return await api.getRootFolders().then((values) {
      _rootFolders = values;
      final savedId = ReadarrDatabase.ADD_AUTHOR_DEFAULT_ROOT_FOLDER_ID.read();
      final hasValidFolder = _rootFolders.any((f) => f.id == savedId);
      if (savedId == null || !hasValidFolder) {
        if (_rootFolders.isNotEmpty) {
          ReadarrDatabase.ADD_AUTHOR_DEFAULT_ROOT_FOLDER_ID
              .update(_rootFolders.first.id);
        }
      }
    }).catchError((error) {
      Future.error(error);
    });
  }

  Future<void> _fetchQualityProfiles(ReadarrAPI api) async {
    return await api.getQualityProfiles().then((values) {
      _qualityProfiles = values;
      final savedId =
          ReadarrDatabase.ADD_AUTHOR_DEFAULT_QUALITY_PROFILE_ID.read();
      if (savedId == null || !_qualityProfiles.containsKey(savedId)) {
        if (_qualityProfiles.isNotEmpty) {
          ReadarrDatabase.ADD_AUTHOR_DEFAULT_QUALITY_PROFILE_ID
              .update(_qualityProfiles.keys.first);
        }
      }
    }).catchError((error) => error);
  }

  Future<void> _fetchMetadataProfiles(ReadarrAPI api) async {
    return await api.getMetadataProfiles().then((values) {
      _metadataProfiles = values;
      final savedId =
          ReadarrDatabase.ADD_AUTHOR_DEFAULT_METADATA_PROFILE_ID.read();
      if (savedId == null || !_metadataProfiles.containsKey(savedId)) {
        if (_metadataProfiles.isNotEmpty) {
          ReadarrDatabase.ADD_AUTHOR_DEFAULT_METADATA_PROFILE_ID
              .update(_metadataProfiles.keys.first);
        }
      }
    }).catchError((error) => error);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      return InvalidRoutePage(
        title: 'readarr.AddBook'.tr(),
        message: 'readarr.BookNotFound'.tr(),
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
          subtitle: 'readarr.StartSearchFor'.tr(),
          onTap: () async => ReadarrDialogs().addAuthorOptions(context),
        ),
        ZagButton.text(
          text: 'zagreus.Add'.tr(),
          icon: Icons.add_rounded,
          onTap: () async => _addBook(),
        ),
      ],
    );
  }

  PreferredSizeWidget get _appBar {
    return ZagAppBar(
      title: widget.data!.displayTitle,
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
        ReadarrDescriptionBlock(
          title: widget.data?.displayTitle ?? 'zagreus.Unknown'.tr(),
          description: widget.data?.overview ?? 'readarr.NoSummaryAvailable'.tr(),
          uri: widget.data?.posterURI ?? '',
          squareImage: false, // Books have rectangular covers
          headers: ZagProfile.forModule('readarr').readarrHeaders,
          onLongPress: () async {
            if (widget.data?.goodreadsLink?.isEmpty ?? true) {
              showZagInfoSnackBar(
                title: 'readarr.NoGoodreadsPageAvailable'.tr(),
                message: 'readarr.NoGoodreadsUrlAvailable'.tr(),
              );
            }
            widget.data?.goodreadsLink?.openLink();
          },
        ),
        // Show author name for books
        if (widget.data?.bookAuthorName != null)
          ZagBlock(
            title: 'readarr.Author'.tr(),
            body: [
              TextSpan(text: widget.data!.bookAuthorName!),
            ],
          ),
        ReadarrDatabase.ADD_AUTHOR_DEFAULT_ROOT_FOLDER_ID.listenableBuilder(
          builder: (context, _) {
            final folderId =
                ReadarrDatabase.ADD_AUTHOR_DEFAULT_ROOT_FOLDER_ID.read();
            final folder = _rootFolders.cast<ReadarrRootFolder?>().firstWhere(
              (f) => f?.id == folderId,
              orElse: () => null,
            );
            return ZagBlock(
              title: 'readarr.RootFolder'.tr(),
              body: [
                TextSpan(
                  text:
                      folder?.path ?? 'readarr.UnknownRootFolder'.tr(),
                ),
              ],
              trailing: const ZagIconButton.arrow(),
              onTap: () async {
                List _values =
                    await ReadarrDialogs.editRootFolder(context, _rootFolders);
                if (_values[0])
                  ReadarrDatabase.ADD_AUTHOR_DEFAULT_ROOT_FOLDER_ID
                      .update(_values[1].id);
              },
            );
          },
        ),
        ReadarrDatabase.ADD_AUTHOR_DEFAULT_MONITOR_NEW_ITEMS.listenableBuilder(
            builder: (context, _) {
          const _db = ReadarrDatabase.ADD_AUTHOR_DEFAULT_MONITOR_NEW_ITEMS;
          final _status = ReadarrMonitorStatus.ALL.fromKey(_db.read()) ??
              ReadarrMonitorStatus.ALL;

          return ZagBlock(
            title: 'readarr.Monitor'.tr(),
            trailing: const ZagIconButton.arrow(),
            body: [TextSpan(text: _status.readable)],
            onTap: () async {
              Tuple2<bool, ReadarrMonitorStatus?> _result =
                  await ReadarrDialogs().selectMonitoringOption(context);
              if (_result.item1) _db.update(_result.item2!.key);
            },
          );
        }),
        ReadarrDatabase.ADD_AUTHOR_DEFAULT_QUALITY_PROFILE_ID.listenableBuilder(
          builder: (context, _) {
            final profileId =
                ReadarrDatabase.ADD_AUTHOR_DEFAULT_QUALITY_PROFILE_ID.read();
            final profile = _qualityProfiles[profileId];
            return ZagBlock(
              title: 'readarr.QualityProfile'.tr(),
              body: [
                TextSpan(
                  text: profile?.name ?? 'readarr.UnknownProfile'.tr(),
                ),
              ],
              trailing: const ZagIconButton.arrow(),
              onTap: () async {
                List _values = await ReadarrDialogs.editQualityProfile(
                    context, _qualityProfiles.values.toList());
                if (_values[0])
                  ReadarrDatabase.ADD_AUTHOR_DEFAULT_QUALITY_PROFILE_ID
                      .update(_values[1].id);
              },
            );
          },
        ),
        ReadarrDatabase.ADD_AUTHOR_DEFAULT_METADATA_PROFILE_ID
            .listenableBuilder(
          builder: (context, _) {
            final profileId =
                ReadarrDatabase.ADD_AUTHOR_DEFAULT_METADATA_PROFILE_ID.read();
            final profile = _metadataProfiles[profileId];
            return ZagBlock(
              title: 'readarr.MetadataProfile'.tr(),
              body: [
                TextSpan(
                  text: profile?.name ?? 'readarr.UnknownProfile'.tr(),
                ),
              ],
              trailing: const ZagIconButton.arrow(),
              onTap: () async {
                List _values = await ReadarrDialogs.editMetadataProfile(
                    context, _metadataProfiles.values.toList());
                if (_values[0])
                  ReadarrDatabase.ADD_AUTHOR_DEFAULT_METADATA_PROFILE_ID
                      .update(_values[1].id);
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _addBook() async {
    ReadarrAPI _api = ReadarrAPI.from(ZagProfile.forModule('readarr'));
    bool? search =
        ReadarrDatabase.ADD_AUTHOR_SEARCH_FOR_MISSING_BOOKS.read();

    final rootFolderId =
        ReadarrDatabase.ADD_AUTHOR_DEFAULT_ROOT_FOLDER_ID.read();
    final qualityProfileId =
        ReadarrDatabase.ADD_AUTHOR_DEFAULT_QUALITY_PROFILE_ID.read();
    final metadataProfileId =
        ReadarrDatabase.ADD_AUTHOR_DEFAULT_METADATA_PROFILE_ID.read();

    final rootFolder = _rootFolders.cast<ReadarrRootFolder?>().firstWhere(
      (f) => f?.id == rootFolderId,
      orElse: () => null,
    );
    final qualityProfile = _qualityProfiles[qualityProfileId];
    final metadataProfile = _metadataProfiles[metadataProfileId];

    if (rootFolder == null || qualityProfile == null || metadataProfile == null) {
      showZagErrorSnackBar(
        title: 'readarr.FailedToAddBook'.tr(),
        message: 'readarr.MissingRequiredConfiguration'.tr(),
      );
      return;
    }

    await _api
        .addBook(
      widget.data!,
      qualityProfile,
      rootFolder,
      metadataProfile,
      ReadarrMonitorStatus.ALL.fromKey(
              ReadarrDatabase.ADD_AUTHOR_DEFAULT_MONITOR_NEW_ITEMS.read()) ??
          ReadarrMonitorStatus.ALL,
      search: search,
    )
        .then((id) {
      showZagSuccessSnackBar(
        title: 'readarr.BookAdded'.tr(),
        message: widget.data!.displayTitle,
      );
      ZagRouter.router.pop();
    }).catchError((error, stack) {
      ZagLogger().error('Failed to add book', error, stack);
      showZagErrorSnackBar(
        title: search
            ? 'readarr.FailedToAddBookWithSearch'.tr()
            : 'readarr.FailedToAddBook'.tr(),
        error: error,
      );
    });
  }
}
