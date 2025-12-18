// dart
import 'package:flutter/material.dart';
import 'package:sgtour_mobile/screens/auth/login_screen.dart';
import 'package:sgtour_mobile/services/storage_service.dart';
import 'package:sgtour_mobile/widgets/common/custom_button.dart';
import 'package:sgtour_mobile/widgets/common/decorative_circle_background.dart';
import '../../config/app_colors.dart';
import '../../utils/extensions/localization_extension.dart';
import 'widgets/onboard_page.dart';
import '../../widgets/common/dots_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<OnboardData> _getPages(BuildContext context) {
    final l10n = context.l10n;
    return [
      OnboardData(
        title: l10n.onboarding_title1,
        description: l10n.onboarding_desc1,
        imageAsset: 'assets/images/splash.png',
      ),
      OnboardData(
        title: l10n.onboarding_title2,
        description: l10n.onboarding_desc2,
        imageAsset: 'assets/images/splash.png',
      ),
      OnboardData(
        title: l10n.onboarding_title3,
        description: l10n.onboarding_desc3,
        imageAsset: 'assets/images/splash.png',
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext(int pageCount) {
    if (_currentIndex < pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (_currentIndex == pageCount - 1) {
      StorageService.instance.setBool(StorageKeys.onboardingCompleted, true);
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(context);
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // SVG Background
          const DecorativeCircleBackground(),
          // Main Content
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (_, index) => OnboardPage(data: pages[index]),
                ),
              ),
              DotsIndicator(count: pages.length, index: _currentIndex),
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    CustomButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      label: _currentIndex == pages.length - 1
                          ? l10n.onboarding_getStarted
                          : l10n.common_next,
                      onPressed: () => _goNext(pages.length),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
