import 'package:flutter/material.dart';
import 'package:zagreus/api/unraid/models.dart';
import 'package:zagreus/api/unraid/unraid.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/unraid.dart';

enum _VmAction {
  start,
  stop,
  reboot,
}

class UnraidVmPage extends StatefulWidget {
  const UnraidVmPage({super.key});

  @override
  State<UnraidVmPage> createState() => _UnraidVmPageState();
}

class _UnraidVmPageState extends State<UnraidVmPage>
    with ZagScrollControllerMixin {
  UnraidVmInfo? _vmInfo;
  bool _loading = true;
  String? _error;
  final Map<String, _VmAction> _pendingActions = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool showLoader = true}) async {
    if (!mounted) return;

    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final info = await _fetchVmInfo();
      if (!mounted) return;

      setState(() {
        _vmInfo = info;
        _loading = false;
        _error = null;
      });
    } catch (error, stackTrace) {
      ZagLogger().error('Failed to load virtual machines', error, stackTrace);
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<UnraidVmInfo> _fetchVmInfo() async {
    final serverState = context.read<UnraidState>();
    final api = UnraidAPI(
      host: serverState.host,
      apiKey: serverState.apiKey,
      headers: serverState.headers,
    );
    return api.getVmInfo();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _vmInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: ZagMessage(
          text: 'Error loading virtual machines',
          buttonText: 'Retry',
          onTap: _loadData,
        ),
      );
    }

    final machines = _vmInfo?.virtualMachines ?? const [];

    return RefreshIndicator(
      onRefresh: () => _loadData(showLoader: false),
      child: ZagListView(
        controller: scrollController,
        children: [
          if (_vmInfo != null) _buildHeaderCard(),
          if (machines.isEmpty)
            _buildEmptyState()
          else
            ...machines.map(_buildVmCard),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final info = _vmInfo!;
    final running = info.runningCount;
    final total = info.totalCount;

    return ZagBlock(
      title: 'VIRTUAL MACHINES',
      body: [
        TextSpan(
          text: '$running of $total VMs running',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ZagUI.DEFAULT_MARGIN_SIZE,
        vertical: 48,
      ),
      child: ZagMessage(
        text: 'Add a VM in Unraid to manage it from here.',
        buttonText: 'Refresh',
        onTap: _loadData,
      ),
    );
  }

  Widget _buildVmCard(UnraidVirtualMachine vm) {
    final pendingAction = _pendingActions[vm.id];
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;
    final titleStyle = (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: theme.textTheme.titleMedium?.color ??
          (isLightTheme ? Colors.black87 : Colors.white),
    );

    return Container(
      margin: const EdgeInsets.only(
        left: ZagUI.DEFAULT_MARGIN_SIZE,
        right: ZagUI.DEFAULT_MARGIN_SIZE,
        bottom: ZagUI.DEFAULT_MARGIN_SIZE,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: isLightTheme ? Border.all(color: Colors.black12) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon, name, and status icon
          Row(
            children: [
              _buildVmAvatar(vm),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  vm.name,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _statusIcon(vm),
                color: _stateColor(vm),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status text
          Text(
            vm.displayState,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _stateColor(vm),
            ),
          ),
          const SizedBox(height: 12),
          // Action buttons
          _buildActionRow(vm, pendingAction),
        ],
      ),
    );
  }

  Widget _buildVmAvatar(UnraidVirtualMachine vm) {
    final color = _stateColor(vm);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.memory_rounded,
        color: color,
        size: 22,
      ),
    );
  }

  Widget _buildActionRow(UnraidVirtualMachine vm, _VmAction? pending) {
    final buttons = _buildActionButtons(vm, pending);
    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        for (int index = 0; index < buttons.length; index++) ...[
          Expanded(child: buttons[index]),
          if (index < buttons.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  List<Widget> _buildActionButtons(
    UnraidVirtualMachine vm,
    _VmAction? pending,
  ) {
    final isBusy = pending != null;
    final buttons = <Widget>[];

    if (vm.canStart) {
      buttons.add(_buildVmButton(
        label: 'Start',
        icon: Icons.play_arrow_rounded,
        color: Colors.green,
        loading: pending == _VmAction.start,
        onTap: isBusy ? null : () => _handleVmAction(vm, _VmAction.start),
      ));
    }

    if (vm.canStop) {
      buttons.add(_buildVmButton(
        label: 'Stop',
        icon: Icons.stop_rounded,
        color: ZagColours.red,
        loading: pending == _VmAction.stop,
        onTap: isBusy ? null : () => _handleVmAction(vm, _VmAction.stop),
      ));
    }

    if (vm.canReboot) {
      buttons.add(_buildVmButton(
        label: 'Reboot',
        icon: Icons.restart_alt_rounded,
        color: ZagColours.orange,
        loading: pending == _VmAction.reboot,
        onTap: isBusy ? null : () => _handleVmAction(vm, _VmAction.reboot),
      ));
    }

    return buttons;
  }

  Widget _buildVmButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool loading,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _handleVmAction(
    UnraidVirtualMachine vm,
    _VmAction action,
  ) async {
    final serverState = context.read<UnraidState>();
    if (!serverState.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configure your server connection first.'),
        ),
      );
      return;
    }

    setState(() {
      _pendingActions[vm.id] = action;
    });

    final api = UnraidAPI(
      host: serverState.host,
      apiKey: serverState.apiKey,
      headers: serverState.headers,
    );

    final actionLabel = switch (action) {
      _VmAction.start => 'start',
      _VmAction.stop => 'stop',
      _VmAction.reboot => 'reboot',
    };

    try {
      switch (action) {
        case _VmAction.start:
          await api.startVm(vm.id);
          break;
        case _VmAction.stop:
          await api.stopVm(vm.id);
          break;
        case _VmAction.reboot:
          await api.rebootVm(vm.id);
          break;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent $actionLabel command to ${vm.name}.'),
        ),
      );

      await _loadData(showLoader: false);
    } catch (error, stackTrace) {
      ZagLogger().error(
        'Failed to $actionLabel VM ${vm.id}',
        error,
        stackTrace,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to $actionLabel VM. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _pendingActions.remove(vm.id);
        });
      }
    }
  }

  Color _stateColor(UnraidVirtualMachine vm) {
    switch (vm.state) {
      case UnraidVmState.running:
        return Colors.green;
      case UnraidVmState.idle:
        return Colors.lightGreen;
      case UnraidVmState.paused:
        return ZagColours.orange;
      case UnraidVmState.shutdown:
      case UnraidVmState.shutoff:
        return Colors.grey;
      case UnraidVmState.crashed:
        return ZagColours.red;
      case UnraidVmState.pmSuspended:
        return Colors.blueAccent;
      case UnraidVmState.unknown:
        return Colors.blueGrey;
    }
  }

  IconData _statusIcon(UnraidVirtualMachine vm) {
    switch (vm.state) {
      case UnraidVmState.running:
        return Icons.check_circle_rounded;
      case UnraidVmState.idle:
        return Icons.hourglass_top_rounded;
      case UnraidVmState.paused:
        return Icons.pause_circle_filled_rounded;
      case UnraidVmState.shutdown:
      case UnraidVmState.shutoff:
        return Icons.power_settings_new_rounded;
      case UnraidVmState.crashed:
        return Icons.error_rounded;
      case UnraidVmState.pmSuspended:
        return Icons.nightlight_round;
      case UnraidVmState.unknown:
        return Icons.help_outline_rounded;
    }
  }
}
