import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtour_mobile/config/app_colors.dart';
import 'package:sgtour_mobile/config/app_text_styles.dart';
import 'package:sgtour_mobile/providers/policy_provider.dart';
import 'package:sgtour_mobile/utils/extensions/localization_extension.dart';

/// Bottom sheet for displaying policy content
class PolicyBottomSheet extends ConsumerWidget {
  final String policyType; // 'privacy' or 'terms'
  final String? title;

  const PolicyBottomSheet({super.key, required this.policyType, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final policyAsync = ref.watch(policyProvider(policyType));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title ?? policyType.toUpperCase(),
                    style: AppTextStyles.heading3.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          // Content
          Expanded(
            child: policyAsync.when(
              data: (policy) =>
                  _PolicyContent(content: policy.content, isDark: isDark),
              loading: () => _LoadingState(isDark: isDark),
              error: (error, stack) => _ErrorState(
                isDark: isDark,
                onRetry: () => ref.refresh(policyProvider(policyType)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyContent extends StatelessWidget {
  final String content;
  final bool isDark;

  const _PolicyContent({required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        content,
        style: AppTextStyles.body2.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final bool isDark;

  const _LoadingState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _ErrorState({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            l10n.common_error,
            style: AppTextStyles.subtitle2.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load content',
            style: AppTextStyles.body2.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(l10n.common_retry),
          ),
        ],
      ),
    );
  }
}
