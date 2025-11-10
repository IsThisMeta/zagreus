import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ZagModuleSwitcherFAB extends StatefulWidget {
  final String currentModuleKey;

  const ZagModuleSwitcherFAB({
    Key? key,
    required this.currentModuleKey,
  }) : super(key: key);

  static void updateModuleTracking(String moduleKey) {
    _ZagModuleSwitcherFABState._updateTracking(moduleKey);
  }

  @override
  State<ZagModuleSwitcherFAB> createState() => _ZagModuleSwitcherFABState();
}

class _ZagModuleSwitcherFABState extends State<ZagModuleSwitcherFAB> {
  static String? _lastLaunchedModuleKey;
  static String? _previousModuleKey;

  static void _updateTracking(String moduleKey) {
    if (_lastLaunchedModuleKey == moduleKey) return;
    _previousModuleKey = _lastLaunchedModuleKey;
    _lastLaunchedModuleKey = moduleKey;
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
      } catch (_) {
        modules = ZagModule.active
          ..sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      }
    }

    modules = modules.where((module) {
      final needsPro = module == ZagModule.DISCOVER ||
          module == ZagModule.OVERSEERR ||
          module == ZagModule.SERVER;
      if (needsPro && !ZagreusPro.isEnabled) {
        return false;
      }
      return module.isEnabled;
    }).toList();

    if (!modules.contains(ZagModule.DASHBOARD)) {
      modules.insert(0, ZagModule.DASHBOARD);
    }

    return modules;
  }

  Future<void> _handleModuleTap(ZagModule module, bool isCurrent) async {
    if (isCurrent) {
      if (_previousModuleKey != null &&
          _previousModuleKey != module.key &&
          ZagModule.fromKey(_previousModuleKey!)?.isEnabled == true) {
        final previous = ZagModule.fromKey(_previousModuleKey!)!;
        _updateTracking(previous.key);
        await previous.launch();
      }
      return;
    }

    _updateTracking(module.key);
    await module.launch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) {
        final modules = _getActiveModules();
        if (modules.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentKey = widget.currentModuleKey.toLowerCase();
        return RepaintBoundary(
          child: Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.15)
                  : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < modules.length; i++) ...[
                  _ModuleIconButton(
                    module: modules[i],
                    isActive: modules[i].key.toLowerCase() == currentKey,
                    onTap: () => _handleModuleTap(
                      modules[i],
                      modules[i].key.toLowerCase() == currentKey,
                    ),
                  ),
                  if (i != modules.length - 1) const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModuleIconButton extends StatelessWidget {
  final ZagModule module;
  final bool isActive;
  final VoidCallback onTap;

  const _ModuleIconButton({
    Key? key,
    required this.module,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color iconColor =
        isActive ? module.color : (isDark ? Colors.white70 : Colors.black54);

    return Tooltip(
      message: module.title,
      waitDuration: const Duration(milliseconds: 400),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 38,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isActive)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: module.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              Icon(
                module.icon,
                color: iconColor,
                size: isActive ? 26 : 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
