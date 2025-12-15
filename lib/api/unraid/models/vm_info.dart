enum UnraidVmState {
  running,
  idle,
  paused,
  shutdown,
  shutoff,
  crashed,
  pmSuspended,
  unknown,
}

extension UnraidVmStateX on UnraidVmState {
  static UnraidVmState fromGraphQl(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'RUNNING':
        return UnraidVmState.running;
      case 'IDLE':
        return UnraidVmState.idle;
      case 'PAUSED':
        return UnraidVmState.paused;
      case 'SHUTDOWN':
        return UnraidVmState.shutdown;
      case 'SHUTOFF':
        return UnraidVmState.shutoff;
      case 'CRASHED':
        return UnraidVmState.crashed;
      case 'PMSUSPENDED':
        return UnraidVmState.pmSuspended;
      default:
        return UnraidVmState.unknown;
    }
  }

  String get label {
    switch (this) {
      case UnraidVmState.running:
        return 'Running';
      case UnraidVmState.idle:
        return 'Idle';
      case UnraidVmState.paused:
        return 'Paused';
      case UnraidVmState.shutdown:
        return 'Shutdown';
      case UnraidVmState.shutoff:
        return 'Off';
      case UnraidVmState.crashed:
        return 'Crashed';
      case UnraidVmState.pmSuspended:
        return 'Power Suspended';
      case UnraidVmState.unknown:
        return 'Unknown';
    }
  }

  bool get isRunning => this == UnraidVmState.running;
  bool get isStopped =>
      this == UnraidVmState.shutdown || this == UnraidVmState.shutoff;
  bool get isErrored => this == UnraidVmState.crashed;
  bool get isSuspended => this == UnraidVmState.pmSuspended;

  bool get canStart =>
      isStopped ||
      this == UnraidVmState.idle ||
      this == UnraidVmState.paused ||
      this == UnraidVmState.pmSuspended ||
      this == UnraidVmState.unknown;
  bool get canStop =>
      this == UnraidVmState.running ||
      this == UnraidVmState.paused ||
      this == UnraidVmState.idle;
  bool get canReboot =>
      this == UnraidVmState.running ||
      this == UnraidVmState.paused ||
      this == UnraidVmState.idle;
}

class UnraidVmInfo {
  final List<UnraidVirtualMachine> virtualMachines;

  const UnraidVmInfo({
    required this.virtualMachines,
  });

  int get totalCount => virtualMachines.length;

  int get runningCount =>
      virtualMachines.where((vm) => vm.state.isRunning).length;

  bool get hasMachines => virtualMachines.isNotEmpty;
}

class UnraidVirtualMachine {
  final String id;
  final String name;
  final UnraidVmState state;
  final String? uuid;

  const UnraidVirtualMachine({
    required this.id,
    required this.name,
    required this.state,
    this.uuid,
  });

  bool get isRunning => state.isRunning;
  bool get isStopped => state.isStopped;
  bool get isErrored => state.isErrored;

  bool get canStart => state.canStart;
  bool get canStop => state.canStop;
  bool get canReboot => state.canReboot;

  String get displayState => state.label;

  String get shortId {
    if (uuid == null || uuid!.isEmpty) return id;
    if (uuid!.length <= 8) return uuid!;
    return uuid!.substring(0, 8).toUpperCase();
  }
}
