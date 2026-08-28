import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection_container.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

/// Application entry point.
///
/// 1. Ensures Flutter bindings are initialised before async work.
/// 2. Loads environment variables from .env file.
/// 3. Wires up all core dependencies via [configureDependencies].
/// 4. Launches the app with light/dark theming, [GoRouter] routing, and
///    [ScreenUtilInit] for responsive sizing.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables.
  await dotenv.load(fileName: ".env");

  // Register all core (and later, feature) dependencies.
  configureDependencies();

  runApp(const NaamatiApp());
}

/// Root application widget.
class NaamatiApp extends StatelessWidget {
  const NaamatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Naamati',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
