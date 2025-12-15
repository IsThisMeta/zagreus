import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrMediaInfoSheet extends ZagBottomModalSheet {
  final SonarrEpisodeFileMediaInfo? mediaInfo;

  SonarrMediaInfoSheet({
    required this.mediaInfo,
  });

  @override
  Widget builder(BuildContext context) {
    return ZagListViewModal(
      children: [
        ZagHeader(text: 'sonarr.Video'.tr()),
        ZagTableCard(
          content: [
            ZagTableContent(
              title: 'sonarr.BitDepth'.tr(),
              body: mediaInfo!.zagVideoBitDepth,
            ),
            ZagTableContent(
              title: 'sonarr.Bitrate'.tr(),
              body: mediaInfo!.zagVideoBitrate,
            ),
            ZagTableContent(
              title: 'sonarr.Codec'.tr(),
              body: mediaInfo!.zagVideoCodec,
            ),
            ZagTableContent(
              title: 'sonarr.FPS'.tr(),
              body: mediaInfo!.zagVideoFps,
            ),
            ZagTableContent(
              title: 'sonarr.Resolution'.tr(),
              body: mediaInfo!.zagVideoResolution,
            ),
            ZagTableContent(
              title: 'sonarr.ScanType'.tr(),
              body: mediaInfo!.zagVideoScanType,
            ),
          ],
        ),
        ZagHeader(text: 'sonarr.Audio'.tr()),
        ZagTableCard(
          content: [
            ZagTableContent(
              title: 'sonarr.Bitrate'.tr(),
              body: mediaInfo!.zagAudioBitrate,
            ),
            ZagTableContent(
              title: 'sonarr.Channels'.tr(),
              body: mediaInfo!.zagAudioChannels,
            ),
            ZagTableContent(
              title: 'sonarr.Codec'.tr(),
              body: mediaInfo!.zagAudioCodec,
            ),
            ZagTableContent(
              title: 'sonarr.Languages'.tr(),
              body: mediaInfo!.zagAudioLanguages,
            ),
            ZagTableContent(
              title: 'sonarr.Streams'.tr(),
              body: mediaInfo!.zagAudioStreamCount,
            ),
          ],
        ),
        ZagHeader(text: 'sonarr.Other'.tr()),
        ZagTableCard(
          content: [
            ZagTableContent(
              title: 'sonarr.Runtime'.tr(),
              body: mediaInfo!.zagRunTime,
            ),
            ZagTableContent(
              title: 'sonarr.Subtitles'.tr(),
              body: mediaInfo!.zagSubtitles,
            ),
          ],
        ),
      ],
    );
  }
}
