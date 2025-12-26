import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/tautulli.dart';
import 'package:zagreus/router/routes/tautulli.dart';

class TautulliStreamCard extends StatelessWidget {
  static final itemExtent = ZagBlock.calculateItemExtent(2, hasBottom: true);

  final TautulliSession session;

  const TautulliStreamCard({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      key: ObjectKey(session),
      title: session.zagTitle,
      posterUrl: session.zagArtworkPath(context),
      posterHeaders: context.read<TautulliState>().headers,
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      onPosterTap: session.ratingKey != null && session.mediaType != null
          ? () => _enterMediaDetails(context)
          : null,
      backgroundUrl: context.watch<TautulliState>().getImageURLFromPath(
            session.art,
            width: MediaQuery.of(context).size.width.truncate(),
          ),
      body: [
        _subtitle1(),
        _subtitle2(),
      ],
      bottom: _bottomWidget(),
      bottomHeight: ZagLinearPercentIndicator.height,
      trailing: ZagIconButton(icon: session.zagSessionStateIcon),
      onTap: () => _enterDetails(context),
    );
  }

  TextSpan _subtitle1() {
    if (session.mediaType == TautulliMediaType.EPISODE) {
      return TextSpan(
        children: [
          TextSpan(text: session.parentTitle),
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(text: session.title ?? ZagUI.TEXT_EMDASH),
        ],
      );
    }
    if (session.mediaType == TautulliMediaType.MOVIE) {
      return TextSpan(text: session.year?.toString() ?? '');
    }
    if (session.mediaType == TautulliMediaType.TRACK) {
      return TextSpan(
        children: [
          TextSpan(text: session.parentTitle),
          TextSpan(text: ZagUI.TEXT_EMDASH.pad()),
          TextSpan(
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
            text: session.title,
          ),
        ],
      );
    }
    return TextSpan(text: session.title ?? ZagUI.TEXT_EMDASH);
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(text: session.zagFriendlyName),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(
          text: session.formattedStream(),
          style: TextStyle(
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: ZagColours.currentAccent,
          ),
        ),
      ],
    );
  }

  Widget _bottomWidget() {
    return SizedBox(
      height: ZagLinearPercentIndicator.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ZagLinearPercentIndicator(
            percent: session.zagTranscodeProgress,
            progressColor: ZagColours.currentAccent.withOpacity(
              ZagUI.OPACITY_SPLASH,
            ),
            backgroundColor: Colors.transparent,
          ),
          ZagLinearPercentIndicator(
            percent: session.zagProgressPercent,
            progressColor: ZagColours.currentAccent,
            backgroundColor: ZagColours.grey.withOpacity(
              ZagUI.OPACITY_SPLASH,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enterDetails(BuildContext context) async {
    TautulliRoutes.ACTIVITY_DETAILS.go(params: {
      'session': session.sessionKey.toString(),
    });
  }

  void _enterMediaDetails(BuildContext context) {
    TautulliRoutes.MEDIA_DETAILS.go(params: {
      'rating_key': session.ratingKey.toString(),
      'media_type': session.mediaType!.value,
    });
  }
}
