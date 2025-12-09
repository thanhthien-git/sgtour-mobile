// dart
import 'package:flutter/material.dart';
import 'package:sgtour_mobile/screens/auth/login_screen.dart';
import 'package:sgtour_mobile/widgets/common/custom_button.dart';
import 'package:sgtour_mobile/widgets/common/decorative_circle_background.dart';
import '../../config/app_colors.dart';
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

  final List<OnboardData> _pages = const [
    OnboardData(
      title: 'Chào mừng đến với SGTour',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam molestie pulvinar consectetur.',
      imageAsset: 'assets/images/splash.png',
    ),
    OnboardData(
      title: 'Gợi ý thông minh',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam molestie pulvinar consectetur.',
      imageAsset: 'assets/images/splash.png',
    ),
    OnboardData(
      title: 'Du lịch cùng AI',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam molestie pulvinar consectetur.',
      imageAsset: 'assets/images/splash.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (_, index) => OnboardPage(data: _pages[index]),
                ),
              ),
              DotsIndicator(count: _pages.length, index: _currentIndex),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 24),
                    CustomButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 56),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      label: _currentIndex == _pages.length - 1
                          ? 'Bắt đầu ngay'
                          : 'Tiếp theo',
                      onPressed: _goNext,
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
