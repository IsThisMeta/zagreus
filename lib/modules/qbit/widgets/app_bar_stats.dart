import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/qbit/core/state.dart';

class QBitAppBarStats extends StatelessWidget {
  const QBitAppBarStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<QBitState, String>(
      selector: (_, model) => '${model.currentDownloadSpeed}|${model.currentUploadSpeed}',
      builder: (context, speeds, _) {
        final parts = speeds.split('|');
        final dlSpeed = parts[0];
        final upSpeed = parts[1];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_downward_rounded,
              size: 16,
              color: ZagColours.currentAccent,
            ),
            const SizedBox(width: 2),
            Text(
              dlSpeed,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_upward_rounded,
              size: 16,
              color: ZagColours.orange,
            ),
            const SizedBox(width: 2),
            Text(
              upSpeed,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }
}
