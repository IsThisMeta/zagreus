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
    if (!context.mounted) return;

    final state = context.read<SonarrManualImportDetailsState>();
    if (!state.canExecuteAction || state.loadingState != ZagLoadingState.INACTIVE) {
      return;
    }

    try {
      List<SonarrManualImport> imports = await state.manualImport!;
      imports = imports
          .where((import) => state.selectedFiles.contains(import.id))
          .toList();

      if (imports.isEmpty) {
        showZagInfoSnackBar(
          title: 'Nothing Selected',
          message: 'Please select at least one file to import',
        );
        return;
      }

      bool allValid = true;
      final files = <SonarrManualImportFile>[];
      for (final import in imports) {
        if (!allValid) break;
        final built = SonarrAPIController().buildManualImportFile(import: import);
        if (built.item1 != null) {
          files.add(built.item1!);
        } else {
          showZagInfoSnackBar(title: 'Invalid Inputs', message: built.item2);
          allValid = false;
        }
      }

      if (!allValid) return;
      if (!context.mounted) return;

      state.loadingState = ZagLoadingState.ACTIVE;

      final ok = await SonarrAPIController().triggerManualImport(
        context: context,
        files: files,
        importMode: SonarrImportMode.COPY
            .from((SonarrDatabase.MANUAL_IMPORT_DEFAULT_MODE.read()))!,
      );

      if (!context.mounted) return;

      if (ok) {
        Navigator.of(context).pop();
      } else {
        state.loadingState = ZagLoadingState.INACTIVE;
      }
    } catch (e, stack) {
      ZagLogger().error('Manual import failed unexpectedly', e, stack);
      if (!context.mounted) return;
      state.loadingState = ZagLoadingState.ERROR;
      showZagErrorSnackBar(title: 'Failed to Import', error: e);
    }
  }
}
