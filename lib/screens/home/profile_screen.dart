import 'package:flutter/material.dart';
import 'package:sgtour_mobile/screens/home/profile/profile_form.dart';
import '../../../models/user_profile_model.dart';
import '../../../utils/extensions/localization_extension.dart';
import '../../../widgets/common/base_scaffold.dart';
import '../../../widgets/profile/profile_avatar.dart';

/// Profile screen for viewing and editing user profile
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // In production, this would come from a provider/repository
  late UserProfileModel _profile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load mock profile - in production, fetch from API/local storage
    _profile = UserProfileModel.mock;
  }

  void _onProfileChanged(UserProfileModel newProfile) {
    setState(() => _profile = newProfile);
  }

  Future<void> _onSave() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.common_success),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onAvatarTap() {
    // TODO: Implement image picker
    debugPrint('Avatar tapped - open image picker');
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Avatar
              ProfileAvatar(
                imageUrl: _profile.avatarUrl,
                size: 120,
                showEditIcon: true,
                onTap: _onAvatarTap,
              ),

              // Profile form
              ProfileForm(
                profile: _profile,
                onProfileChanged: _onProfileChanged,
                onSave: _onSave,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
