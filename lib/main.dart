import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtourcus/bootstrap_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BootstrapService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}
