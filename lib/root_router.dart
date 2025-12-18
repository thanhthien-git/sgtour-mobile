import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtour_mobile/providers/locale_provider.dart';
import 'package:sgtour_mobile/screens/auth/login_screen.dart';
import 'package:sgtour_mobile/screens/home/main_navigation.dart';
import 'package:sgtour_mobile/providers/auth_provider.dart';
import 'package:sgtour_mobile/screens/language/language_selection_screen.dart';
import 'package:sgtour_mobile/screens/onboarding/onboarding_screen.dart';
import 'package:sgtour_mobile/screens/splash_screen.dart';

class RootRouter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);

    if (!localeState.isInitialized || !authState.checked) {
      return const SplashScreen();
    }

    if (localeState.isFirstLaunch) {
      return const LanguageSelectionScreen();
    }

    if (!localeState.isCompletedOnboarding) {
      return const OnboardingScreen();
    }

    if (authState.isAuthenticated) {
      return const MainNavigation();
    }

    return const LoginScreen();
  }
}
