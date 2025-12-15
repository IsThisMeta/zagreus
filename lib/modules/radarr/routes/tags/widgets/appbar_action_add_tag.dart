import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrTagsAppBarActionAddTag extends StatelessWidget {
  final bool asDialogButton;

  const RadarrTagsAppBarActionAddTag({
    Key? key,
    this.asDialogButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (asDialogButton)
      return ZagDialog.button(
        text: 'zagreus.Add'.tr(),
        textColor: Colors.white,
        onPressed: () async => _onPressed(context),
      );
    return ZagIconButton(
      icon: Icons.add_rounded,
      onPressed: () async => _onPressed(context),
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    Tuple2<bool, String> values = await RadarrDialogs().addNewTag(context);
    if (values.item1)
      RadarrAPIHelper()
          .addTag(context: context, label: values.item2)
          .then((value) {
        if (value) context.read<RadarrState>().fetchTags();
      });
  }
}
