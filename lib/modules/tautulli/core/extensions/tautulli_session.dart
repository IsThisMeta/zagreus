import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/duration/timestamp.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/tautulli.dart';

extension TautulliSessionAudioExtension on TautulliSession {
  String get _language {
    if (audioLanguage?.isEmpty ?? true) return 'zagreus.Unknown'.tr();
    return audioLanguage!.toTitleCase();
  }

  String get _codec {
    if (audioCodec?.isEmpty ?? true) return ZagUI.TEXT_EMDASH;
    if (audioCodec == 'truehd') return 'TrueHD';
    return audioCodec!.toUpperCase();
  }

  String get _channelLayout {
    if (audioChannelLayout?.isEmpty ?? true) return ZagUI.TEXT_EMDASH;
    return audioChannelLayout!.split('(')[0].toTitleCase();
  }

  String get _streamCodec {
    if (streamAudioCodec?.isEmpty ?? true) return ZagUI.TEXT_EMDASH;
    if (streamAudioCodec == 'truehd') return 'TrueHD';
    return streamAudioCodec!.toUpperCase();
  }

  String get _streamChannelLayout {
    if (streamAudioChannelLayout?.isEmpty ?? false) return ZagUI.TEXT_EMDASH;
    return streamAudioChannelLayout!.split('(')[0].toTitleCase();
  }

  String formattedAudio() {
    if (streamAudioDecision != null) {
      final decision = streamAudioDecision.localizedName;

      switch (streamAudioDecision) {
        case TautulliTranscodeDecision.TRANSCODE:
          return '$decision ($_language - $_codec $_channelLayout ${ZagUI.TEXT_ARROW_RIGHT} $_streamCodec $_streamChannelLayout)';
        case TautulliTranscodeDecision.COPY:
          return '$decision ($_language - $_streamCodec $_streamChannelLayout)';
        default:
          return '$decision ($_language - $_streamCodec $_streamChannelLayout)';
      }
    }

    return 'tautulli.None'.tr();
  }
}

extension TautulliSessionContainerExtension on TautulliSession {
  String get _container {
    if (container?.isEmpty ?? true) return 'zagreus.Unknown'.tr();
    return container!.toUpperCase();
  }

  String get _streamContainer {
    if (streamContainer?.isEmpty ?? true) return 'zagreus.Unknown'.tr();
    return streamContainer!.toUpperCase();
  }

  String formattedContainer() {
    if (streamContainerDecision == TautulliTranscodeDecision.TRANSCODE) {
      return '${'tautulli.Converting'.tr()} ($_container ${ZagUI.TEXT_ARROW_RIGHT} $_streamContainer)';
    }

    return '${TautulliTranscodeDecision.DIRECT_PLAY.localizedName} ($_streamContainer)';
  }
}

extension TautulliSessionSubtitleExtension on TautulliSession {
  String get _language {
    if (subtitleLanguage?.isEmpty ?? true) return 'zagreus.Unknown'.tr();
    return subtitleLanguage!.toTitleCase();
  }

  String get _codec {
    if ((streamSubtitleTransient ?? false) && streamSubtitleCodec != null)
      return 'tautulli.None'.tr();
    if (subtitleCodec?.isEmpty ?? true) return ZagUI.TEXT_EMDASH;
    return subtitleCodec!.toUpperCase();
  }

  String get _streamCodec {
    if (streamSubtitleCodec?.isEmpty ?? true) return ZagUI.TEXT_EMDASH;
    return streamSubtitleCodec!.toUpperCase();
  }

  String formattedSubtitles() {
    if (subtitles ?? false) {
      final decision = streamSubtitleDecision.localizedName;
      final synced = syncedVersion ?? false;

      switch (streamSubtitleDecision) {
        case TautulliTranscodeDecision.TRANSCODE:
          return '$decision ($_language - $_codec ${ZagUI.TEXT_ARROW_RIGHT} $_streamCodec)';
        case TautulliTranscodeDecision.COPY:
          return '$decision ($_language - $_codec)';
        case TautulliTranscodeDecision.BURN:
          return '$decision ($_language - $_codec)';
        default:
          return '${TautulliTranscodeDecision.DIRECT_PLAY.localizedName} ($_language - ${synced ? _codec : _streamCodec})';
      }
    }

    return 'tautulli.None'.tr();
  }
}

