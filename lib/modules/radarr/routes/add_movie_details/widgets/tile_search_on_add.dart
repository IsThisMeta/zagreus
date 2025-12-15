import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrAddMovieDetailsSearchOnAddTile extends StatelessWidget {
  const RadarrAddMovieDetailsSearchOnAddTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RadarrDatabase.ADD_MOVIE_SEARCH_FOR_MISSING.listenableBuilder(
      builder: (context, _) => ZagBlock(
        title: 'radarr.StartSearchForMissingMovie'.tr(),
        trailing: ZagSwitch(
          value: RadarrDatabase.ADD_MOVIE_SEARCH_FOR_MISSING.read(),
          onChanged: (value) =>
              RadarrDatabase.ADD_MOVIE_SEARCH_FOR_MISSING.update(value),
        ),
      ),
    );
  }
}