import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrAddSeriesDetailsSearchForCutoffTile extends StatelessWidget {
  const SonarrAddSeriesDetailsSearchForCutoffTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SonarrDatabase.ADD_SERIES_SEARCH_FOR_CUTOFF_UNMET.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'sonarr.StartSearchForCutoffUnmetEpisodes'.tr(),
        trailing: ZagSwitch(
          value: SonarrDatabase.ADD_SERIES_SEARCH_FOR_CUTOFF_UNMET.read(),
          onChanged: (value) =>
              SonarrDatabase.ADD_SERIES_SEARCH_FOR_CUTOFF_UNMET.update(value),
        ),
      ),
    );
  }
}