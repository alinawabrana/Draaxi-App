import 'package:draaxi/src/router/app_routes.dart';
import 'package:draaxi/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'DRAAXI',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ATheme.lightModeThemes,
      darkTheme: ATheme.darkModeThemes,
      routerConfig: AppRoutes.routes(ref),
    );
  }
}
