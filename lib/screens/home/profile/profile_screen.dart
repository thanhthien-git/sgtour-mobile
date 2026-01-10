import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgtour_mobile/screens/home/profile/profile_form.dart';
import 'package:sgtour_mobile/services/file/cloudinary_service.dart';
import 'package:sgtour_mobile/services/user_service.dart';
import 'package:sgtour_mobile/widgets/notification_popup.dart';
import '../../../widgets/common/refreshable_body.dart';
import '../../../models/user/user_profile_model.dart';
import '../../../utils/extensions/localization_extension.dart';
import '../../../widgets/common/base_scaffold.dart';
import '../../../widgets/profile/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  UserProfileModel? _originalProfile;
  UserProfileModel? _editingProfile;

  File? _localAvatarFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  bool get _hasChanges {
    if (_originalProfile == null || _editingProfile == null) return false;
    return _originalProfile != _editingProfile;
  }

  Future<void> _fetchUserProfile() async {
    try {
      final res = await UserService.getProfile();

      if (!mounted) return;

      setState(() {
        _originalProfile = res;
        _editingProfile = res;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onProfileChanged(UserProfileModel newProfile) {
    setState(() => _editingProfile = newProfile);
  }

  Future<void> _onSave() async {
    if (_editingProfile == null || !_hasChanges) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isLoading = true);

    try {
      final updatedProfile = await UserService.updateProfile(_editingProfile!);
      if (!mounted) return;
      setState(() {
        _originalProfile = updatedProfile;
        _editingProfile = updatedProfile;
        _isLoading = false;
      });

      NotificationPopup.show(
        context,
        context.l10n.common_success,
        isSuccess: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      NotificationPopup.show(
        context,
        context.l10n.common_error,
        isSuccess: false,
      );
    }
  }

  Future<void> _onAvatarTap() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final File imageFile = File(pickedFile.path);

      setState(() {
        _localAvatarFile = imageFile;
      });

      _handleBackgroundUpload(imageFile);
    } catch (e) {}
  }

  Future<void> _handleBackgroundUpload(File imageFile) async {
    try {
      final String? secureUrl = await CloudinaryService.uploadImage(imageFile);

      if (secureUrl == null) throw Exception("Cloudinary upload failed");

      if (mounted) {
        setState(() {
          _editingProfile = _editingProfile?.copyWith(avatarUrl: secureUrl);
        });
      }
      if (_editingProfile != null) {
        final profileToUpdate = _editingProfile!.copyWith(avatarUrl: secureUrl);

        await UserService.updateProfile(profileToUpdate);

        if (mounted) {
          setState(() {
            _originalProfile = profileToUpdate;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _localAvatarFile = null;
        });
        NotificationPopup.show(
          context,
          "Không thể cập nhật ảnh đại diện",
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshableBody(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          onRefresh: _fetchUserProfile,
          child: Column(
            children: [
              const SizedBox(height: 24),
              ProfileAvatar(
                imageUrl: _originalProfile?.avatarUrl,
                size: 120,
                showEditIcon: true,
                onTap: _onAvatarTap,
              ),

              const SizedBox(height: 24),
              ProfileForm(
                profile: _editingProfile ?? UserProfileModel.empty(),
                onProfileChanged: _onProfileChanged,
                onSave: _hasChanges ? _onSave : () {},
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
