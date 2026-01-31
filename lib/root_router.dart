import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtourcus/providers/locale_provider.dart';
import 'package:sgtourcus/providers/auth_provider.dart';
import 'package:sgtourcus/screens/auth/login_screen.dart';
import 'package:sgtourcus/screens/home/main_navigation.dart';
import 'package:sgtourcus/screens/language/language_selection_screen.dart';
import 'package:sgtourcus/screens/onboarding/onboarding_screen.dart';

class RootRouter extends ConsumerWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);

    if (!localeState.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (localeState.isFirstLaunch) {
      return const LanguageSelectionScreen();
    }

    if (!localeState.isCompletedOnboarding) {
      return const OnboardingScreen();
    }

    return authState.when(
      data: (isAuthenticated) {
        if (isAuthenticated) {
          return const MainNavigation();
        } else {
          return const LoginScreen();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const LoginScreen(),
    );
  }
}
