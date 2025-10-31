import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagBlock extends StatelessWidget {
  static const TITLE_HEIGHT = ZagUI.FONT_SIZE_H2 + 4.0;
  static const SUBTITLE_HEIGHT = ZagUI.FONT_SIZE_H3 + 4.0;

  // If true, will load a skeleton-form version of the block.
  final bool skeletonEnabled;
  final bool skeletonPoster;
  final int skeletonSubtitles;

  final bool? disabled;
  final String? title;
  final Color titleColor;
  final Color? backgroundColor;
  final int titleMaxLines;

  /// If defined, only takes the first body subtitle from the [body] array
  /// And allows that single [TextSpan] to overflow to this many lines
  final int? customBodyMaxLines;
  final List<TextSpan>? body;

  /// Icons that lead the body lines. If defined, then the length of this list
  /// must match the length of [body]. If a specific line does not need a
  /// leading icon, pass in null.
  final List<IconData?>? bodyLeadingIcons;
  final Color? bodyLeadingIconsColor;

  final Widget? leading;
  final Widget? trailing;
  final Widget? bottom;
  final double bottomHeight;

  final Function? onTap;
  final Function? onLongPress;

  final IconData? posterPlaceholderIcon;
  final String? posterUrl;
  final Map? posterHeaders;
  final bool posterIsSquare;
  final String? backgroundUrl;
  final Map? backgroundHeaders;

  const ZagBlock({
    Key? key,
    this.skeletonEnabled = false,
    this.skeletonPoster = true,
    this.skeletonSubtitles = 2,
    this.disabled = false,
    this.title,
    this.titleColor =
        const Color(0x00000000), // Sentinel value - will be set in build
    this.backgroundColor,
    this.titleMaxLines = 1,
    this.body,
    this.bodyLeadingIcons,
    this.bodyLeadingIconsColor,
    this.bottom,
    this.bottomHeight = SUBTITLE_HEIGHT,
    this.customBodyMaxLines,
    this.posterPlaceholderIcon,
    this.posterUrl,
    this.posterHeaders = const {},
    this.posterIsSquare = false,
    this.backgroundUrl,
    this.backgroundHeaders = const {},
    this.onTap,
    this.onLongPress,
    this.leading,
    this.trailing,
  }) : super(key: key);

  static double calculateItemExtent(
    int subtitleLines, {
    bool hasBottom = false,
    double bottomHeight = SUBTITLE_HEIGHT,
  }) {
    double height = calculateItemHeight(
      subtitleLines,
      hasBottom: hasBottom,
      bottomHeight: bottomHeight,
    );
    return height + ZagUI.MARGIN_H_DEFAULT_V_HALF.vertical;
  }

  static double calculateItemHeight(
    int subtitleLines, {
    bool hasBottom = false,
    double bottomHeight = SUBTITLE_HEIGHT,
  }) {
    double height = (ZagUI.DEFAULT_MARGIN_SIZE * 2) + TITLE_HEIGHT;
    height += subtitleLines * SUBTITLE_HEIGHT;
    if (hasBottom) height += bottomHeight;
    return height;
  }

  double _calculateHeight() {
    int? _scalar = customBodyMaxLines;
    _scalar ??= body?.length ?? 0;
    return calculateItemHeight(
      _scalar,
      hasBottom: bottom != null,
      bottomHeight: bottomHeight,
    );
  }

  double _calculateSkeletonHeight() {
    return calculateItemHeight(
      skeletonSubtitles,
      hasBottom: bottom != null,
      bottomHeight: bottomHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (skeletonEnabled) return _buildSkeletonBlock(context);
    return _buildBlock(context);
  }

  Widget _buildSkeletonBlock(BuildContext context) {
    double _height = _calculateSkeletonHeight();
    return ZagCard(
      context: context,
      child: ZagShimmer(
        child: Row(
          children: [
            if (skeletonPoster) _poster(context, _height),
            _tile(context, _height),
          ],
        ),
      ),
      height: _height,
    );
  }

  Widget _buildBlock(BuildContext context) {
    double _height = _calculateHeight();
    return ZagCard(
      context: context,
      child: InkWell(
        child: Stack(
          children: [
            if (backgroundUrl?.isNotEmpty ?? false)
              _fadeInBackground(context, _height),
            if (backgroundUrl?.isNotEmpty ?? false)
              Container(
                height: _height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            Colors.black.withOpacity(0.5),
                            Colors.black.withOpacity(0.2),
                          ]
                        : [
                            Colors.black.withOpacity(0.15),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            Opacity(
              opacity: disabled! ? ZagUI.OPACITY_DISABLED : 1.0,
              child: Row(
                children: [
                  _poster(context, _height),
                  _tile(context, _height),
                ],
              ),
            ),
          ],
        ),
        mouseCursor: onTap != null || onLongPress != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        onTap: onTap as void Function()?,
        onLongPress: onLongPress as void Function()?,
      ),
      height: _height,
      color: backgroundColor ??
          (backgroundUrl?.isNotEmpty ?? false ? Colors.transparent : null),
    );
  }

  Widget _fadeInBackground(BuildContext context, double _height) {
    if (backgroundUrl == null) return const SizedBox();

    final _percent = ZagreusDatabase.THEME_IMAGE_BACKGROUND_OPACITY.read();
    if (_percent == 0) return const SizedBox(height: 0, width: 0);

    double _opacity = _percent / 100;
    if (disabled!) _opacity *= ZagUI.OPACITY_DISABLED;

    return Opacity(
      opacity: _opacity,
      child: FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        height: _height,
        width: MediaQuery.of(context).size.width,
        fadeInDuration: const Duration(
          milliseconds: ZagUI.ANIMATION_SPEED_IMAGES,
        ),
        fit: BoxFit.cover,
        image: ZagNetworkImageProvider(
          url: backgroundUrl!,
          headers: backgroundHeaders?.cast<String, String>(),
        ).imageProvider,
        imageErrorBuilder: (context, error, stack) => SizedBox(
          height: _height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  Widget _poster(BuildContext context, double height) {
    double _dimension = height - ZagUI.DEFAULT_MARGIN_SIZE;

    if (skeletonEnabled) {
      return Padding(
        padding: const EdgeInsets.only(left: ZagUI.MARGIN_SIZE_HALF),
        child: Container(
          height: _dimension,
          width: _dimension / (posterIsSquare ? 1.0 : 1.5),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
            border: ZagUI.shouldUseBorder
                ? Border.all(color: ZagColours.white10)
                : null,
          ),
        ),
      );
    }

    if (posterUrl == null && posterPlaceholderIcon == null) {
      return const SizedBox(width: 0.0, height: 0.0);
    }

    return Padding(
      padding: const EdgeInsets.only(left: ZagUI.MARGIN_SIZE_HALF),
      child: ZagNetworkImage(
        context: context,
        url: posterUrl ?? '',
        headers: posterHeaders,
        placeholderIcon: posterPlaceholderIcon,
        height: _dimension,
        width: _dimension / (posterIsSquare ? 1.0 : 1.5),
      ),
    );
  }

  Widget _tile(BuildContext context, double height) {
    if (skeletonEnabled) {
      return Expanded(
        child: Padding(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: ZagBlock.TITLE_HEIGHT - 4.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
                  border: ZagUI.shouldUseBorder
                      ? Border.all(color: ZagColours.white10)
                      : null,
                ),
              ),
              ...List.generate(skeletonSubtitles, (_) {
                return Container(
                  height: ZagBlock.SUBTITLE_HEIGHT - 6.0,
                  width: MediaQuery.of(context).size.width / 2.5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(ZagUI.BORDER_RADIUS),
                    border: ZagUI.shouldUseBorder
                        ? Border.all(color: ZagColours.white10)
                        : null,
                  ),
                );
              }),
            ],
          ),
          padding: ZagUI.MARGIN_DEFAULT,
        ),
      );
    }

    return Expanded(
      // ignore: deprecated_member_use_from_same_package
      child: ZagListTile(
        context: context,
        title: _scrollableText(
          child: ZagText.title(
            text: title ?? ZagUI.TEXT_EMDASH,
            color: titleColor == const Color(0x00000000)
                ? (Theme.of(context).brightness == Brightness.light
                    ? Colors.black87
                    : Colors.white)
                : titleColor,
            overflow: TextOverflow.visible,
            maxLines: this.titleMaxLines,
          ),
        ),
        subtitle: _subtitle(),
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        drawBorder: false,
        height: height,
        trailing: trailing,
        leading: leading,
      ),
    );
  }

  Widget? _subtitle() {
    int maxLines = customBodyMaxLines ?? 1;

    if (bodyLeadingIcons != null) {
      assert(
        bodyLeadingIcons!.length == body?.length,
        'bodyLeadingIcons and body should be the same size',
      );
    }

    Widget _wrapper(List<Widget> children) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    Widget _entry(TextSpan textSpan, IconData? icon) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(
                right: ZagUI.DEFAULT_MARGIN_SIZE / 4,
              ),
              child: SizedBox(
                width: ZagUI.FONT_SIZE_H2 + ZagUI.DEFAULT_MARGIN_SIZE / 2,
                child: Icon(
                  icon,
                  color: bodyLeadingIconsColor,
                  size: ZagUI.FONT_SIZE_H2,
                ),
              ),
            ),
          Expanded(
            child: _scrollableText(
              child: Align(
                alignment: Alignment.topLeft,
                child: Builder(
                  builder: (context) => RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: ZagUI.FONT_SIZE_H3,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? ZagColours.grey
                            : Colors.grey.shade900,
                      ),
                      children: [textSpan],
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: maxLines == 1 ? false : true,
                    maxLines: maxLines,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    List<Widget> _children = [];

    if (body?.isNotEmpty ?? false) {
      if (customBodyMaxLines != null) {
        _children.add(_entry(body![0], bodyLeadingIcons?.elementAtOrNull(0)));
      } else {
        for (int i = 0; i < body!.length; i++) {
          _children.add(_entry(body![i], bodyLeadingIcons?.elementAtOrNull(i)));
          if (i != body!.length - 1) {
            _children.add(const SizedBox(height: ZagUI.MARGIN_SIZE_HALF));
          }
        }
      }
    }

    if (bottom != null) {
      if (_children.isNotEmpty) {
        _children.add(const SizedBox(height: ZagUI.MARGIN_SIZE_HALF));
      }
      _children.add(
        SizedBox(
          height: bottomHeight,
          child: bottom,
        ),
      );
    }

    return _children.isEmpty ? null : _wrapper(_children);
  }

  Widget _scrollableText({
    required Widget child,
    Axis scrollDirection = Axis.horizontal,
  }) {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      child: child,
    );
  }
}
