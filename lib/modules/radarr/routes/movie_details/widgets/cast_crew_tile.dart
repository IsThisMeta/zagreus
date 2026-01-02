import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
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
    final position = _position(context);
    final typeLabel = _typeLabel(context);
    return ZagBlock(
      title: credits.personName,
      posterPlaceholderIcon: ZagIcons.USER,
      posterUrl: credits.images!.isEmpty
          ? null
          : (credits.images![0].remoteUrl ?? credits.images![0].url),
      body: [
        TextSpan(text: position),
        TextSpan(
          text: typeLabel,
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
                // Free users: Open TMDB person page in in-app browser
                credits.personTmdbId.toString().openTmdbPersonInApp();
              }
            }
          : null,
    );
  }

  String _typeLabel(BuildContext context) {
    switch (credits.type) {
      case RadarrCreditType.CAST:
        return 'radarr.Cast'.tr();
      case RadarrCreditType.CREW:
        return 'radarr.Crew'.tr();
      default:
        return ZagUI.TEXT_EMDASH;
    }
  }

  String? _position(BuildContext context) {
    switch (credits.type) {
      case RadarrCreditType.CREW:
        return _crewJobLabel(context);
      case RadarrCreditType.CAST:
        return credits.character!.isEmpty
            ? ZagUI.TEXT_EMDASH
            : credits.character;
      default:
        return ZagUI.TEXT_EMDASH;
    }
  }

  String _crewJobLabel(BuildContext context) {
    final job = credits.job;
    if (job == null || job.isEmpty) return ZagUI.TEXT_EMDASH;
    switch (job.toLowerCase()) {
      case 'director':
        return 'radarr.CreditJobDirector'.tr();
      case 'producer':
        return 'radarr.CreditJobProducer'.tr();
      case 'screenplay':
        return 'radarr.CreditJobScreenplay'.tr();
      default:
        return job;
    }
  }
}
