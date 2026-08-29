import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/charity_account_status_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import 'route_names.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder screens (will be replaced by feature screens)
// ─────────────────────────────────────────────────────────────────────────────

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 64),
            const SizedBox(height: 16),
            const Text('404 — Page not found'),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go(RouteNames.splash),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppRouter
// ─────────────────────────────────────────────────────────────────────────────

/// Central [GoRouter] configuration.
///
/// Feature routes should be added as new [GoRoute] entries inside [_routes].
/// Redirect logic (auth guard, onboarding check) can be wired up in [redirect].
///
/// Usage in [MaterialApp.router]:
/// ```dart
/// MaterialApp.router(
///   routerConfig: AppRouter.router,
/// )
/// ```
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.welcome,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => const _NotFoundPage(),
    // redirect: _guard,  ← uncomment and implement once auth is wired up
    routes: _routes,
  );

  // ── Route Definitions ──────────────────────────────────────────────────────

  static final List<RouteBase> _routes = [
    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (context, state) => const _SplashPage(),
    ),
    GoRoute(
      path: RouteNames.welcome,
      name: 'welcome',
      builder: (context, state) => const WelcomePage(),
    ),

    // ── Auth routes (placeholder) ─────────────────────────────────────────────
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.register,
      name: 'register',
      builder: (context, state) {
        final type = state.uri.queryParameters['type'];
        final initialType = type == 'charity'
            ? RegisterAccountType.charity
            : RegisterAccountType.donor;

        return RegisterPage(initialType: initialType);
      },
    ),
    GoRoute(
      path: RouteNames.charityPending,
      name: 'charity-pending',
      builder: (context, state) => const CharityAccountStatusPage(
        title: 'حسابك قيد المراجعة',
        message:
            'تم استلام طلب تسجيل الجمعية. سيقوم الأدمن بمراجعته يدويًا قبل تفعيل الحساب.',
        icon: Icons.hourglass_top_rounded,
      ),
    ),
    GoRoute(
      path: RouteNames.charitySuspended,
      name: 'charity-suspended',
      builder: (context, state) => const CharityAccountStatusPage(
        title: 'الحساب موقوف',
        message:
            'تم إيقاف حساب الجمعية. يرجى التواصل مع الأدمن لإعادة التفعيل.',
        icon: Icons.block_rounded,
      ),
    ),

    // ── Onboarding (placeholder) ──────────────────────────────────────────────
    GoRoute(
      path: RouteNames.onboarding,
      name: 'onboarding',
      builder: (context, state) =>
          const _SplashPage(), // replace with OnboardingPage
    ),

    // ── Main app routes (placeholder) ─────────────────────────────────────────
    GoRoute(
      path: RouteNames.home,
      name: 'home',
      builder: (context, state) => const _SplashPage(), // replace with HomePage
    ),
    GoRoute(
      path: RouteNames.profile,
      name: 'profile',
      builder: (context, state) =>
          const _SplashPage(), // replace with ProfilePage
    ),
    GoRoute(
      path: RouteNames.settings,
      name: 'settings',
      builder: (context, state) =>
          const _SplashPage(), // replace with SettingsPage
    ),
  ];

  // ── Auth Guard (stub — implement once BLoC auth state is ready) ───────────

  // static String? _guard(BuildContext context, GoRouterState state) {
  //   final isAuthenticated = sl<AuthBloc>().state.isAuthenticated;
  //   final isOnboarded = sl<SharedPreferences>().getBool(StorageKeys.isOnboardingComplete) ?? false;
  //
  //   if (!isAuthenticated && state.matchedLocation != RouteNames.login) {
  //     return RouteNames.login;
  //   }
  //   if (!isOnboarded && state.matchedLocation != RouteNames.onboarding) {
  //     return RouteNames.onboarding;
  //   }
  //   return null; // no redirect
  // }
}
