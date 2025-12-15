import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliActivityStatus extends StatelessWidget {
  final TautulliActivity? activity;

  const TautulliActivityStatus({
    required this.activity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagHeader(
      text: activity!.zagSessionsHeader,
      subtitle: [
        activity!.zagSessions,
        activity!.zagBandwidth,
      ].join('\n'),
    );
  }
}
