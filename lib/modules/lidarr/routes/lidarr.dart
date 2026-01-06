import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/router/routes/lidarr.dart';
import 'package:zagreus/modules/lidarr/routes/queue.dart';

class LidarrRoute extends StatefulWidget {
  const LidarrRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<LidarrRoute> createState() => _State();
}

class _State extends State<LidarrRoute> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ZagPageController? _pageController;
  String _profileState = ZagProfile.forModule('lidarr').toString();
  LidarrAPI _api = LidarrAPI.from(ZagProfile.forModule('lidarr'));

  final List _refreshKeys = [
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
    GlobalKey<RefreshIndicatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    print('🔍 LidarrRoute initState() called');

    final initialPage = LidarrDatabase.NAVIGATION_INDEX.read();
    print('🔍 Loaded initial index: $initialPage');

    _pageController = ZagPageController(initialPage: initialPage);

    print('🔍 Page controller created with initialPage: $initialPage');

    // Inject global cube overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZagGlobalCubeManager.instance.injectCube(context);
    });
  }

  @override
  void deactivate() {
    print('🔍 LidarrRoute deactivate() called');
    super.deactivate();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      module: ZagModule.LIDARR,
      body: _body(),
      drawer: _drawer(),
      appBar: _appBar() as PreferredSizeWidget?,
      bottomNavigationBar: _bottomNavigationBar(),
      onProfileChange: (_) {
        if (_profileState != ZagProfile.forModule('lidarr').toString()) _refreshProfile();
      },
    );
  }

  Widget _drawer() => ZagDrawer(page: ZagModule.LIDARR.key);

  Widget? _bottomNavigationBar() {
    if (ZagProfile.forModule('lidarr').lidarrEnabled)
      return LidarrNavigationBar(pageController: _pageController);
    return null;
  }

  Widget _body() {
    if (!ZagProfile.forModule('lidarr').lidarrEnabled)
      return ZagMessage.moduleNotEnabled(
        context: context,
        module: ZagModule.LIDARR.title,
      );
    return ZagPageView(
      controller: _pageController,
      children: [
        LidarrCatalogue(
          refreshIndicatorKey: _refreshKeys[0],
          refreshAllPages: _refreshAllPages,
        ),
        LidarrMissing(
          refreshIndicatorKey: _refreshKeys[1],
          refreshAllPages: _refreshAllPages,
        ),
        LidarrHistory(
          refreshIndicatorKey: _refreshKeys[2],
          refreshAllPages: _refreshAllPages,
        ),
        LidarrQueueRoute(
          embedInNavigation: true,
          scrollController: LidarrNavigationBar.scrollControllers[3],
          openDownloadsDrawer: _openQueueDrawer,
        ),
      ],
    );
  }

  Widget _appBar() {
    // Get current profile and its lidarr instances only
    final currentProfile = ZagreusDatabase.ENABLED_PROFILE.read();
    final instances = ZagProfile.getInstancesForModule(currentProfile, 'lidarr');
    
    // Build list: main profile first, then shadow instances
    List<String> profiles = [];
    if (ZagBox.profiles.read(currentProfile)?.lidarrEnabled ?? false) {
      profiles.add(currentProfile);
    }
    profiles.addAll(instances);
    
    List<Widget>? actions;
    if (ZagProfile.forModule('lidarr').lidarrEnabled)
      actions = [
        ZagIconButton(
          icon: Icons.add_rounded,
          onPressed: () async => _enterAddArtist(),
        ),
        ZagIconButton(
          icon: Icons.more_vert_rounded,
          onPressed: () async => _handlePopup(),
        ),
      ];
    
    final instanceName = ZagProfile.getActiveInstanceName('lidarr');
    final title = instanceName != null 
        ? '${ZagModule.LIDARR.title} $instanceName'
        : ZagModule.LIDARR.title;
    
    return ZagAppBar.dropdown(
      title: title,
      useDrawer: true,
      profiles: profiles,
      actions: actions,
      pageController: _pageController,
      scrollControllers: LidarrNavigationBar.scrollControllers,
      onProfileSelected: (selected) {
        final parsed = ZagProfile.parseShadowKey(selected);
        if (parsed != null) {
          ZagInstanceContext().setActiveInstance('lidarr', selected);
        } else {
          ZagInstanceContext().clearActiveInstance('lidarr');
        }
        setState(() {});
        context.read<LidarrState>().reset();
      },
    );
  }

  List<Widget> _buildQueueDrawerAction() {
    return [];
  }

  void _openQueueDrawer() {
    final scaffoldState = _scaffoldKey.currentState;
    if (scaffoldState?.hasEndDrawer ?? false) {
      scaffoldState?.openEndDrawer();
    }
  }

  Future<void> _enterAddArtist() async {
    final _model = Provider.of<LidarrState>(context, listen: false);
    _model.addSearchQuery = '';
    LidarrRoutes.ADD_ARTIST.go();
  }

  Future<void> _handlePopup() async {
    List<dynamic> values = await LidarrDialogs.globalSettings(context);
    if (values[0])
      switch (values[1]) {
        case 'web_gui':
          ZagProfile profile = ZagProfile.forModule('lidarr');
          await profile.effectiveLidarrHost().openLink();
          break;
        case 'update_library':
          await _api
              .updateLibrary()
              .then((_) => showZagSuccessSnackBar(
                  title: 'lidarr.UpdatingLibrary'.tr(),
                  message: 'lidarr.UpdatingLibraryDescription'.tr()))
              .catchError((error) => showZagErrorSnackBar(
                  title: 'lidarr.FailedToUpdateLibrary'.tr(), error: error));
          break;
        case 'rss_sync':
          await _api
              .triggerRssSync()
              .then((_) => showZagSuccessSnackBar(
                  title: 'lidarr.RunningRssSync'.tr(),
                  message: 'lidarr.RunningRssSyncDescription'.tr()))
              .catchError((error) => showZagErrorSnackBar(
                  title: 'lidarr.FailedToRunRssSync'.tr(), error: error));
          break;
        case 'backup':
          await _api
              .triggerBackup()
              .then((_) => showZagSuccessSnackBar(
                  title: 'lidarr.BackingUpDatabase'.tr(),
                  message: 'lidarr.BackingUpDatabaseDescription'.tr()))
              .catchError((error) => showZagErrorSnackBar(
                  title: 'lidarr.FailedToBackupDatabase'.tr(), error: error));
          break;
        case 'missing_search':
          {
            List<dynamic> values =
                await LidarrDialogs.searchAllMissing(context);
            if (values[0])
              await _api
                  .searchAllMissing()
                  .then((_) => showZagSuccessSnackBar(
                      title: 'lidarr.Searching'.tr(),
                      message: 'lidarr.SearchAllMissingDescription'.tr()))
                  .catchError((error) => showZagErrorSnackBar(
                      title: 'lidarr.FailedToSearch'.tr(), error: error));
            break;
          }
        default:
          ZagLogger().warning('Unknown Case: ${values[1]}');
      }
  }

  void _refreshProfile() {
    _api = LidarrAPI.from(ZagProfile.forModule('lidarr'));
    _profileState = ZagProfile.forModule('lidarr').toString();
    _refreshAllPages();
  }

  void _refreshAllPages() {
    for (var key in _refreshKeys) key?.currentState?.show();
  }
}
