import 'package:flutter/material.dart';
import 'package:zagreus/main.dart';
import 'package:zagreus/system/recovery_mode/action_tile.dart';

class BootstrapTile extends RecoveryActionTile {
  const BootstrapTile({
    super.key,
    super.title = 'Bootstrap Zagreus',
    super.description = 'Run the bootstrap process and show any errors',
  });

  @override
  Future<void> action(BuildContext context) async {
    try {
      await bootstrap();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bootstrap completed')),
        );
      }
    } catch (error, stack) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Bootstrap Failed'),
          content: SingleChildScrollView(
            child: Text('$error\n\n$stack'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
