import 'package:flutter/material.dart';
import 'package:sgtourcus/config/app_colors.dart';
import 'package:sgtourcus/config/app_text_styles.dart';
import 'package:sgtourcus/screens/home/profile/profile_screen.dart';
import 'package:sgtourcus/screens/home/settings_screen.dart';
import 'package:sgtourcus/widgets/common/base_scaffold.dart';
import '../../../utils/extensions/localization_extension.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseScaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MenuTile(
                icon: Icons.person_outline,
                label: l10n.profile_title,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              const SettingsContent(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 16),
              Text(label, style: AppTextStyles.body1.copyWith(color: textColor)),
              const Spacer(),
              Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
