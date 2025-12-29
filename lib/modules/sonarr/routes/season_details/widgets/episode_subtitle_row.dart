import 'package:flutter/material.dart';
import 'package:zagreus/api/bazarr/models.dart';
import 'package:zagreus/core.dart';

/// A row widget that displays subtitle status for an episode.
/// Shows a CC icon followed by language tags for both existing and missing subtitles.
/// Existing subtitles are shown with accent color, missing with gray.
/// Only renders when there are any subtitles (existing or missing) configured.
class EpisodeSubtitleRow extends StatelessWidget {
  final BazarrEpisode? bazarrEpisode;

  const EpisodeSubtitleRow({
    Key? key,
    this.bazarrEpisode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final existingSubtitles = bazarrEpisode?.existingSubtitles ?? [];
    final missingSubtitles = bazarrEpisode?.missingSubtitles ?? [];

    // Don't show anything if no subtitles are configured
    if (existingSubtitles.isEmpty && missingSubtitles.isEmpty) {
      return const SizedBox.shrink();
    }

    // Determine CC icon color based on subtitle status
    final bool hasAllSubtitles = missingSubtitles.isEmpty && existingSubtitles.isNotEmpty;
    final bool hasSomeSubtitles = existingSubtitles.isNotEmpty;

    Color ccIconColor;
    if (hasAllSubtitles) {
      ccIconColor = ZagColours.currentAccent;
    } else if (hasSomeSubtitles) {
      ccIconColor = ZagColours.currentAccent.withOpacity(0.7);
    } else {
      ccIconColor = Theme.of(context).brightness == Brightness.dark
          ? ZagColours.grey
          : Colors.grey.shade600;
    }

    // Build list of subtitle tags (existing first, then missing)
    List<Widget> tags = [];

    // Add existing subtitles (highlighted)
    for (final subtitle in existingSubtitles.take(4)) {
      tags.add(_SubtitleTag(subtitle: subtitle, isDownloaded: true));
    }

    // Add missing subtitles (gray) if we have room
    final remainingSlots = 4 - tags.length;
    if (remainingSlots > 0) {
      for (final subtitle in missingSubtitles.take(remainingSlots)) {
        tags.add(_SubtitleTag(subtitle: subtitle, isDownloaded: false));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.closed_caption_rounded,
          size: 16.0,
          color: ccIconColor,
        ),
        const SizedBox(width: 4.0),
        Flexible(
          child: Wrap(
            spacing: 4.0,
            runSpacing: 2.0,
            children: tags,
          ),
        ),
      ],
    );
  }
}

class _SubtitleTag extends StatelessWidget {
  final BazarrSubtitle subtitle;
  final bool isDownloaded;

  const _SubtitleTag({
    Key? key,
    required this.subtitle,
    required this.isDownloaded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String label = subtitle.name ?? subtitle.code2 ?? 'Unknown';

    // Add indicators for forced/HI subtitles
    if (subtitle.forced == true) {
      label = '$label (F)';
    } else if (subtitle.hearingImpaired == true) {
      label = '$label (HI)';
    }

    // Downloaded: accent color border, Missing: gray border
    final borderColor = isDownloaded
        ? ZagColours.currentAccent
        : (isDark ? ZagColours.grey : Colors.grey.shade500);

    final textColor = isDownloaded
        ? (isDark ? Colors.white : Colors.black87)
        : (isDark ? ZagColours.grey : Colors.grey.shade600);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.0,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          color: textColor,
        ),
      ),
    );
  }
}
