import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../providers/biometric_provider.dart';
import '../../services/biometric_service.dart';

class BiometricLoginButton extends ConsumerWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const BiometricLoginButton({super.key, this.onSuccess, this.onError});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricState = ref.watch(biometricProvider);

    if (!biometricState.isAvailable) {
      return const SizedBox.shrink();
    }

    final icon = biometricState.primaryBiometric == BiometricType.face
        ? Icons.face
        : Icons.fingerprint;
    final label = biometricState.primaryBiometric == BiometricType.face
        ? 'Face ID'
        : 'Fingerprint';

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: biometricState.isLoading
            ? null
            : () => _handleBiometricLogin(context, ref),
        icon: biometricState.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBiometricLogin(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Implementation in login screen
  }
}

class BiometricToggleSwitch extends ConsumerWidget {
  final String userId;

  const BiometricToggleSwitch({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricState = ref.watch(biometricProvider);

    if (!biometricState.isAvailable) {
      return const SizedBox.shrink();
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                biometricState.primaryBiometric == BiometricType.face
                    ? Icons.face
                    : Icons.fingerprint,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      biometricState.primaryBiometric == BiometricType.face
                          ? 'Face ID Login'
                          : 'Fingerprint Login',
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enable quick login',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitch(
                value: biometricState.isEnabled,
                onChanged: biometricState.isLoading
                    ? null
                    : (value) async {
                        if (value) {
                          // Show dialog to enable biometric
                          _showEnableBiometricDialog(context, ref, userId);
                        } else {
                          await ref
                              .read(biometricProvider.notifier)
                              .disableBiometric(userId);
                        }
                      },
                isLoading: biometricState.isLoading,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEnableBiometricDialog(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Biometric Login'),
        content: const Text(
          'You will be asked to authenticate. Your biometric data will be securely stored.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Get token from current auth state and enable biometric
              // This should be implemented based on your auth structure
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}

class AnimatedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isLoading;

  const AnimatedSwitch({
    required this.value,
    required this.onChanged,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value ? AppColors.primary : AppColors.textSecondary,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
