import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection_container.dart';
import 'core/push/push_notification_service.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/splash/presentation/splash_lottie.dart';

/// Application entry point.
///
/// 1. Ensures Flutter bindings are initialised before async work.
/// 2. Loads environment variables from .env file.
/// 3. Wires up all core dependencies via [configureDependencies].
/// 4. Launches the app with light/dark theming, [GoRouter] routing, and
///    [ScreenUtilInit] for responsive sizing.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait — the UI is designed mobile-portrait only.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables.
  await dotenv.load(fileName: ".env");

  // Reads android/app/google-services.json natively — no explicit options
  // needed since only Android is targeted.
  await Firebase.initializeApp();

  // Register all core (and later, feature) dependencies.
  await configureDependencies();

  // Permission + token registration + foreground banners + tap-to-navigate.
  // Fire-and-forget: push setup should never block first paint.
  unawaited(sl<PushNotificationService>().init());

  // Pre-decode the splash lottie so it renders on the splash's first frame
  // instead of appearing after a visible delay.
  await SplashLottie.preload();

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
        return BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>(),
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) => MaterialApp.router(
              title: 'نِعْمَتِي',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: AppRouter.router,
            ),
          ),
        );
      },
    );
  }
}
