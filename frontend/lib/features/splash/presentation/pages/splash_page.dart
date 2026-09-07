import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../splash_lottie.dart';

/// Animated brand splash screen.
///
/// A brand-fixed dark-green canvas (same visual language as the welcome
/// page's hero) that stays identical in light and dark mode. The logo lottie —
/// which bakes in a near-white background and ends on the "نعمتي" wordmark —
/// floats as a rounded white card over the green, with the tagline in white
/// beneath it and a gold loading hint at the bottom.
///
/// Navigation happens when the logo animation completes and the stored access
/// token has been checked: the user is routed to [RouteNames.home]
/// (authenticated) or [RouteNames.welcome].
///
/// Route: [RouteNames.splash] (`/splash`), set as [AppRouter.initialLocation].
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

// TickerProviderStateMixin (not the single-ticker variant): the state owns two
// AnimationControllers — one for the text intro, one for the lottie.
class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  /// Safety net so a failed/stalled animation can never hang the splash.
  static const Duration _fallbackTimeout = Duration(seconds: 12);

  late final AnimationController _introController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  /// Drives the lottie; its duration is set once the composition loads.
  late final AnimationController _lottieController;

  Timer? _fallbackTimer;
  String _destination = RouteNames.welcome;
  bool _authDone = false;
  bool _animDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animDone = true;
        _tryNavigate();
      }
    });

    _introController.forward();

    // Preloaded composition: start immediately (onLoaded won't fire for the
    // direct-composition [Lottie] widget).
    final composition = SplashLottie.composition;
    if (composition != null) {
      _lottieController
        ..duration = composition.duration
        ..forward(from: 0);
    }

    _fallbackTimer = Timer(_fallbackTimeout, _tryNavigate);
    _checkAuth();
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _introController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  void _onLottieLoaded(LottieComposition composition) {
    if (!mounted) return;
    _lottieController
      ..duration = composition.duration
      ..forward(from: 0);
  }

  /// Checks for a stored token and, if present, resolves *which* home the
  /// signed-in account belongs on — a bare "has a token" check previously
  /// sent every authenticated user (charity included) to the donor home,
  /// mirrors the role/status branch [LoginCubit]'s listener already uses.
  Future<void> _checkAuth() async {
    final secureStorage = sl<FlutterSecureStorage>();
    final accessToken = await secureStorage.read(key: StorageKeys.accessToken);
    if (accessToken == null || accessToken.isEmpty) {
      _destination = RouteNames.welcome;
      _authDone = true;
      _tryNavigate();
      return;
    }

    final result = await sl<GetCurrentUserUseCase>()(const NoParams());
    _destination = result.fold(
      // Stale/expired token — the auth interceptor already cleared it.
      (_) => RouteNames.welcome,
      _destinationFor,
    );
    _authDone = true;
    _tryNavigate();
  }

  String _destinationFor(User user) {
    if (user.accountType == 'charity') {
      if (user.status == 'suspended') return RouteNames.charitySuspended;
      if (user.status == 'pending') return RouteNames.charityPending;
      return RouteNames.charityHome;
    }
    return RouteNames.home;
  }

  /// Leaves the splash only after both the animation finished and the auth
  /// check has resolved.
  void _tryNavigate() {
    if (!mounted || _navigated || !_authDone || !_animDone) return;
    _navigated = true;
    context.go(_destination);
  }

  @override
  Widget build(BuildContext context) {
    final composition = SplashLottie.composition;

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryDark, AppColors.brandGreen],
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative glow circles ──────────────────────────────────
              Positioned(
                top: -80.r,
                left: -60.r,
                child: const _GlowCircle(size: 220),
              ),
              Positioned(
                top: 120.r,
                right: -90.r,
                child: const _GlowCircle(size: 260, tint: AppColors.secondary),
              ),
              Positioned(
                bottom: -100.r,
                left: -70.r,
                child: const _GlowCircle(size: 280),
              ),

              // ── Brand content ────────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Logo animation framed as a floating white card over the
                    // green canvas. The lottie's baked-in near-white background
                    // fills the card, and the animation ends on the "نعمتي"
                    // wordmark — so no static title is rendered here.
                    Flexible(
                      flex: 5,
                      child: Center(
                        child: Container(
                          width: 320.w,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.30),
                                blurRadius: 36,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AspectRatio(
                            aspectRatio: 720 / 405,
                            child: (composition != null)
                                ? Lottie(
                                    composition: composition,
                                    controller: _lottieController,
                                    fit: BoxFit.cover,
                                  )
                                : Lottie.asset(
                                    SplashLottie.assetName,
                                    controller: _lottieController,
                                    onLoaded: _onLottieLoaded,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          'نحول فائض الطعام إلى نعمة تصل مستحقيها',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ── Bottom loading hint ────────────────────────────────
                    Flexible(
                      flex: 4,
                      child: Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24.r,
                                height: 24.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.secondaryLight,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'من فائضك... نعمة لغيرك',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft translucent circle used as ambient decoration on the green canvas.
class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, this.tint});

  final double size;

  /// Optional warm tint (e.g. gold) for the circle; defaults to white.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? Colors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.08), width: 1),
      ),
    );
  }
}
