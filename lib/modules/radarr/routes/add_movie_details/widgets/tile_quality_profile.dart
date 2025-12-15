import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrAddMovieDetailsQualityProfileTile extends StatelessWidget {
  const RadarrAddMovieDetailsQualityProfileTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<RadarrAddMovieDetailsState, RadarrQualityProfile>(
      selector: (_, state) => state.qualityProfile,
      builder: (context, profile, _) => ZagBlock(
        title: 'radarr.QualityProfile'.tr(),
        body: [TextSpan(text: profile.name ?? ZagUI.TEXT_EMDASH)],
        trailing: const ZagIconButton.arrow(),
        onTap: () async {
          List<RadarrQualityProfile> qualityProfiles =
              await context.read<RadarrState>().qualityProfiles!;
          Tuple2<bool, RadarrQualityProfile?> values = await RadarrDialogs()
              .editQualityProfile(context, qualityProfiles);
          if (values.item1)
            context.read<RadarrAddMovieDetailsState>().qualityProfile =
                values.item2!;
        },
      ),
    );
  }
}
