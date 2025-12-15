import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrAddMovieDetailsTagsTile extends StatelessWidget {
  const RadarrAddMovieDetailsTagsTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'radarr.Tags'.tr(),
      body: [
        TextSpan(
          text: context.watch<RadarrAddMovieDetailsState>().tags.isEmpty
              ? ZagUI.TEXT_EMDASH
              : context
                  .watch<RadarrAddMovieDetailsState>()
                  .tags
                  .map((e) => e.label)
                  .join(', '),
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async => await RadarrDialogs().setAddTags(context),
    );
  }
}
