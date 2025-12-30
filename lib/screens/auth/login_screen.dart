import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sgtour_mobile/screens/home/main_navigation.dart';
import 'package:sgtour_mobile/services/auth/auth_service.dart';
import 'package:sgtour_mobile/services/map/location_service.dart';
import 'package:sgtour_mobile/widgets/common/decorative_circle_background.dart';
import 'package:sgtour_mobile/widgets/notification_popup.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../api/api_service.dart';
import 'package:dio/dio.dart';
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
  static final auth = AuthService();
  bool _isLoading = false;

  final double _inputHeight = 70;
  final double _buttonHeight = 60;
  final double _itemSpacing = 24;

  static const double _spacingXl = 48;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final text = _emailController.text.trim();
    final isEmail = text.contains('@');

    await auth
        .login(
          email: isEmail ? text : null,
          phone: isEmail ? null : text,
          password: _passwordController.text,
          typeUser: 'customer',
        )
        .then((_) async {
          if (!mounted) return;
          NotificationPopup.show(
            context,
            context.l10n.auth_loginSuccess,
            isSuccess: true,
          );
          setState(() => _isLoading = false);
          await _navigateAfterLogin();
        })
        .catchError((e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          NotificationPopup.show(
            context,
            context.l10n.auth_loginFailed,
            isSuccess: false,
          );
        });
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

  void _handleGoogleLogin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final api = ApiService();
    final auth = AuthService.fromApi(api: api);

    auth
        .loginWithGoogle(typeUser: 'customer')
        .then((_) async {
          if (!mounted) return;
          Navigator.of(context).pop();
          NotificationPopup.show(
            context,
            context.l10n.auth_loginSuccess,
            isSuccess: true,
          );
          await _navigateAfterLogin();
        })
        .catchError((e) {
          if (!mounted) return;
          Navigator.of(context).pop();
          var message = 'Google sign-in failed';
          if (e is DioException) {
            final data = e.response?.data;
            if (data is Map && data['message'] != null) {
              message = data['message'].toString();
            }
          } else if (e is Exception) {
            message = e.toString();
          }
          NotificationPopup.show(context, message, isSuccess: false);
        });
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
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 40,
                bottom: 24 + bottomPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(isDark),
                      SizedBox(height: _spacingXl),
                      _buildForm(isDark),
                      SizedBox(height: _spacingXl),
                      _buildDivider(isDark),
                      SizedBox(height: _spacingXl),
                      _buildSocialLogin(),
                    ],
                  ),

                  _buildSignUpLink(),
                ],
              ),
            ),
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
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _handleForgotPassword,
              child: Text(
                context.l10n.auth_forgotPassword,
                style: AppTextStyles.subtitle2.copyWith(
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
              minimumSize: Size(double.infinity, _buttonHeight),
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
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _handleSignUp,
          child: Text(
            context.l10n.auth_createAccount,
            style: AppTextStyles.subtitle2.copyWith(
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
      height: _buttonHeight,
      label: context.l10n.auth_loginWithGoogle,
      icon: SvgPicture.asset(
        'assets/icons/google_icon.svg',
        width: 24,
        height: 24,
      ),
      onPressed: _handleGoogleLogin,
    );
  }
}
