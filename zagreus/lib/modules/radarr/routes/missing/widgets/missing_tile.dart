import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

class RadarrMissingTile extends StatefulWidget {
  static final itemExtent = ZagBlock.calculateItemExtent(3);

  final RadarrMovie movie;
  final RadarrQualityProfile? profile;
  final bool isMultiSelectMode;
  final bool isSelected;
  final VoidCallback onToggleSelection;

  const RadarrMissingTile({
    Key? key,
    required this.movie,
    required this.profile,
    this.isMultiSelectMode = false,
    this.isSelected = false,
    required this.onToggleSelection,
  }) : super(key: key);

  @override
  State<RadarrMissingTile> createState() => _State();
}

class _State extends State<RadarrMissingTile> {
  @override
  Widget build(BuildContext context) {
    return Selector<RadarrState, Future<List<RadarrMovie>>?>(
      selector: (_, state) => state.missing,
      builder: (context, missing, _) => ZagBlock(
        backgroundUrl:
            context.read<RadarrState>().getFanartURL(widget.movie.id),
        posterUrl: context.read<RadarrState>().getPosterURL(widget.movie.id),
        posterHeaders: context.read<RadarrState>().headers,
        posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
        disabled: !widget.movie.monitored!,
        title: widget.movie.title,
        body: [
          _subtitle1(),
          _subtitle2(),
          _subtitle3(),
        ],
        trailing: widget.isMultiSelectMode ? _selectionIndicator() : _trailing(),
        onTap: widget.isMultiSelectMode ? widget.onToggleSelection : _onTap,
      ),
    );
  }

  Widget _selectionIndicator() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
        border: Border.all(
          color: widget.isSelected ? Colors.blue : Colors.grey,
          width: 2,
        ),
      ),
      child: widget.isSelected
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            )
          : null,
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        TextSpan(text: widget.movie.zagYear),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.movie.zagRuntime),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.movie.zagStudio),
      ],
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(text: widget.profile!.zagName),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.movie.zagMinimumAvailability),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.movie.zagReleaseDate),
      ],
    );
  }

  TextSpan _subtitle3() {
    String? _days = widget.movie.zagEarlierReleaseDate?.asDaysDifference();
    return TextSpan(
        style: const TextStyle(
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          color: ZagColours.red,
        ),
        text: _days == null
            ? 'radarr.Released'.tr()
            : _days == 'Today'
                ? 'radarr.ReleasedToday'.tr()
                : 'Released $_days Ago');
  }

  ZagIconButton _trailing() {
    return ZagIconButton(
      icon: Icons.search_rounded,
      onPressed: () async => RadarrAPIHelper().automaticSearch(
          context: context,
          movieId: widget.movie.id!,
          title: widget.movie.title!),
      onLongPress: () => RadarrRoutes.MOVIE_RELEASES.go(params: {
        'movie': widget.movie.id!.toString(),
      }),
    );
  }

  Future<void> _onTap() async {
    RadarrRoutes.MOVIE.go(params: {
      'movie': widget.movie.id!.toString(),
    });
  }
}
