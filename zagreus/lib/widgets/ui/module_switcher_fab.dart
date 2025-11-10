import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/utils/zagreus_pro.dart';

class ZagModuleSwitcherFAB extends StatefulWidget {
  final String currentModuleKey;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ZagModuleSwitcherFAB({
    Key? key,
    required this.currentModuleKey,
    required this.scaffoldKey,
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
        widget.scaffoldKey.currentState?.closeEndDrawer();
      }
      return;
    }

    _updateTracking(module.key);
    await module.launch();
    widget.scaffoldKey.currentState?.closeEndDrawer();
  }

  Widget _buildModuleDrawer() {
    final modules = _getActiveModules();
    final currentKey = widget.currentModuleKey.toLowerCase();

    return Drawer(
      elevation: ZagUI.ELEVATION,
      backgroundColor: Theme.of(context).primaryColor,
      width: 80,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: modules.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final module = modules[index];
                  final isActive = module.key.toLowerCase() == currentKey;
                  return _ModuleIconButton(
                    module: module,
                    isActive: isActive,
                    onTap: () => _handleModuleTap(module, isActive),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ZagreusDatabase.ENABLED_PROFILE.listenableBuilder(
      builder: (context, _) => _buildModuleDrawer(),
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
    return Tooltip(
      message: module.title,
      waitDuration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 64,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? module.color.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(
                      color: module.color.withOpacity(0.4),
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              module.icon,
              color: module.color.withOpacity(isActive ? 1.0 : 0.5),
              size: isActive ? 32 : 28,
            ),
          ),
        ),
      ),
    );
  }
}
