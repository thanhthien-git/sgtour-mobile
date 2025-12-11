import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../enums/gender.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/user_profile_model.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_date_picker.dart';
import '../../../widgets/common/custom_dropdown.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/labeled_form_field.dart';

/// Profile form widget containing all editable fields
class ProfileForm extends StatefulWidget {
  final UserProfileModel profile;
  final ValueChanged<UserProfileModel> onProfileChanged;
  final VoidCallback onSave;
  final bool isLoading;

  const ProfileForm({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final double _fieldSpacing = 24;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
  }

  @override
  void didUpdateWidget(ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _nameController.text = widget.profile.name;
      _emailController.text = widget.profile.email;
      _phoneController.text = widget.profile.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name field
        LabeledFormField(
          label: l10n.profile_name,
          child: CustomTextField(
            controller: _nameController,
            hintText: l10n.profile_name,
            reserveErrorSpace: false,
            onChanged: (value) =>
                widget.onProfileChanged(widget.profile.copyWith(name: value)),
          ),
        ),
        SizedBox(height: _fieldSpacing),

        // Email field
        LabeledFormField(
          label: l10n.profile_email,
          child: CustomTextField(
            controller: _emailController,
            hintText: l10n.profile_email,
            keyboardType: TextInputType.emailAddress,
            reserveErrorSpace: false,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            onChanged: (value) =>
                widget.onProfileChanged(widget.profile.copyWith(email: value)),
          ),
        ),
        SizedBox(height: _fieldSpacing),

        // Change password field
        LabeledFormField(
          label: l10n.profile_changePassword,
          child: CustomTextField(
            hintText: '••••••••',
            obscureText: true,
            reserveErrorSpace: false,
            suffixIcon: Icon(
              Icons.lock_outline,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: _fieldSpacing),

        // Gender dropdown
        LabeledFormField(
          label: l10n.profile_gender,
          child: CustomDropdown<Gender>(
            value: widget.profile.gender,
            prefixIcon: Icon(
              Icons.person_outline,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              size: 20,
            ),
            items: Gender.getDropdownItems(l10n),
            onChanged: (value) {
              if (value != null) {
                widget.onProfileChanged(widget.profile.copyWith(gender: value));
              }
            },
          ),
        ),
        SizedBox(height: _fieldSpacing),

        // Birth date field
        LabeledFormField(
          label: l10n.profile_birthDate,
          child: CustomDatePicker(
            value: widget.profile.birthDate,
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              size: 20,
            ),
            onChanged: (value) => widget.onProfileChanged(
              widget.profile.copyWith(birthDate: value),
            ),
          ),
        ),
        SizedBox(height: _fieldSpacing),

        // Phone number field
        LabeledFormField(
          label: l10n.profile_phone,
          child: CustomTextField(
            controller: _phoneController,
            hintText: l10n.profile_phone,
            keyboardType: TextInputType.phone,
            reserveErrorSpace: false,
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            onChanged: (value) => widget.onProfileChanged(
              widget.profile.copyWith(phoneNumber: value),
            ),
          ),
        ),
        SizedBox(height: _fieldSpacing),

        // Save button
        Center(
          child: SizedBox(
            width: 200,
            height: 48,
            child: CustomButton(
              label: l10n.profile_save,
              onPressed: widget.onSave,
              isLoading: widget.isLoading,
            ),
          ),
        ),
      ],
    );
  }
}
