import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrMoviesEditPathTile extends StatelessWidget {
  const RadarrMoviesEditPathTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<RadarrMoviesEditState, String>(
      selector: (_, state) => state.path,
      builder: (context, path, _) => ZagBlock(
        title: 'radarr.MoviePath'.tr(),
        body: [TextSpan(text: path)],
        trailing: const ZagIconButton.arrow(),
        onTap: () async => _onTap(context, path),
      ),
    );
  }

  Future<void> _onTap(BuildContext context, String currentPath) async {
    final state = context.read<RadarrMoviesEditState>();
    final originalPath = currentPath;

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
      title: 'radarr.MoviePath'.tr(),
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
            title: 'radarr.MoviePath'.tr(),
            onSubmitted: (_) => setValues(true),
            validator: (_) => null,
          ),
        ),
        StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: GestureDetector(
                onTap: () {
                  setState(() => moveFiles = !moveFiles);
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'radarr.MoveFiles'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: moveFiles,
                      onChanged: (value) {
                        setState(() => moveFiles = value ?? false);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
      contentPadding: ZagDialog.inputDialogContentPadding(),
    );

    if (confirmed) {
      state.path = textController.text;
      state.moveFiles = moveFiles;
    }
  }
}
