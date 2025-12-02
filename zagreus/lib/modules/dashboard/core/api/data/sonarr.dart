import 'package:flutter/material.dart';
import 'package:zagreus/database/box.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/database/tables/zagreus.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/router/routes/sonarr.dart';

import 'package:zagreus/system/logger.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/vendor.dart';
import 'package:zagreus/modules/sonarr/core/state.dart';
import 'package:zagreus/modules/dashboard/core/api/data/abstract.dart';

class CalendarSonarrData extends CalendarData {
  String episodeTitle;
  int seasonNumber;
  int episodeNumber;
  int seriesID;
  String airTime;
  bool hasFile;
  String? fileQualityProfile;
  bool monitored;
  int runtime;

  CalendarSonarrData({
    required int id,
    required String title,
    required this.episodeTitle,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.seriesID,
    required this.airTime,
    required this.hasFile,
    required this.fileQualityProfile,
    required this.monitored,
    this.runtime = 0,
    String? instanceKey,
  }) : super(id, title, instanceKey: instanceKey);

  @override
  List<TextSpan> get body {
    final released = hasAired;
    final onAir = isOnAir;
    return [
      TextSpan(
        children: [
          TextSpan(
              text: seasonNumber == 0 ? 'Specials' : 'Season $seasonNumber'),
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(text: 'Episode $episodeNumber'),
        ],
      ),
      TextSpan(
        style: TextStyle(
          fontStyle: FontStyle.italic,
        ),
        text: episodeTitle,
      ),
      if (!hasFile && onAir)
        TextSpan(
          text: 'sonarr.OnAir'.tr(),
          style: TextStyle(
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: ZagColours.orange.withOpacity(
              monitored ? 1.0 : ZagUI.OPACITY_DISABLED,
            ),
          ),
        ),
      if (!hasFile && !onAir)
        TextSpan(
          text: released ? 'sonarr.Missing'.tr() : 'sonarr.Unaired'.tr(),
          style: TextStyle(
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: (released ? ZagColours.red : ZagColours.blue).withOpacity(
              monitored ? 1.0 : ZagUI.OPACITY_DISABLED,
            ),
          ),
        ),
      if (hasFile)
        TextSpan(
          text: 'Downloaded ($fileQualityProfile)',
          style: TextStyle(
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: ZagColours.currentAccent,
          ),
        ),
    ];
  }

  bool get hasAired {
    if (airTimeObject != null) return DateTime.now().isAfter(airTimeObject!);
    return false;
  }

  /// Returns true if the episode is currently airing (between start and end time)
  bool get isOnAir {
    if (airTimeObject == null || runtime <= 0) return false;
    final now = DateTime.now();
    final endTime = airTimeObject!.add(Duration(minutes: runtime));
    return now.isAfter(airTimeObject!) && now.isBefore(endTime);
  }

  @override
  Future<void> enterContent(BuildContext context) async {
    // Set instance context before navigating
    if (instanceKey != null) {
      ZagInstanceContext().setActiveInstance('sonarr', instanceKey);
    } else {
      ZagInstanceContext().clearActiveInstance('sonarr');
    }
    // Reset state to load from correct profile
    context.read<SonarrState>().reset();
    SonarrRoutes.SERIES.go(params: {'series': seriesID.toString()});
  }

  @override
  Widget trailing(BuildContext context) => ZagIconButton(
        text: airTimeString,
        onPressed: () async => trailingOnPress(context),
        onLongPress: () => trailingOnLongPress(context),
      );

  DateTime? get airTimeObject {
    return DateTime.tryParse(airTime)?.toLocal();
  }

  String get airTimeString {
    if (airTimeObject != null) {
      return ZagreusDatabase.USE_24_HOUR_TIME.read()
          ? DateFormat.Hm().format(airTimeObject!)
          : DateFormat('hh:mm\na').format(airTimeObject!);
    }
    return 'Unknown';
  }

  @override
  Future<void> trailingOnPress(BuildContext context) async {
    if (context.read<SonarrState>().api != null)
      context
          .read<SonarrState>()
          .api!
          .command
          .episodeSearch(episodeIds: [id])
          .then((_) => showZagSuccessSnackBar(
                title: 'Searching for Episode...',
                message: episodeTitle,
              ))
          .catchError((error, stack) {
            ZagLogger().error(
              'Failed to search for episode: $id',
              error,
              stack,
            );
            showZagErrorSnackBar(
              title: 'Failed to Search',
              error: error,
            );
          });
  }

  @override
  Future<void> trailingOnLongPress(BuildContext context) async {
    SonarrRoutes.RELEASES.go(queryParams: {
      'episode': id.toString(),
    });
  }

  @override
  String? backgroundUrl(BuildContext context) {
    // For shadow instances, we need to build URL from the instance profile
    if (instanceKey != null) {
      final profile = ZagBox.profiles.read(instanceKey!);
      if (profile != null) {
        return _buildFanartUrl(profile);
      }
    }
    return context.read<SonarrState>().getFanartURL(this.seriesID);
  }

  @override
  String? posterUrl(BuildContext context) {
    // For shadow instances, we need to build URL from the instance profile
    if (instanceKey != null) {
      final profile = ZagBox.profiles.read(instanceKey!);
      if (profile != null) {
        return _buildPosterUrl(profile);
      }
    }
    return context.read<SonarrState>().getPosterURL(this.seriesID);
  }
  
  String? _buildFanartUrl(ZagProfile profile) {
    final host = profile.effectiveSonarrHost();
    final key = profile.sonarrKey;
    if (host.isEmpty) return null;
    final baseUrl = host.endsWith('/') 
        ? '${host}api/v3/MediaCover' 
        : '$host/api/v3/MediaCover';
    return '$baseUrl/$seriesID/fanart-360.jpg?apikey=$key';
  }
  
  String? _buildPosterUrl(ZagProfile profile) {
    final host = profile.effectiveSonarrHost();
    final key = profile.sonarrKey;
    if (host.isEmpty) return null;
    final baseUrl = host.endsWith('/') 
        ? '${host}api/v3/MediaCover' 
        : '$host/api/v3/MediaCover';
    return '$baseUrl/$seriesID/poster-500.jpg?apikey=$key';
  }
}
