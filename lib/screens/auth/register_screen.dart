import 'package:flutter/material.dart';
import 'package:sgtour_mobile/api/api_service.dart';
import 'package:sgtour_mobile/screens/auth/login_screen.dart';
import 'package:sgtour_mobile/services/auth/auth_service.dart';
import 'package:sgtour_mobile/widgets/common/decorative_circle_background.dart';
import 'package:sgtour_mobile/widgets/notification_popup.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../utils/extensions/localization_extension.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static final api = ApiService();
  static final auth = AuthService.fromApi(api: api);

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await auth.register(
          name: _nameController.text,
          phoneOrEmail: _phoneOrEmailController.text,
          password: _passwordController.text,
        );
        if (!mounted) return;
        NotificationPopup.show(
          context,
          context.l10n.auth_registerSuccess,
          isSuccess: true,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } catch (e) {
        if (!mounted) return;
        NotificationPopup.show(
          context,
          context.l10n.auth_registerFailed,
          isSuccess: false,
        );
      }
    }
  }

  bool _isLoading = false;

  final double _inputHeight = 70;
  final double _buttonHeight = 60;
  final double _itemSpacing = 24;

  static const double _spacingXl = 24;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneOrEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleLoginNavigation() {
    Navigator.pop(context);
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 44,
                  bottom: bottomPadding + 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(isDark),
                    SizedBox(height: _spacingXl),
                    _buildForm(isDark),
                    SizedBox(height: _spacingXl),
                    _buildDivider(isDark),
                    SizedBox(height: _spacingXl),
                    _buildLoginLink(),
                  ],
                ),
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
            context.l10n.auth_register,
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _itemSpacing),
          Text(
            context.l10n.auth_createAccountToStart,
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
          // Name Field
          CustomTextField(
            height: _inputHeight,
            hintText: context.l10n.auth_fullName,
            controller: _nameController,
            keyboardType: TextInputType.name,
            prefixIcon: Icon(
              Icons.person_outline,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return context.l10n.validation_nameRequired;
              }
              return null;
            },
          ),
          SizedBox(height: _itemSpacing),
          // Email Field
          CustomTextField(
            height: _inputHeight,
            hintText: context.l10n.auth_email,
            controller: _phoneOrEmailController,
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
          // Confirm Password Field
          CustomTextField(
            height: _inputHeight,
            hintText: context.l10n.auth_confirmPassword,
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return context.l10n.validation_confirmPasswordRequired;
              }
              if (value != _passwordController.text) {
                return context.l10n.validation_passwordMismatch;
              }
              return null;
            },
          ),
          SizedBox(height: _itemSpacing),
          // Register Button
          CustomButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, _buttonHeight),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: context.l10n.auth_register,
            onPressed: _register,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: _handleLoginNavigation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.auth_hasAccount,
            style: AppTextStyles.subtitle2.copyWith(color: AppColors.text),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.auth_loginNow,
            style: AppTextStyles.subtitle2.copyWith(color: AppColors.success),
          ),
        ],
      ),
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
              color: isDark ? Colors.grey[400] : AppColors.text,
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
}