extension TautulliSessionStreamExtension on TautulliSession {
  String get _transcodeSpeed {
    if (transcodeThrottled ?? true) return 'tautulli.Throttled'.tr();
    return 'tautulli.Speed'.tr(args: ['${transcodeSpeed ?? 0.0}']);
  }

  String formattedStream() {
    final decision = transcodeDecision.localizedName;

    switch (transcodeDecision) {
      case TautulliTranscodeDecision.TRANSCODE:
        return '$decision ($_transcodeSpeed)';
      case TautulliTranscodeDecision.COPY:
        return decision;
      default:
        return TautulliTranscodeDecision.DIRECT_PLAY.localizedName;
    }
  }
}

extension TautulliSessionVideoExtension on TautulliSession {
  String get _codec {
    if (videoCodec?.isEmpty ?? true) return 'zagreus.Unknown'.tr();
    return videoCodec!.toUpperCase();
  }

  String get _streamCodec {
    if (streamVideoCodec?.isEmpty ?? true) return 'zagreus.Unknown'.tr();
    return streamVideoCodec!.toUpperCase();
  }

  String get _fullResolution {
    if (videoFullResolution?.isEmpty ?? true) return 'zagreus.Unknown'.tr();
    return videoFullResolution!;
  }

  String get _streamFullResolution {
    if (streamVideoFullResolution?.isEmpty ?? true)
      return 'zagreus.Unknown'.tr();
    return streamVideoFullResolution!;
  }

  String get _dynamicRange {
    if (videoDynamicRange?.isEmpty ?? true) return '';
    if (videoDynamicRange != 'SDR') return ' $videoDynamicRange';
    return '';
  }

  String get _streamDynamicRange {
    final isSdr = streamVideoDynamicRange == 'SDR';

    if (streamVideoDynamicRange?.isEmpty ?? true) return '';
    if (!isSdr || _dynamicRange.isNotEmpty) return ' $streamVideoDynamicRange';
    return '';
  }

  String get _hardwareDecoding {
    final isTc = streamVideoDecision == TautulliTranscodeDecision.TRANSCODE;

    if (isTc && (transcodeHardwareDecoding ?? false)) return ' (HW)';
    return '';
  }

  String get _hardwareEncoding {
    final isTc = streamVideoDecision == TautulliTranscodeDecision.TRANSCODE;

    if (isTc && (transcodeHardwareEncoding ?? false)) return ' (HW)';
    return '';
  }

  String formattedVideo() {
    if (streamVideoDecision != null) {
      final decision = streamVideoDecision.localizedName;

      switch (streamVideoDecision) {
        case TautulliTranscodeDecision.TRANSCODE:
          return '$decision ($_codec$_hardwareDecoding $_fullResolution$_dynamicRange ${ZagUI.TEXT_ARROW_RIGHT} $_streamCodec$_hardwareEncoding $_streamFullResolution$_streamDynamicRange)';
        case TautulliTranscodeDecision.COPY:
          return '$decision ($_streamCodec $_streamFullResolution$_streamDynamicRange)';
        default:
          return '${TautulliTranscodeDecision.DIRECT_PLAY.localizedName} ($_streamCodec $_streamFullResolution$_streamDynamicRange)';
      }
    }

    return 'tautulli.None'.tr();
  }
}

extension TautulliSessionExtension on TautulliSession {
  bool hasAudio() {
    const types = [
      TautulliMediaType.MOVIE,
      TautulliMediaType.EPISODE,
      TautulliMediaType.CLIP,
      TautulliMediaType.TRACK,
    ];
    return types.contains(mediaType);
  }

  bool hasSubtitles() {
    const types = [
      TautulliMediaType.MOVIE,
      TautulliMediaType.EPISODE,
      TautulliMediaType.CLIP,
    ];
    return types.contains(mediaType);
  }

  bool hasVideo() {
    const types = [
      TautulliMediaType.MOVIE,
      TautulliMediaType.EPISODE,
      TautulliMediaType.CLIP,
      TautulliMediaType.PHOTO,
    ];
    return types.contains(mediaType);
  }

