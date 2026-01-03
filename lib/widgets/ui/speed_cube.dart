import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/router/router.dart';
import 'package:zagreus/system/session_state.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ZagSpeedCube extends StatefulWidget {
  final String currentModuleKey;

  const ZagSpeedCube({
    Key? key,
    required this.currentModuleKey,
  }) : super(key: key);

  // Public static method accessible from outside
  static void updateModuleTracking(String fromModule, String toModule) {
    _ZagSpeedCubeState._updateTracking(fromModule, toModule);
  }

  @override
  State<ZagSpeedCube> createState() => _ZagSpeedCubeState();
}

class _ZagSpeedCubeState extends State<ZagSpeedCube>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  // Track last launched module for long press
  static String? _lastLaunchedModuleKey;
  static String? _previousModuleKey;

  // Internal tracking method
  static void _updateTracking(String fromModule, String toModule) {
    _previousModuleKey = fromModule;
    _lastLaunchedModuleKey = toModule;
    print(
        '🔍 CUBE: Tracking updated! Previous: $_previousModuleKey, Current: $toModule');
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees (1/8 turn) - much subtler
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95, // Barely scales down
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  List<ZagModule> _getActiveModules() {
    final autoManage = ZagreusDatabase.DRAWER_AUTOMATIC_MANAGE.read();
    List<ZagModule> modules;

    if (autoManage) {
      modules = ZagModule.active
        ..sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else {
      try {
        final storedModules = ZagreusDatabase.DRAWER_MANUAL_ORDER.read();
        modules = List.from(storedModules);
        final missing = ZagModule.active;
        missing.retainWhere((m) => !modules.contains(m));
        modules.addAll(missing);
        modules.retainWhere((m) => m.featureFlag);
        modules = modules.cast<ZagModule>();
      } catch (e) {
        modules = ZagModule.active
          ..sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      }
    }

    final isPro = ZagreusPro.isEnabled;

    // Filter out premium modules if not Pro
    modules = modules.where((module) {
      if ((module == ZagModule.DISCOVER ||
              module == ZagModule.SEERR ||
              module == ZagModule.UNRAID ||
              module == ZagModule.SSH) &&
          !isPro) {
        return false;
      }
      return module.isEnabled;
    }).toList();

    // For free users: show Dashboard (titled "Home")
    // For pro users: show Discover (titled "Dashboard")
    if (isPro) {
      // Remove Dashboard, keep Discover
      modules.removeWhere((m) => m == ZagModule.DASHBOARD);
      if (!modules.contains(ZagModule.DISCOVER)) {
        modules.insert(0, ZagModule.DISCOVER);
      }
    } else {
      // Remove Discover, keep Dashboard
      modules.removeWhere((m) => m == ZagModule.DISCOVER);
      if (!modules.contains(ZagModule.DASHBOARD)) {
        modules.insert(0, ZagModule.DASHBOARD);
      }
    }

    return modules;
  }

  @override
  Widget build(BuildContext context) {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) {
        final modules = _getActiveModules();
        print('🔍 CUBE: Active modules count: ${modules.length}');
        print('🔍 CUBE: Modules: ${modules.map((m) => m.title).join(", ")}');

        final currentModule = modules.firstWhere(
          (m) => m.key.toLowerCase() == widget.currentModuleKey.toLowerCase(),
          orElse: () => ZagModule.DASHBOARD,
        );
        print('🔍 CUBE: Current module: ${currentModule.title}');

        // Calculate dynamic height: 56px for CUBE + 54px per module button (46px + 8px gap)
        final moduleCount = modules
            .where((m) =>
                m.key.toLowerCase() != widget.currentModuleKey.toLowerCase())
            .length;
        final screenHeight = MediaQuery.of(context).size.height;
        final maxHeight = screenHeight - 200;

        final idealHeight = 56.0 + (54.0 * moduleCount);
        final buttonSpacing =
            idealHeight > maxHeight ? (maxHeight - 56.0) / moduleCount : 54.0;

        final dynamicHeight = idealHeight > maxHeight ? maxHeight : idealHeight;
        print(
            '🔍 CUBE: Modules: $moduleCount, Spacing: $buttonSpacing, Height: $dynamicHeight');

        return SizedBox(
          width: 56,
          height: _isOpen ? dynamicHeight : 56,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.hardEdge,
            children: [
              // Module buttons
              ..._buildModuleButtons(
                  context, modules, currentModule, buttonSpacing),
              // Main CUBE - always on top
              Positioned(
                bottom: 0,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        print('🔍 CUBE: Main CUBE tapped, isOpen: $_isOpen');
                        _toggle();
                      },
                      onLongPress: () async {
                        if (_isOpen) return;

                        print('🔍 CUBE: Long press detected!');
                        if (_previousModuleKey != null) {
                          print(
                              '🔍 CUBE: Launching previous module with restore: $_previousModuleKey');
                          final previousModule = modules.firstWhere(
                            (m) => m.key == _previousModuleKey,
                            orElse: () => modules.first,
                          );

                          try {
                            await previousModule.launch(); // restore defaults to true
                            print(
                                '🔍 CUBE: Successfully launched $_previousModuleKey with saved route');

                            // Swap the tracking so we can bounce back!
                            final temp = _lastLaunchedModuleKey;
                            _lastLaunchedModuleKey = _previousModuleKey;
                            _previousModuleKey = temp;
                            print(
                                '🔍 CUBE: Swapped! Previous: $_previousModuleKey, Current: $_lastLaunchedModuleKey');
                          } catch (e) {
                            print('🔍 CUBE: Error launching module: $e');
                          }
                        } else {
                          print('🔍 CUBE: No previous module tracked yet');
                        }
                      },
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        child: AnimatedBuilder(
                          animation: _rotateAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotateAnimation.value * 2 * 3.14159,
                              child: Opacity(
                                opacity: _isOpen ? 1.0 : 0.5,
                                child: Transform.translate(
                                  offset: const Offset(-4, 0),
                                  child: Icon(
                                    Icons.apps_rounded,
                                    color: currentModule.color,
                                    size: 28,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildModuleButtons(
    BuildContext context,
    List<ZagModule> modules,
    ZagModule currentModule,
    double spacing,
  ) {
    if (!_isOpen) return [];

    final buttons = <Widget>[];
    final visibleModules = modules
        .where(
            (m) => m.key.toLowerCase() != widget.currentModuleKey.toLowerCase())
        .toList()
        .reversed
        .toList();

    print(
        '🔍 CUBE: Building ${visibleModules.length} module buttons with spacing: $spacing');

    for (int i = 0; i < visibleModules.length; i++) {
      final module = visibleModules[i];
      final distance = spacing * (i + 1);

      buttons.add(
        Positioned(
          bottom: 0,
          child: Transform.translate(
            offset: const Offset(-4, 0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final slideDistance = distance * _animationController.value;
                final opacity = _animationController.value;
                return Transform.translate(
                  offset: Offset(0, -slideDistance),
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                );
              },
              child: _buildModuleButton(context, module),
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  Widget _buildModuleButton(BuildContext context, ZagModule module) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: module.color.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: () async {
            print('🔍 CUBE: Module button tapped: ${module.title}');
            print('🔍 CUBE: Module key: ${module.key}');
            print('🔍 CUBE: Module is enabled: ${module.isEnabled}');
            print('🔍 CUBE: Module homeRoute: ${module.homeRoute}');
            print('🔍 CUBE: Closing menu...');
            _toggle();

            await Future.delayed(const Duration(milliseconds: 100));

            // Route saving is handled automatically by _RouteLocationTracker
            print('🔍 CUBE: Calling module.launch(restore: false)...');
            try {
              await module.launch(restore: false);
              print('🔍 CUBE: module.launch() completed successfully');

              // Track that we're switching from current module to new module
              _updateTracking(widget.currentModuleKey, module.key);
            } catch (e, stack) {
              print('🔍 CUBE: ERROR during launch: $e');
              print('🔍 CUBE: Stack trace: $stack');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(7.35),
            child: Icon(
              module.icon,
              color: module.color,
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}
