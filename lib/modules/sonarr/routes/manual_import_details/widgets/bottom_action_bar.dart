import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrManualImportDetailsBottomActionBar extends StatelessWidget {
  const SonarrManualImportDetailsBottomActionBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBottomActionBar(
      actions: [
        SonarrDatabase.MANUAL_IMPORT_DEFAULT_MODE.listenableBuilder(
          builder: (context, _) => ZagActionBarCard(
            title: 'sonarr.ImportMode'.tr(),
            subtitle: SonarrImportMode.COPY
                .from((SonarrDatabase.MANUAL_IMPORT_DEFAULT_MODE.read()))!
                .zagReadable,
            //checkboxState: true,
            onTap: () async => _importModeOnTap(context),
          ),
        ),
        ZagButton(
          type: ZagButtonType.TEXT,
          text: 'sonarr.Import'.tr(),
          icon: Icons.download_done_rounded,
          loadingState:
              context.watch<SonarrManualImportDetailsState>().loadingState,
          onTap: () async => _importOnTap(context),
        ),
      ],
    );
  }

  Future<void> _importModeOnTap(BuildContext context) async {
    Tuple2<bool, SonarrImportMode?> result =
        await SonarrDialogs().setManualImportMode(context);
    if (result.item1)
      SonarrDatabase.MANUAL_IMPORT_DEFAULT_MODE.update(result.item2!.value);
  }

  Future<void> _importOnTap(BuildContext context) async {
    if (context.read<SonarrManualImportDetailsState>().canExecuteAction &&
        context.read<SonarrManualImportDetailsState>().loadingState ==
            ZagLoadingState.INACTIVE) {
      List<SonarrManualImport> _imports =
          await context.read<SonarrManualImportDetailsState>().manualImport!;
      _imports = _imports
          .where((import) => context
              .read<SonarrManualImportDetailsState>()
              .selectedFiles
              .contains(import.id))
          .toList();
      if (_imports.isEmpty) {
        showZagInfoSnackBar(
            title: 'Nothing Selected',
            message: 'Please select at least one file to import');
        return;
      }
      bool _allValid = true;
      List<SonarrManualImportFile> _files = [];
      _imports.forEach((import) {
        if (_allValid) {
          Tuple2<SonarrManualImportFile?, String?> _file =
              SonarrAPIController().buildManualImportFile(import: import);
          if (_file.item1 != null) {
            _files.add(_file.item1!);
          } else {
            showZagInfoSnackBar(title: 'Invalid Inputs', message: _file.item2);
            _allValid = false;
          }
        }
      });
      if (_allValid) {
        context.read<SonarrManualImportDetailsState>().loadingState =
            ZagLoadingState.ACTIVE;
        await SonarrAPIController()
            .triggerManualImport(
              context: context,
              files: _files,
              importMode: SonarrImportMode.COPY
                  .from((SonarrDatabase.MANUAL_IMPORT_DEFAULT_MODE.read()))!,
            )
            .then((result) => result
                ? Navigator.of(context).pop()
                : context.read<SonarrManualImportDetailsState>().loadingState =
                    ZagLoadingState.INACTIVE)
            .catchError((_) => context
                .read<SonarrManualImportDetailsState>()
                .loadingState = ZagLoadingState.ERROR);
      }
    }
  }
}
