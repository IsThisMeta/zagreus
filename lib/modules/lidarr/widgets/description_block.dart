import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class LidarrDescriptionBlock extends StatefulWidget {
  final String? description;
  final String title;
  final String uri;
  final bool squareImage;
  final Map? headers;
  final Function? onLongPress;

  const LidarrDescriptionBlock({
    Key? key,
    required this.description,
    required this.title,
    required this.uri,
    required this.headers,
    this.squareImage = false,
    this.onLongPress,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LidarrDescriptionBlock> {
  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: widget.title,
      body: [
        ZagTextSpan.extended(
          text: widget.description?.isNotEmpty ?? false
              ? widget.description
              : 'lidarr.NoSummaryAvailable'.tr(),
        ),
      ],
      onTap: () async => ZagDialogs().textPreview(
        context,
        widget.title,
        widget.description?.trim() ?? 'lidarr.NoSummaryAvailable'.tr(),
      ),
      onLongPress: widget.onLongPress,
      customBodyMaxLines: 3,
      posterPlaceholderIcon: ZagIcons.USER,
      posterHeaders: widget.headers,
      posterIsSquare: widget.squareImage,
      posterUrl: widget.uri,
    );
  }
}
