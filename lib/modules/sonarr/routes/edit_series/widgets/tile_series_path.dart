import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrSeriesEditSeriesPathTile extends StatelessWidget {
  const SonarrSeriesEditSeriesPathTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'sonarr.SeriesPath'.tr(),
      body: [
        TextSpan(
          text: context.watch<SonarrSeriesEditState>().seriesPath,
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async => _onTap(context),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    final state = context.read<SonarrSeriesEditState>();
    final originalPath = state.seriesPath;

    bool confirmed = false;
    final formKey = GlobalKey<FormState>();
    final textController = TextEditingController()..text = originalPath;
    bool moveFiles = state.moveFiles;

    void setValues(bool flag) {
      if (formKey.currentState?.validate() ?? false) {
        confirmed = flag;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    await ZagDialog.dialog(
      context: context,
      title: 'sonarr.SeriesPath'.tr(),
      buttons: [
        ZagDialog.button(
          text: 'Save',
          onPressed: () => setValues(true),
        ),
      ],
      content: [
        Form(
          key: formKey,
          child: ZagDialog.textFormInput(
            controller: textController,
            title: 'sonarr.SeriesPath'.tr(),
            onSubmitted: (_) => setValues(true),
            validator: (_) => null,
          ),
        ),
        StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  Checkbox(
                    value: moveFiles,
                    onChanged: (value) {
                      setState(() => moveFiles = value ?? false);
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => moveFiles = !moveFiles);
                      },
                      child: Text(
                        'sonarr.MoveFiles'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
      contentPadding: ZagDialog.inputDialogContentPadding(),
    );

    if (confirmed) {
      state.seriesPath = textController.text;
      state.moveFiles = moveFiles;
    }
  }
}
