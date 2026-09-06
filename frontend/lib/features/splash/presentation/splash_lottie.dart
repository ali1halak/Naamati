import 'package:lottie/lottie.dart';

/// Preloads and caches the splash logo lottie composition.
///
/// [preload] is called in `main()` before [runApp] so [SplashPage] can render
/// the animation synchronously on its very first frame — decoding the large
/// image-sequence JSON at widget-build time makes the logo appear noticeably
/// late on the screen.
abstract class SplashLottie {
  static const String assetName = 'assets/lotties/logo_transition.json';

  static LottieComposition? _composition;

  /// Preloaded composition, or `null` if [preload] hasn't run/succeeded yet.
  static LottieComposition? get composition => _composition;

  static Future<void> preload() async {
    try {
      _composition ??= await AssetLottie(assetName).load();
    } catch (_) {
      // SplashPage falls back to Lottie.asset if preloading failed.
    }
  }
}
