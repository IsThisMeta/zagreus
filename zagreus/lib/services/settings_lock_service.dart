import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/services/biometric_service.dart';
import 'package:zagreus/supabase/auth.dart';
import 'package:zagreus/widgets/ui.dart';
import 'package:zagreus/widgets/ui/snackbar/snackbar_error.dart';
import 'package:zagreus/widgets/ui/snackbar/snackbar_info.dart';
import 'package:zagreus/widgets/ui/snackbar/snackbar_success.dart';

class SettingsLockService {
  SettingsLockService._();

  static final SettingsLockService instance = SettingsLockService._();

  final BiometricService _biometricService = BiometricService.instance;
  final ZagSupabaseAuth _supabaseAuth = ZagSupabaseAuth();

  Future<bool> ensureUnlocked(BuildContext context) async {
    if (!ZagreusDatabase.SETTINGS_LOCK_ENABLED.read()) {
      return true;
    }

    if (!_supabaseAuth.isSignedIn) {
      ZagreusDatabase.SETTINGS_LOCK_ENABLED.update(false);
      ZagreusDatabase.SETTINGS_LOCK_USE_BIOMETRIC.update(false);
      showZagInfoSnackBar(
        title: 'Settings lock disabled',
        message:
            'Settings lock requires an active Zagreus account session. Sign in again to turn it back on.',
      );
      return true;
    }

    final useBiometric = ZagreusDatabase.SETTINGS_LOCK_USE_BIOMETRIC.read();
    if (useBiometric && await _biometricService.isSupported()) {
      final biometricSuccess = await _biometricService.authenticate(
        reason: 'Authenticate to open settings',
      );
      if (biometricSuccess) {
        return true;
      }
    }

    return _promptForPassword(context);
  }

  Future<bool> _promptForPassword(BuildContext context) async {
    final email = _supabaseAuth.email;
    if (email == null) {
      showZagErrorSnackBar(
        title: 'Unable to verify account',
        message: 'Sign in again to unlock settings.',
      );
      return false;
    }

    final controller = TextEditingController();
    bool succeeded = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSubmitting = false;
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> submitWithSetState() async {
              if (isSubmitting) return;
              setState(() {
                errorText = null;
                isSubmitting = true;
              });

              final password = controller.text.trim();
              if (password.isEmpty) {
                setState(() {
                  errorText = 'Password is required';
                  isSubmitting = false;
                });
                return;
              }

              try {
                final response = await _supabaseAuth.signInUser(email, password);
                if (response.state) {
                  succeeded = true;
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  return;
                }

                setState(() {
                  errorText =
                      response.error?.message ?? 'Incorrect password, try again.';
                  isSubmitting = false;
                });
              } catch (error, stack) {
                ZagLogger().error('Failed to verify Supabase password', error, stack);
                setState(() {
                  errorText = 'Unable to verify password right now. Try again.';
                  isSubmitting = false;
                });
              }
            }

            Future<void> sendResetWithSetState() async {
              if (isSubmitting) return;
              setState(() {
                errorText = null;
                isSubmitting = true;
              });
              try {
                await _supabaseAuth.resetPassword(email);
                showZagSuccessSnackBar(
                  title: 'Password reset sent',
                  message: 'Check your email for reset instructions.',
                );
              } catch (error, stack) {
                ZagLogger()
                    .error('Failed to request password reset', error, stack);
                showZagErrorSnackBar(
                  title: 'Failed to send reset email',
                  message: 'Please try again shortly.',
                );
              } finally {
                setState(() {
                  isSubmitting = false;
                });
              }
            }

            return AlertDialog(
              shape: ZagUI.shapeBorder,
              title: const Text('Unlock Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter your Zagreus account password to continue.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    obscureText: true,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submitWithSetState(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: errorText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isSubmitting ? null : sendResetWithSetState,
                      child: const Text('Send password reset email'),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isSubmitting ? null : submitWithSetState,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Unlock'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return succeeded;
  }
}
