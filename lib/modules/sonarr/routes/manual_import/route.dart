import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrManualImportRoute extends StatefulWidget {
  const SonarrManualImportRoute({
    Key? key,
  }) : super(key: key);

  @override
  State<SonarrManualImportRoute> createState() => _State();
}

class _State extends State<SonarrManualImportRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SonarrManualImportState(context),
      builder: (context, _) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar(),
        body: _body(context),
        bottomNavigationBar: const SonarrManualImportBottomActionBar(),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'sonarr.ManualImport'.tr(),
      scrollControllers: [scrollController],
      // Hide the endDrawer icon while keeping drawer accessible via swipe
      actions: const [SizedBox.shrink()],
      bottom: ZagAppBar.empty(
        height: ZagTextInputBar.defaultAppBarHeight,
        child: SonarrManualImportPathBar(scrollController: scrollController),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return FutureBuilder(
      future:
          context.select<SonarrManualImportState, Future<SonarrFileSystem>?>(
              (state) => state.directories),
      builder: (context, AsyncSnapshot<SonarrFileSystem> snapshot) {
        if (snapshot.hasError) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            ZagLogger().error(
              'Unable to fetch Sonarr filesystem',
              snapshot.error,
              snapshot.stackTrace,
            );
          }
          return ZagMessage.error(onTap: () {
            context.read<SonarrManualImportState>().fetchDirectories(
                  context,
                  context.read<SonarrManualImportState>().currentPath,
                );
          });
        }
        if (snapshot.hasData) return _list(context, snapshot.data);
        return const ZagLoader();
      },
    );
  }

  Widget _list(BuildContext context, SonarrFileSystem? fileSystem) {
    if ((fileSystem?.directories?.length ?? 0) == 0 &&
        (fileSystem!.parent == null || fileSystem.parent!.isEmpty)) {
      return ZagMessage(
        text: 'sonarr.NoSubdirectoriesFound'.tr(),
      );
    }
    return Selector<SonarrManualImportState, String?>(
      selector: (_, state) => state.currentPath,
      builder: (context, path, _) {
        List<SonarrFileSystemDirectory> directories =
            _filterDirectories(path, fileSystem);
        return ZagListView(
          key: ObjectKey(fileSystem!.directories),
          controller: scrollController,
          children: [
            SonarrManualImportParentDirectoryTile(fileSystem: fileSystem),
            ...List.generate(
              directories.length,
              (index) => SonarrManualImportDirectoryTile(
                  directory: directories[index]),
            ),
          ],
        );
      },
    );
  }

  List<SonarrFileSystemDirectory> _filterDirectories(
    String? path,
    SonarrFileSystem? fileSystem,
  ) {
    if (path == null || path.isEmpty) {
      return fileSystem!.directories ?? [];
    }
    if (fileSystem?.directories == null || fileSystem!.directories!.isEmpty) {
      return [];
    }
    return fileSystem.directories!
        .where(
          (element) =>
              (element.path?.toLowerCase() ?? '').contains(path.toLowerCase()),
        )
        .toList();
  }
}
