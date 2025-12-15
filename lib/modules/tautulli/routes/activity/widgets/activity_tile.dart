import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/tautulli.dart';
import 'package:zagreus/router/routes/tautulli.dart';

class TautulliActivityTile extends StatelessWidget {
  final TautulliSession session;
  final bool disableOnTap;

  const TautulliActivityTile({
    Key? key,
    required this.session,
    this.disableOnTap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: session.zagTitle,
      posterUrl: session.zagArtworkPath(context),
      posterHeaders: context.read<TautulliState>().headers,
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      backgroundUrl: context.watch<TautulliState>().getImageURLFromPath(
            session.art,
            width: MediaQuery.of(context).size.width.truncate(),
          ),
      body: [
        _subtitle1(),
        _subtitle2(),
        _subtitle3(),
      ],
      bottom: _bottomWidget(),
      bottomHeight: ZagLinearPercentIndicator.height,
      trailing: ZagIconButton(icon: session.zagSessionStateIcon),
      onTap: disableOnTap ? null : () async => _enterDetails(context),
    );
  }

  TextSpan _subtitle1() {
    if (session.mediaType == TautulliMediaType.EPISODE) {
      return TextSpan(
        children: [
          TextSpan(text: session.parentTitle),
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(
              text: 'tautulli.Episode'.tr(args: [
            session.mediaIndex?.toString() ?? ZagUI.TEXT_EMDASH
          ])),
          TextSpan(text: ': '),
          TextSpan(
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
            text: session.title ?? ZagUI.TEXT_EMDASH,
          ),
        ],
      );
    }
    if (session.mediaType == TautulliMediaType.MOVIE) {
      return TextSpan(text: session.year.toString());
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
    if (session.mediaType == TautulliMediaType.LIVE) {
      return TextSpan(text: session.title);
    }
    return TextSpan(text: ZagUI.TEXT_EMDASH);
  }

  TextSpan _subtitle2() {
    return TextSpan(text: session.zagFriendlyName);
  }

  TextSpan _subtitle3() {
    return TextSpan(
      text: session.formattedStream(),
      style: TextStyle(
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        color: ZagColours.currentAccent,
      ),
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
}
