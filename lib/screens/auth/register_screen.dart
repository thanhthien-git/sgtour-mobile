import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sgtour_mobile/widgets/common/decorative_circle_background.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import 'widgets/social_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  final double _inputHeight = 56;
  final double _itemSpacing = 24;

  static const double _spacingXl = 24;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate register API call
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Register successful!')));
      });
    }
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Stack(
        children: [
          const DecorativeCircleBackground(),
          // Main Content (Centered & Scrollable)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
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
                  // Extra space for bottom link
                ],
              ),
            ),
          ),
          // Login Link (Fixed at bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: _buildLoginLink(),
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
            'Đăng ký',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _itemSpacing),
          Text(
            'Tạo tài khoản để bắt đầu',
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
            hintText: 'Họ và tên',
            controller: _nameController,
            keyboardType: TextInputType.name,
            prefixIcon: Icon(
              Icons.person_outline,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
          ),
          SizedBox(height: _itemSpacing),
          // Email Field
          CustomTextField(
            height: _inputHeight,
            hintText: 'Email hoặc số điện thoại',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập email hoặc số điện thoại';
              }
              return null;
            },
          ),
          SizedBox(height: _itemSpacing),
          // Password Field
          CustomTextField(
            height: _inputHeight,
            hintText: 'Mật khẩu',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập mật khẩu';
              }
              if ((value?.length ?? 0) < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              return null;
            },
          ),
          SizedBox(height: _itemSpacing),
          // Confirm Password Field
          CustomTextField(
            height: _inputHeight,
            hintText: 'Nhập lại mật khẩu',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: isDark ? Colors.grey[400] : AppColors.textSecondary,
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập lại mật khẩu';
              }
              if (value != _passwordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
          ),
          SizedBox(height: _itemSpacing),
          // Register Button
          CustomButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, _inputHeight),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: 'Đăng ký',
            onPressed: _handleRegister,
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
            'Đã có tài khoản?',
            style: AppTextStyles.body2.copyWith(color: AppColors.text),
          ),
          const SizedBox(width: 8),
          Text(
            'Đăng nhập ngay',
            style: AppTextStyles.body2.copyWith(color: AppColors.success),
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
            'hoặc',
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

  Widget _buildSocialLogin() {
    return SocialButton(
      height: _inputHeight,
      label: 'Google',
      icon: SvgPicture.asset(
        'assets/icons/google_icon.svg',
        width: 24,
        height: 24,
      ),
      onPressed: _handleGoogleLogin,
    );
  }
}
