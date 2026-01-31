import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtourcus/screens/auth/login_screen.dart';
import 'package:sgtourcus/services/auth/auth_service.dart';
import 'package:sgtourcus/widgets/dialogs/confirmation_dialog.dart';
import 'package:sgtourcus/widgets/dialogs/contact_dialog.dart';
import 'package:sgtourcus/widgets/dialogs/policy_bottom_sheet.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../constants/language_options.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/biometric_provider.dart';
import '../../utils/extensions/localization_extension.dart';
import '../../widgets/common/base_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: const [
              _DarkModeToggle(),
              SizedBox(height: 16),
              _BiometricToggle(),
              SizedBox(height: 16),
              _LanguageSelector(),
              SizedBox(height: 16),
              _ContactButton(),
              SizedBox(height: 16),
              _PolicyButton(policyType: 'privacy'),
              SizedBox(height: 16),
              _PolicyButton(policyType: 'terms'),
              SizedBox(height: 16),
              _LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSelector extends ConsumerStatefulWidget {
  const _LanguageSelector();

  @override
  ConsumerState<_LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends ConsumerState<_LanguageSelector> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider.select((s) => s.locale));
    final currentLanguage = languageOptions.firstWhere(
      (lang) => lang.locale == currentLocale,
      orElse: () => languageOptions.first,
    );

    return _SettingsCard(
      title: l10n.settings_language,
      icon: Icons.language,
      trailing: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: AppColors.primary,
        ),
      ),
      child: Column(
        children: [
          _LanguageOption(
            key: ValueKey(currentLanguage.locale.languageCode),
            title: currentLanguage.title,
            isSelected: true,
            onTap: () {},
            isDark: isDark,
          ),
          if (_isExpanded) ...[
            for (final lang in languageOptions) ...[
              if (lang.locale != currentLocale)
                Column(
                  children: [
                    Divider(
                      height: 1,
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    _LanguageOption(
                      key: ValueKey(lang.locale.languageCode),
                      title: lang.title,
                      isSelected: false,
                      onTap: () {
                        ref
                            .read(localeProvider.notifier)
                            .setLocale(lang.locale);
                        setState(() {
                          _isExpanded = false;
                        });
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
            ],
          ] else if (languageOptions.length > 1) ...[
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = true;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.common_other,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual language option row
class _LanguageOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _LanguageOption({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.subtitle2.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            _RadioIndicator(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final bool isSelected;

  const _RadioIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}

class _DarkModeToggle extends ConsumerWidget {
  const _DarkModeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDark;

    return _SettingsCard(
      title: l10n.settings_darkMode,
      icon: isDark ? Icons.dark_mode : Icons.light_mode,
      trailing: _SimpleSwitch(
        value: isDark,
        onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
      ),
    );
  }
}

class _BiometricToggle extends ConsumerWidget {
  const _BiometricToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final biometricState = ref.watch(biometricProvider);

    if (!biometricState.isAvailable) {
      return const SizedBox.shrink();
    }

    final isFaceId =
        biometricState.primaryBiometric?.toString().contains('face') ?? false;
    final biometricLabel = isFaceId
        ? l10n.biometric_login_face
        : l10n.biometric_login_fingerprint;

    return _SettingsCard(
      title: biometricLabel,
      icon: isFaceId ? Icons.face : Icons.fingerprint,
      trailing: biometricState.isLoading
          ? SizedBox(
              width: 50,
              height: 28,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            )
          : _SimpleSwitch(
              value: biometricState.isEnabled,
              onChanged: (_) {
                if (biometricState.isEnabled) {
                  ref
                      .read(biometricProvider.notifier)
                      .disableBiometric('user_id');
                } else {
                  _showEnableBiometricDialog(context, ref);
                }
              },
            ),
      child: biometricState.isLoading
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          : null,
    );
  }

  void _showEnableBiometricDialog(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    ConfirmationDialog.show(
      context: context,
      title: l10n.biometric_enable_title,
      content: l10n.biometric_enable_desc,
      cancelText: l10n.common_cancel,
      confirmText: l10n.common_confirm,
      onConfirm: () async {
        await ref
            .read(biometricProvider.notifier)
            .enableBiometric('user_id', 'token_here');
      },
    );
  }
}

class _SimpleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SimpleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        tween: Tween<double>(begin: 0, end: value ? 1 : 0),
        builder: (context, position, child) {
          return Container(
            width: 50,
            height: 28,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Color.lerp(
                AppColors.textSecondary,
                AppColors.primary,
                position,
              ),
            ),
            child: Align(
              alignment: Alignment(position * 2 - 1, 0),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.error),
          borderRadius: BorderRadius.circular(12),
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              l10n.auth_logout,
              style: AppTextStyles.subtitle2.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = context.l10n;

    ConfirmationDialog.show(
      context: context,
      title: l10n.auth_logout,
      content: l10n.logout_confirm,
      cancelText: l10n.common_cancel,
      confirmText: l10n.auth_logout,
      isDestructive: true,
      onConfirm: () => _logout(context),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? child;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsCard({
    required this.title,
    required this.icon,
    this.child,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.subtitle2.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          if (child != null) ...[
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            child!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}

/// Contact support button
class _ContactButton extends StatelessWidget {
  const _ContactButton();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _SettingsCard(
      title: l10n.settings_contact,
      icon: Icons.phone,
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.primary,
        size: 16,
      ),
      onTap: () => showDialog(
        context: context,
        builder: (context) => const ContactDialog(),
      ),
    );
  }
}

/// Policy button - generic implementation for different policy types
class _PolicyButton extends StatelessWidget {
  final String policyType; // 'privacy' or 'terms'

  const _PolicyButton({required this.policyType});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Get localized title based on policy type
    final title = policyType == 'privacy'
        ? l10n.settings_privacy
        : l10n.settings_terms;

    return _SettingsCard(
      title: title,
      icon: policyType == 'privacy' ? Icons.privacy_tip : Icons.description,
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.primary,
        size: 16,
      ),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: PolicyBottomSheet(policyType: policyType, title: title),
        ),
      ),
    );
  }
}
