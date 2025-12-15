import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrSeriesAddDetailsMonitorTile extends StatelessWidget {
  const SonarrSeriesAddDetailsMonitorTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: 'sonarr.Monitor'.tr(),
      body: [
        TextSpan(
          text:
              context.watch<SonarrSeriesAddDetailsState>().monitorType.zagName,
        ),
      ],
      trailing: const ZagIconButton.arrow(),
      onTap: () async => _onTap(context),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    Tuple2<bool, SonarrSeriesMonitorType?> result =
        await SonarrDialogs().editMonitorType(context);
    if (result.item1) {
      context.read<SonarrSeriesAddDetailsState>().monitorType = result.item2!;
      SonarrDatabase.ADD_SERIES_DEFAULT_MONITOR_TYPE
          .update(result.item2!.value!);
    }
  }
}
