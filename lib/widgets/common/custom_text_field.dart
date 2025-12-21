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

  // 1. Biến disable đã có sẵn
  final bool disable;

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
    this.disable = false, // Mặc định là cho phép nhập
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
    final double verticalPadding = (fieldHeight - 24) / 2;
    const double errorHeight = 18;

    final Color disabledTextColor = isDark
        ? Colors.grey[600]!
        : Colors.grey[400]!;
    final Color disabledFillColor = isDark ? Colors.black12 : Colors.grey[100]!;
    final Color disabledBorderColor = isDark
        ? Colors.grey[800]!
        : Colors.grey[300]!;

    Widget textField = TextFormField(
      enabled: !widget.disable,

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
        color: widget.disable
            ? disabledTextColor
            : (isDark ? Colors.white : AppColors.text),
        height: 1.0,
      ),

      decoration: InputDecoration(
        isDense: true,
        errorStyle: const TextStyle(height: 0, fontSize: 0),

        hintText: widget.hintText,
        hintStyle: AppTextStyles.body2.copyWith(
          color: isDark ? Colors.grey[400] : AppColors.textTertiary,
        ),

        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 24,
        ),

        suffixIcon: widget.obscureText
            ? (widget.disable
                  ? null
                  : GestureDetector(
                      onTap: () => setState(() => _isObscured = !_isObscured),
                      child: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: isDark
                            ? Colors.grey[400]
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ))
            : widget.suffixIcon,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 24,
        ),

        filled: true,
        fillColor: widget.disable
            ? disabledFillColor
            : (isDark ? Colors.grey[900] : AppColors.inputBackground),

        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: verticalPadding > 0 ? verticalPadding : 0,
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
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.error),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: disabledBorderColor),
        ),
      ),
    );

    Widget? errorWidget;
    if (widget.reserveErrorSpace) {
      errorWidget = SizedBox(
        height: errorHeight,
        child: _errorText == null
            ? const SizedBox.shrink()
            : Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    _errorText!,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
      );
    } else if (_errorText != null) {
      errorWidget = Padding(
        padding: const EdgeInsets.only(top: 4, left: 4),
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
