import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/profile.dart';
import 'package:zagreus/extensions/scroll_controller.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/utils/profile_tools.dart';

enum _AppBarType {
  DEFAULT,
  EMPTY,
  DROPDOWN,
}

class ZagAppBar extends StatefulWidget implements PreferredSizeWidget {
  static const APPBAR_HEIGHT = kToolbarHeight;

  final _AppBarType type;
  final String? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool hideLeading;
  final bool useDrawer;
  final Widget? child;
  final double? height;
  final List<String?>? profiles;
  final PageController? pageController;
  final List<ScrollController>? scrollControllers;
  final Color? backgroundColor;
  final void Function(String)? onProfileSelected;

  @override
  Size get preferredSize {
    double _size = (height ?? APPBAR_HEIGHT);
    if (bottom != null) _size += bottom!.preferredSize.height - 0.0;
    return Size.fromHeight(_size);
  }

  const ZagAppBar._internal({
    required this.type,
    required this.useDrawer,
    this.title,
    this.actions,
    this.bottom,
    this.child,
    this.height,
    this.profiles,
    this.pageController,
    this.scrollControllers,
    this.hideLeading = false,
    this.backgroundColor,
    this.onProfileSelected,
  });

  /// Create a new [AppBar] widget pre-styled for Zagreus.
  ///
  /// Will register an onTap gesture for the AppBar if:
  /// - [state] is supplied, and will call [scrollBackList] on the state controller.
  /// - [pageController] and [scrollControllers] are supplied, will register a listener on the page controller and scroll back the respective scroll controller.
  ///
  /// Passing in all 3 will result in state.scrollBackList taking precedence.
  factory ZagAppBar({
    required String title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool useDrawer = false,
    bool hideLeading = false,
    PageController? pageController,
    Color? backgroundColor,
    List<ScrollController>? scrollControllers,
  }) {
    if (pageController != null)
      assert(scrollControllers != null,
          'pageController is defined, scrollControllers should as well.');
    return ZagAppBar._internal(
      title: title,
      actions: actions,
      bottom: bottom,
      useDrawer: useDrawer,
      pageController: pageController,
      scrollControllers: scrollControllers,
      hideLeading: hideLeading,
      backgroundColor: backgroundColor,
      type: _AppBarType.DEFAULT,
    );
  }

  /// Create a new, empty [ZagAppBar] which can be used to attach to a [Scaffold] in a [PageView] that is already wrapped in an [AppBar].
  ///
  /// Example usages would be a [PageView] but a single page needs an [AppBar] bottom widget.
  ///
  /// The default padding is for a [ZagTextInputBar].
  factory ZagAppBar.empty({
    required Widget child,
    required double height,
    EdgeInsets padding = ZagTextInputBar.appBarMargin,
    Alignment alignment = Alignment.topCenter,
    Color? backgroundColor,
  }) {
    return ZagAppBar._internal(
      child: Container(
        child: child,
        height: height,
        padding: padding,
        alignment: alignment,
      ),
      height: height,
      useDrawer: false,
      backgroundColor: backgroundColor,
      type: _AppBarType.EMPTY,
    );
  }

