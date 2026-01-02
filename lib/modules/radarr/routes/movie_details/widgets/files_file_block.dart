import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrMovieDetailsFilesFileBlock extends StatefulWidget {
  final RadarrMovieFile file;

  const RadarrMovieDetailsFilesFileBlock({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrMovieDetailsFilesFileBlock> {
  ZagLoadingState _deleteFileState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      content: [
        ZagTableContent(
          title: 'radarr.RelativePath'.tr(),
          body: widget.file.zagRelativePath,
        ),
        ZagTableContent(
          title: 'radarr.Video'.tr(),
          body: widget.file.mediaInfo?.zagVideoCodec,
        ),
        ZagTableContent(
          title: 'radarr.Audio'.tr(),
          body: [
            widget.file.mediaInfo?.zagAudioCodec,
            if (widget.file.mediaInfo?.audioChannels != null)
              widget.file.mediaInfo?.audioChannels.toString(),
          ].join(ZagUI.TEXT_BULLET.pad()),
        ),
        ZagTableContent(
          title: 'radarr.Size'.tr(),
          body: widget.file.zagSize,
        ),
        ZagTableContent(
          title: 'radarr.Languages'.tr(),
          body: widget.file.zagLanguage,
        ),
        ZagTableContent(
          title: 'radarr.Quality'.tr(),
          body: widget.file.zagQuality,
        ),
        ZagTableContent(
          title: 'radarr.Formats'.tr(),
          body: widget.file.zagCustomFormats,
        ),
        ZagTableContent(
          title: 'radarr.DateAdded'.tr(),
          body: widget.file.zagDateAdded,
        ),
      ],
      buttons: [
        if (widget.file.mediaInfo != null)
          ZagButton.text(
            text: 'radarr.MediaInfo'.tr(),
            icon: Icons.info_outline_rounded,
            onTap: () async => _viewMediaInfo(),
          ),
        ZagButton(
          type: ZagButtonType.TEXT,
          text: 'zagreus.Delete'.tr(),
          icon: Icons.delete_rounded,
          onTap: () async => _deleteFile(),
          color: ZagColours.red,
          loadingState: _deleteFileState,
        ),
      ],
    );
  }

  Future<void> _deleteFile() async {
    setState(() => _deleteFileState = ZagLoadingState.ACTIVE);
    bool result = await RadarrDialogs().deleteMovieFile(context);
    if (result) {
      bool execute = await RadarrAPIHelper()
          .deleteMovieFile(context: context, movieFile: widget.file);
      if (execute) context.read<RadarrMovieDetailsState>().fetchFiles(context);
    }
    setState(() => _deleteFileState = ZagLoadingState.INACTIVE);
  }

  Future<void> _viewMediaInfo() async {
    ZagBottomModalSheet().show(
      builder: (context) => ZagListViewModal(
        children: [
          ZagHeader(text: 'radarr.Video'.tr()),
          ZagTableCard(
            content: [
              ZagTableContent(
                title: 'radarr.BitDepth'.tr(),
                body: widget.file.mediaInfo?.zagVideoBitDepth,
              ),
              ZagTableContent(
                title: 'radarr.Codec'.tr(),
                body: widget.file.mediaInfo?.zagVideoCodec,
              ),
              ZagTableContent(
                title: 'radarr.DynamicRange'.tr(),
                body: widget.file.mediaInfo?.zagVideoDynamicRange,
              ),
              ZagTableContent(
                title: 'radarr.FPS'.tr(),
                body: widget.file.mediaInfo?.zagVideoFps,
              ),
              ZagTableContent(
                title: 'radarr.Resolution'.tr(),
                body: widget.file.mediaInfo?.zagVideoResolution,
              ),
            ],
          ),
          ZagHeader(text: 'radarr.Audio'.tr()),
          ZagTableCard(
            content: [
              ZagTableContent(
                title: 'radarr.Channels'.tr(),
                body: widget.file.mediaInfo?.zagAudioChannels,
              ),
              ZagTableContent(
                title: 'radarr.Codec'.tr(),
                body: widget.file.mediaInfo?.zagAudioCodec,
              ),
              ZagTableContent(
                title: 'radarr.Languages'.tr(),
                body: widget.file.mediaInfo?.zagAudioLanguages,
              ),
              ZagTableContent(
                title: 'radarr.Streams'.tr(),
                body: widget.file.mediaInfo?.zagAudioStreamCount,
              ),
            ],
          ),
          ZagHeader(text: 'radarr.Other'.tr()),
          ZagTableCard(
            content: [
              ZagTableContent(
                title: 'radarr.Runtime'.tr(),
                body: widget.file.mediaInfo?.zagRunTime,
              ),
              ZagTableContent(
                title: 'radarr.ScanType'.tr(),
                body: widget.file.mediaInfo?.zagScanType,
              ),
              ZagTableContent(
                title: 'radarr.Subtitles'.tr(),
                body: widget.file.mediaInfo?.zagSubtitles,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
