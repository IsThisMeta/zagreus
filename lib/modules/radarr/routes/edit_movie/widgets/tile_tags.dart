import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrMoviesEditTagsTile extends StatelessWidget {
  const RadarrMoviesEditTagsTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<RadarrTag> _tags = context.watch<RadarrMoviesEditState>().tags;
    return ZagBlock(
      title: 'radarr.Tags'.tr(),
      body: [
        TextSpan(
          text: _tags.isEmpty
              ? ZagUI.TEXT_EMDASH
              : _tags.map((e) => e.label).join(', '),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async => await RadarrDialogs().setEditTags(context),
    );
  }
}