  /// Create a [zagAppBar] with the title widget having a dropdown to switch to the supplied list of profiles.
  ///
  /// Will register an onTap gesture for the AppBar if:
  /// - [state] is supplied, and will call [scrollBackList] on the state controller.
  /// - [pageController] and [scrollControllers] are supplied, will register a listener on the page controller and scroll back the respective scroll controller.
  ///
  /// Passing in all 3 will result in state.scrollBackList taking precedence.
  factory ZagAppBar.dropdown({
    required String title,
    required List<String> profiles,
    bool useDrawer = true,
    bool hideLeading = false,
    List<Widget>? actions,
    PageController? pageController,
    List<ScrollController>? scrollControllers,
    PreferredSizeWidget? bottom,
    Color? backgroundColor,
    void Function(String)? onProfileSelected,
  }) {
    if (pageController != null)
      assert(scrollControllers != null,
          'if pageController is defined, scrollControllers should as well.');
    if (profiles.length < 2)
      return ZagAppBar._internal(
        title: title,
        actions: actions,
        useDrawer: useDrawer,
        hideLeading: hideLeading,
        bottom: bottom,
        pageController: pageController,
        scrollControllers: scrollControllers,
        backgroundColor: backgroundColor,
        type: _AppBarType.DEFAULT,
      );
    return ZagAppBar._internal(
      title: title,
      profiles: profiles,
      actions: actions,
      bottom: bottom,
      useDrawer: useDrawer,
      hideLeading: hideLeading,
      pageController: pageController,
      scrollControllers: scrollControllers,
      backgroundColor: backgroundColor,
      onProfileSelected: onProfileSelected,
      type: _AppBarType.DROPDOWN,
    );
  }

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ZagAppBar> {
  int _index = 0;

  @override
  void initState() {
    _index = widget.pageController?.initialPage ?? 0;
    widget.pageController?.addListener(_pageControllerListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.pageController?.removeListener(_pageControllerListener);
    super.dispose();
  }

  void _pageControllerListener() {
    if ((widget.pageController?.page?.round() ?? _index) == _index) return;
    _index = widget.pageController!.page!.round();
  }

  void _onTap() {
    try {
      if ((widget.scrollControllers?.isNotEmpty ?? false) &&
          ((widget.scrollControllers!.length - 1) >= _index)) {
        widget.scrollControllers![_index].animateToStart();
      }
    } catch (error, stack) {
      ZagLogger().error(
          'Failed to scroll back: Index: $_index, ScrollControllers: ${widget.scrollControllers?.length ?? 0}',
          error,
          stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (widget.type) {
      case _AppBarType.DEFAULT:
        child = _default(context);
        break;
      case _AppBarType.EMPTY:
        child = _empty(context);
        break;
      case _AppBarType.DROPDOWN:
        child = _dropdown(context);
        break;
      default:
        throw Exception('Unknown AppBar type.');
    }
    return GestureDetector(
      child: child,
      onTap: _onTap,
    );
  }

  Widget? _sharedLeading(BuildContext context) {
    if (widget.hideLeading) return null;
    if (widget.useDrawer)
      return SizedBox(
        child: ZagIconButton.appBar(
          icon: Icons.menu_rounded,
          color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
          onPressed: () async {
            HapticFeedback.lightImpact();
            if (Scaffold.of(context).hasDrawer) {
              Scaffold.of(context).openDrawer();
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
        ),
        height: kToolbarHeight,
      );
    return SizedBox(
      child: ZagIconButton.appBar(
        icon: Icons.arrow_back_ios_new_rounded,
        color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
        onPressed: ZagRouter().popSafely,
        onLongPress: ZagRouter().popToRootRoute,
      ),
      height: kToolbarHeight,
    );
  }

  Widget _default(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor,
      title: Text(
        widget.title ?? '',
        overflow: TextOverflow.fade,
        style: const TextStyle(fontSize: ZagUI.FONT_SIZE_H1),
      ),
      leading: _sharedLeading(context),
      automaticallyImplyLeading: !(widget.hideLeading),
      centerTitle: false,
      elevation: 0,
      actions: widget.actions,
      bottom: widget.bottom,
    );
  }

  Widget _empty(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor,
      automaticallyImplyLeading: false,
      toolbarHeight: widget.height,
      leadingWidth: 0.0,
      elevation: 0.0,
      titleSpacing: 0.0,
      title: widget.child,
      // Hide the endDrawer icon while keeping drawer accessible via swipe
      actions: const [SizedBox.shrink()],
    );
  }

  Widget _dropdown(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor,
      automaticallyImplyLeading: !(widget.hideLeading),
      title: ZagPopupMenuButton<String>(
        tooltip: 'Change Profiles',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  widget.title!,
                  style: const TextStyle(fontSize: ZagUI.FONT_SIZE_H1),
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
        onSelected: (result) {
          HapticFeedback.selectionClick();
          if (widget.onProfileSelected != null) {
            widget.onProfileSelected!(result);
          } else {
            ZagProfileTools().changeTo(result, popToRootRoute: true);
          }
        },
        itemBuilder: (context) {
          return <PopupMenuEntry<String>>[
            for (String? profile in widget.profiles!)
              PopupMenuItem<String>(
                value: profile,
                child: Text(
                  // Show friendly name for shadow profiles
                  ZagProfile.getInstanceDisplayName(profile!) ?? profile,
                  style: TextStyle(
                    fontSize: ZagUI.FONT_SIZE_H3,
                    color: ZagreusDatabase.ENABLED_PROFILE.read() == profile
                        ? ZagColours.accent
                        : Colors.white,
                  ),
                ),
              )
          ];
        },
      ),
      leading: _sharedLeading(context),
      centerTitle: false,
      elevation: 0,
      actions: widget.actions,
      bottom: widget.bottom,
    );
  }
}
