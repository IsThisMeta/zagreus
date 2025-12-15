import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrAddSeriesDetailsSearchForMissingTile extends StatelessWidget {
  const SonarrAddSeriesDetailsSearchForMissingTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SonarrDatabase.ADD_SERIES_SEARCH_FOR_MISSING.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'sonarr.StartSearchForMissingEpisodes'.tr(),
        trailing: ZagSwitch(
          value: SonarrDatabase.ADD_SERIES_SEARCH_FOR_MISSING.read(),
          onChanged: (value) =>
              SonarrDatabase.ADD_SERIES_SEARCH_FOR_MISSING.update(value),
        ),
      ),
    );
  }
}