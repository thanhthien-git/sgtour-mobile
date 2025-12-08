import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgtour_mobile/screens/splash_screen.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConfig.appName,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SGTour'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to ${AppConfig.appName}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme();
              },
              child: const Text('Toggle Dark Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
