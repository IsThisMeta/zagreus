import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/qbit/core/state.dart';
import 'package:zagreus/modules/qbit/core/api/api.dart';

class QBitQueueFAB extends StatelessWidget {
  final QBitAPI api;
  final VoidCallback onComplete;

  const QBitQueueFAB({
    Key? key,
    required this.api,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<QBitState, bool>(
      selector: (_, model) => model.paused,
      builder: (context, paused, _) {
        return FloatingActionButton(
          heroTag: 'qbit_fab',
          onPressed: () => _togglePause(context, paused),
          backgroundColor: paused ? ZagColours.currentAccent : ZagColours.orange,
          child: Icon(
            paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Future<void> _togglePause(BuildContext context, bool isPaused) async {
    try {
      if (isPaused) {
        await api.resumeAll();
        showZagSuccessSnackBar(
          title: 'Resumed All Torrents',
          message: null,
        );
      } else {
        await api.pauseAll();
        showZagSuccessSnackBar(
          title: 'Paused All Torrents',
          message: null,
        );
      }
      onComplete();
    } catch (error) {
      showZagErrorSnackBar(
        title: isPaused ? 'Failed to Resume' : 'Failed to Pause',
        error: error,
      );
    }
  }
}
