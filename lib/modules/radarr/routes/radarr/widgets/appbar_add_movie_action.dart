import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/router/routes/radarr.dart';

class RadarrAppBarAddMoviesAction extends StatelessWidget {
  const RadarrAppBarAddMoviesAction({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagIconButton(
      icon: Icons.add_rounded,
      iconSize: ZagUI.ICON_SIZE,
      onPressed: RadarrRoutes.ADD_MOVIE.go,
    );
  }
}