  String? get zagTitle {
    if (this.grandparentTitle != null && this.grandparentTitle!.isNotEmpty)
      return this.grandparentTitle;
    if (this.parentTitle != null && this.parentTitle!.isNotEmpty)
      return this.parentTitle;
    if (this.title != null && this.title!.isNotEmpty) return this.title;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagFullTitle {
    return [
      if (this.title != null && this.title!.isNotEmpty) this.title,
      if (this.parentTitle != null && this.parentTitle!.isNotEmpty)
        this.parentTitle,
      if (this.grandparentTitle != null && this.grandparentTitle!.isNotEmpty)
        this.grandparentTitle,
    ].join('\n');
  }

  String get zagYear {
    if (this.year != null) return this.year.toString();
    return ZagUI.TEXT_EMDASH;
  }

  String get zagDuration {
    double _percent = (this.progressPercent ?? 0) / 100;
    String _progress = Duration(
            seconds:
                ((this.streamDuration ?? const Duration(seconds: 0)).inSeconds *
                        _percent)
                    .floor())
        .asNumberTimestamp();
    String _total = this.streamDuration!.asNumberTimestamp();
    return '$_progress/$_total (${this.progressPercent}%)';
  }

  String? get zagLibraryName {
    if (this.libraryName != null && this.libraryName!.isNotEmpty)
      return this.libraryName;
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagFriendlyName {
    if (this.friendlyName != null && this.friendlyName!.isNotEmpty)
      return this.friendlyName;
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagIPAddress {
    if (this.ipAddress != null && this.ipAddress!.isNotEmpty)
      return this.ipAddress;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagPlatform {
    return [
      this.platform ?? ZagUI.TEXT_EMDASH,
      if (this.platformVersion != null && this.platformVersion!.isNotEmpty)
        '(${this.platformVersion})',
    ].join(' ');
  }

  String? get zagProduct {
    if (this.product != null && this.product!.isNotEmpty) return this.product;
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagPlayer {
    if (this.player != null && this.player!.isNotEmpty) return this.player;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagQuality {
    return [
      this.qualityProfile ?? ZagUI.TEXT_EMDASH,
      if (this.streamBitrate != null)
        '(${this.streamBitrate.asKilobits(decimals: 1)}ps)',
    ].join(' ');
  }

  String get zagBandwidth {
    if (this.bandwidth != null)
      return '${this.bandwidth.asKilobits(decimals: 1)}ps';
    return ZagUI.TEXT_EMDASH;
  }

  String? zagArtworkPath(BuildContext context) {
    switch (this.mediaType) {
      case TautulliMediaType.EPISODE:
        return context
            .read<TautulliState>()
            .getImageURLFromRatingKey(this.grandparentRatingKey);
      case TautulliMediaType.TRACK:
        return context
            .read<TautulliState>()
            .getImageURLFromRatingKey(this.parentRatingKey);
      case TautulliMediaType.MOVIE:
      case TautulliMediaType.LIVE:
      default:
        return context
            .read<TautulliState>()
            .getImageURLFromRatingKey(this.ratingKey);
    }
  }

  IconData get zagSessionStateIcon {
    switch (this.state) {
      case TautulliSessionState.PAUSED:
        return Icons.pause_rounded;
      case TautulliSessionState.PLAYING:
        return Icons.play_arrow_rounded;
      case TautulliSessionState.BUFFERING:
      default:
        return Icons.compare_arrows_rounded;
    }
  }

  double get zagSessionStateIconOffset {
    switch (this.state) {
      case TautulliSessionState.PAUSED:
        return -2.0;
      case TautulliSessionState.PLAYING:
        return -3.0;
      case TautulliSessionState.BUFFERING:
      default:
        return 0.0;
    }
  }

  String get zagETA {
    try {
      double _percent = this.progressPercent! / 100;
      Duration _progress = Duration(
          seconds: (this.streamDuration!.inSeconds * _percent).floor());
      Duration _eta = this.streamDuration! - _progress;
      return DateTime.now().add(_eta).asTimeOnly();
    } catch (error, stack) {
      ZagLogger().error('Failed to calculate ETA', error, stack);
      return 'zagreus.Unknown'.tr();
    }
  }

  double get zagTranscodeProgress =>
      min(1.0, max(0, this.transcodeProgress! / 100));
  double get zagProgressPercent =>
      min(1.0, max(0, this.progressPercent! / 100));
}
