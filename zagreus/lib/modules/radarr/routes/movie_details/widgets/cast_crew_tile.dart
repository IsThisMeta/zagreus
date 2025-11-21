import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/modules/discover/routes/person_details/route.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class RadarrMovieDetailsCastCrewTile extends StatelessWidget {
  final RadarrMovieCredits credits;

  const RadarrMovieDetailsCastCrewTile({
    Key? key,
    required this.credits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: credits.personName,
      posterPlaceholderIcon: ZagIcons.USER,
      posterUrl: credits.images!.isEmpty
          ? null
          : (credits.images![0].remoteUrl ?? credits.images![0].url),
      body: [
        TextSpan(text: _position),
        TextSpan(
          text: credits.type!.readable,
          style: TextStyle(
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: credits.type == RadarrCreditType.CAST
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
                // Free users: Open TMDB person page externally
                credits.personTmdbId.toString().openTmdbPerson();
              }
            }
          : null,
    );
  }

  String? get _position {
    switch (credits.type) {
      case RadarrCreditType.CREW:
        return credits.job!.isEmpty ? ZagUI.TEXT_EMDASH : credits.job;
      case RadarrCreditType.CAST:
        return credits.character!.isEmpty
            ? ZagUI.TEXT_EMDASH
            : credits.character;
      default:
        return ZagUI.TEXT_EMDASH;
    }
  }
}
