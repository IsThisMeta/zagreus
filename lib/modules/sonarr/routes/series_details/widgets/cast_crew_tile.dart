import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/modules/discover/routes/person_details/route.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class SonarrSeriesDetailsCastCrewTile extends StatelessWidget {
  final SonarrSeriesCredits credits;

  const SonarrSeriesDetailsCastCrewTile({
    Key? key,
    required this.credits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: credits.personName,
      posterPlaceholderIcon: ZagIcons.USER,
      posterUrl: TMDBApi.getImageUrl(credits.profilePath, size: 'w185'),
      body: [
        TextSpan(text: _position),
        TextSpan(
          text: credits.type == 'cast'
              ? 'sonarr.Cast'.tr()
              : 'sonarr.Crew'.tr(),
          style: TextStyle(
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: credits.type == 'cast'
                ? ZagColours.accent
                : ZagColours.orange,
          ),
        ),
      ],
      onTap: credits.personTmdbId != null
          ? () {
              if (ZagreusPro.isEnabled) {
                // Pro users: Navigate to internal person details page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PersonDetailsRoute(
                      personId: credits.personTmdbId!,
                      personName: credits.personName ?? '',
                    ),
                  ),
                );
              } else {
                // Free users: Open TMDB person page in in-app browser
                credits.personTmdbId.toString().openTmdbPersonInApp();
              }
            }
          : null,
    );
  }

  String? get _position {
    if (credits.type == 'cast') {
      return credits.character?.isEmpty ?? true
          ? ZagUI.TEXT_EMDASH
          : credits.character;
    } else {
      return credits.job?.isEmpty ?? true ? ZagUI.TEXT_EMDASH : credits.job;
    }
  }
}
