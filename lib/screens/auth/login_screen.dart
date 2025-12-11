import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sgtour_mobile/screens/home/main_navigation.dart';
import 'package:sgtour_mobile/widgets/common/decorative_circle_background.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../services/location_service.dart';
import '../../utils/extensions/localization_extension.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../permission/location_permission_screen.dart';
import 'widgets/social_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final double _inputHeight = 56;
  final double _itemSpacing = 24;

  // Spacing constants (design tokens)
  static const double _spacingXl = 48;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.auth_loginSuccess)));

        // Check location permission and navigate accordingly
        await _navigateAfterLogin();
      });
    }
  }

  Future<void> _navigateAfterLogin() async {
    final status = await LocationService.getLocationStatus();
    if (!mounted) return;

    if (status == LocationStatus.granted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
      );
    }
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Forgot Password tapped')));
  }

  void _handleSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  void _handleGoogleLogin() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Google login tapped')));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const DecorativeCircleBackground(),
          // Main Content (Centered & Scrollable)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 40,
                  bottom: 100 + bottomPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    _buildHeader(isDark),
                    SizedBox(height: _spacingXl),
                    // Form
                    _buildForm(isDark),
                    SizedBox(height: _spacingXl),
                    // Divider
                    _buildDivider(isDark),
                    SizedBox(height: _spacingXl),
                    // Social Login
                    _buildSocialLogin(),
                  ],
                ),
              ),
            ),
          ),
          // Sign Up Link (Fixed at bottom, respects system navigation)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + 24,
            child: _buildSignUpLink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.auth_login,
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _itemSpacing),
          Text(
            context.l10n.auth_welcomeBack,
            style: AppTextStyles.body1.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Field
          CustomTextField(
            height: _inputHeight,
            hintText: context.l10n.auth_email,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return context.l10n.validation_emailRequired;
              }
              return null;
            },
          ),
          SizedBox(height: _itemSpacing),
          // Password Field
          CustomTextField(
            height: _inputHeight,
            hintText: context.l10n.auth_password,
            controller: _passwordController,
            obscureText: true,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return context.l10n.validation_passwordRequired;
              }
              if ((value?.length ?? 0) < 6) {
                return context.l10n.validation_passwordMinLength;
              }
              return null;
            },
          ),
          SizedBox(height: _itemSpacing),
          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _handleForgotPassword,
              child: Text(
                context.l10n.auth_forgotPassword,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: _itemSpacing),
          // Login Button
          CustomButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, _inputHeight),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: context.l10n.auth_login,
            onPressed: _handleLogin,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.auth_noAccount,
          style: AppTextStyles.body2.copyWith(color: AppColors.text),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _handleSignUp,
          child: Text(
            context.l10n.auth_createAccount,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? Colors.grey[700] : AppColors.border,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.l10n.common_or,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? Colors.grey[400] : AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? Colors.grey[700] : AppColors.border,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return SocialButton(
      height: _inputHeight,
      label: 'Tiếp tục với Google',
      icon: SvgPicture.asset(
        'assets/icons/google_icon.svg',
        width: 24,
        height: 24,
      ),
      onPressed: _handleGoogleLogin,
    );
  }
}
