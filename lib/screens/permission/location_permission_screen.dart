import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sgtour_mobile/services/map/location_service.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../utils/extensions/localization_extension.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/decorative_circle_background.dart';
import '../home/main_navigation.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingPermission();
  }

  Future<void> _checkExistingPermission() async {
    final status = await LocationService.getLocationStatus();
    if (status == LocationStatus.granted) {
      _navigateToMain();
    }
  }

  Future<void> _handleEnableLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final serviceEnabled = await LocationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _errorMessage = context.l10n.location_serviceDisabled;
      });
      await LocationService.openLocationSettings();
      return;
    }

    final status = await LocationService.requestPermission();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (status.isGranted) {
      _navigateToMain();
    } else if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog();
    } else {
      setState(() {
        _errorMessage = context.l10n.location_permissionRequired;
      });
    }
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  void _showPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          context.l10n.location_permissionDeniedTitle,
          style: AppTextStyles.heading4,
        ),
        content: Text(
          context.l10n.location_permissionDeniedDesc,
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              context.l10n.common_cancel,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              LocationService.openSettings();
            },
            child: Text(
              context.l10n.location_openSettings,
              style: AppTextStyles.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Stack(
        children: [
          const DecorativeCircleBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Icon
                  _buildLocationIcon(isDark),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    context.l10n.location_enableTitle,
                    style: AppTextStyles.heading2.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    context.l10n.location_enableDesc,
                    style: AppTextStyles.body1.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Features list
                  _buildFeaturesList(isDark),

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const Spacer(flex: 3),

                  // Enable button
                  CustomButton(
                    label: context.l10n.location_enableButton,
                    onPressed: _handleEnableLocation,
                    isLoading: _isLoading,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationIcon(bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.location_on,
            size: 48,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(bool isDark) {
    final features = [
      context.l10n.location_feature1,
      context.l10n.location_feature2,
      context.l10n.location_feature3,
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 20, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: AppTextStyles.body2.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
