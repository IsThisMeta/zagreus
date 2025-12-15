import 'package:flutter/material.dart';

import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/modules/dashboard/core/api/data/abstract.dart';
import 'package:zagreus/modules/dashboard/core/api/data/lidarr.dart';
import 'package:zagreus/modules/dashboard/core/api/data/radarr.dart';
import 'package:zagreus/modules/dashboard/core/api/data/sonarr.dart';

class ContentBlock extends StatelessWidget {
  final CalendarData data;
  const ContentBlock(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headers = getHeaders();
    final disabled = _isDisabled();
    return ZagBlock(
      title: data.title,
      body: data.body,
      posterHeaders: headers,
      backgroundHeaders: headers,
      posterUrl: data.posterUrl(context),
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      backgroundUrl: data.backgroundUrl(context),
      trailing: data.trailing(context),
      onTap: () async => data.enterContent(context),
      disabled: disabled,
    );
  }

  Map getHeaders() {
    switch (data.runtimeType) {
      case CalendarLidarrData:
        return ZagProfile.current.lidarrHeaders;
      case CalendarRadarrData:
        return ZagProfile.current.radarrHeaders;
      case CalendarSonarrData:
        return ZagProfile.current.sonarrHeaders;
      default:
        return const {};
    }
  }

  bool _isDisabled() {
    switch (data.runtimeType) {
      case CalendarRadarrData:
        return !(data as CalendarRadarrData).monitored;
      case CalendarSonarrData:
        return !(data as CalendarSonarrData).monitored;
      default:
        return false;
    }
  }
}
