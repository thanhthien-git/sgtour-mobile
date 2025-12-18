import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;
  final double? height;
  final bool reserveErrorSpace;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height,
    this.reserveErrorSpace = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double fieldHeight = widget.height ?? 56;
    final double verticalPadding = (fieldHeight - 20) / 2;
    const double errorHeight = 18;

    Widget textField = TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _isObscured,
      onChanged: widget.onChanged,
      validator: widget.validator != null
          ? (value) {
              final error = widget.validator!(value);
              if (error != _errorText) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _errorText = error);
                  }
                });
              }
              return error;
            }
          : null,
      textAlignVertical: TextAlignVertical.center,
      style: AppTextStyles.body1.copyWith(
        color: isDark ? Colors.white : AppColors.text,
        height: 1.0,
      ),
      decoration: InputDecoration(
        isDense: true,
        errorStyle: const TextStyle(
          height: 0,
          fontSize: 0,
          color: Colors.transparent,
        ),
        hintText: widget.hintText,
        hintStyle: AppTextStyles.body2.copyWith(
          color: isDark ? Colors.grey[400] : AppColors.textTertiary,
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? GestureDetector(
                onTap: () => setState(() => _isObscured = !_isObscured),
                child: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              )
            : widget.suffixIcon,
        filled: true,
        fillColor: isDark ? Colors.grey[900] : AppColors.inputBackground,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: verticalPadding,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );

    // Build error widget based on reserveErrorSpace setting
    Widget? errorWidget;
    if (widget.reserveErrorSpace) {
      // Always reserve space for error text (prevents layout shift during validation)
      errorWidget = SizedBox(
        height: errorHeight,
        child: _errorText == null
            ? const SizedBox.shrink()
            : Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _errorText!,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.error,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
      );
    } else if (_errorText != null) {
      // Only show error when present (no reserved space)
      errorWidget = Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          _errorText!,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.error,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [textField, if (errorWidget != null) errorWidget],
    );

    if (widget.width != null) {
      return SizedBox(width: widget.width, child: content);
    }

    return content;
  }
}
