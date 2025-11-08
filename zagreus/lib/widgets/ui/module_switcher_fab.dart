import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ZagModuleSwitcherFAB extends StatefulWidget {
  final String currentModuleKey;

  const ZagModuleSwitcherFAB({
    Key? key,
    required this.currentModuleKey,
  }) : super(key: key);

  @override
  State<ZagModuleSwitcherFAB> createState() => _ZagModuleSwitcherFABState();
}

class _ZagModuleSwitcherFABState extends State<ZagModuleSwitcherFAB>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  // Track last launched module for long press
  static String? _lastLaunchedModuleKey;

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

    // Filter out premium modules if not Pro
    modules = modules.where((module) {
      if ((module == ZagModule.DISCOVER ||
              module == ZagModule.OVERSEERR ||
              module == ZagModule.SERVER) &&
          !ZagreusPro.isEnabled) {
        return false;
      }
      return module.isEnabled;
    }).toList();

    // Add Dashboard at the beginning if not there
    if (!modules.contains(ZagModule.DASHBOARD)) {
      modules.insert(0, ZagModule.DASHBOARD);
    }

    return modules;
  }

  @override
  Widget build(BuildContext context) {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) {
        final modules = _getActiveModules();
        print('🔍 FAB: Active modules count: ${modules.length}');
        print('🔍 FAB: Modules: ${modules.map((m) => m.title).join(", ")}');

        final currentModule = modules.firstWhere(
          (m) => m.key.toLowerCase() == widget.currentModuleKey.toLowerCase(),
          orElse: () => ZagModule.DASHBOARD,
        );
        print('🔍 FAB: Current module: ${currentModule.title}');

        // Calculate dynamic height: 56px for FAB + 72px per module button
        final moduleCount = modules.where((m) => m.key.toLowerCase() != widget.currentModuleKey.toLowerCase()).length;
        final dynamicHeight = 56.0 + (72.0 * moduleCount);
        print('🔍 FAB: Module count (excluding current): $moduleCount, Dynamic height: $dynamicHeight');

        return SizedBox(
          width: 56,
          height: _isOpen ? dynamicHeight : 56, // Expand dynamically based on module count
          child: Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              // Module buttons - these are positioned widgets and will be on top
              ..._buildModuleButtons(context, modules, currentModule),
              // Main FAB - always on top
              Positioned(
                bottom: 0,
                right: 0,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        print('🔍 FAB: Main FAB tapped, isOpen: $_isOpen');
                        _toggle();
                      },
                      onLongPress: () async {
                        if (_isOpen) return;
                        
                        print('🔍 FAB: Long press detected!');
                        if (_lastLaunchedModuleKey != null) {
                          print('🔍 FAB: Launching last used module: $_lastLaunchedModuleKey');
                          final lastModule = modules.firstWhere(
                            (m) => m.key == _lastLaunchedModuleKey,
                            orElse: () => modules.first,
                          );
                          
                          try {
                            await lastModule.launch();
                            print('🔍 FAB: Successfully launched $_lastLaunchedModuleKey');
                          } catch (e) {
                            print('🔍 FAB: Error launching module: $e');
                          }
                        } else {
                          print('🔍 FAB: No last module tracked yet');
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
                                child: Icon(
                                  Icons.apps_rounded,
                                  color: currentModule.color,
                                  size: 32,
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
  ) {
    if (!_isOpen) return [];

    final buttons = <Widget>[];
    final visibleModules = modules
        .where(
            (m) => m.key.toLowerCase() != widget.currentModuleKey.toLowerCase())
        .toList()
        .reversed // Reverse so first module is farthest, last is closest
        .toList();

    print('🔍 FAB: Building ${visibleModules.length} module buttons');

    for (int i = 0; i < visibleModules.length; i++) {
      final module = visibleModules[i];
      final distance = 72.0 * (i + 1);

      buttons.add(
        Positioned(
          bottom: 0,
          right: 0,
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
      );
    }

    return buttons;
  }

  Widget _buildModuleButton(BuildContext context, ZagModule module) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(28),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: module.color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () async {
            print('🔍 FAB: Module button tapped: ${module.title}');
            print('🔍 FAB: Module key: ${module.key}');
            print('🔍 FAB: Module is enabled: ${module.isEnabled}');
            print('🔍 FAB: Module homeRoute: ${module.homeRoute}');
            print('🔍 FAB: Closing menu...');
            _toggle();

            await Future.delayed(const Duration(milliseconds: 100));

            print('🔍 FAB: Calling module.launch()...');
            try {
              await module.launch();
              print('🔍 FAB: module.launch() completed successfully');
              
              // Track this as the last launched module
              _lastLaunchedModuleKey = module.key;
              print('🔍 FAB: Saved last launched module: ${module.key}');
            } catch (e, stack) {
              print('🔍 FAB: ERROR during launch: $e');
              print('🔍 FAB: Stack trace: $stack');
            }
          },
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  module.icon,
                  color: module.color,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  module.key == 'dashboard' ? 'Home' : module.title,
                  style: TextStyle(
                    color: module.color,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
