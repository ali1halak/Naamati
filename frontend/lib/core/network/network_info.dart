import 'package:connectivity_plus/connectivity_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NetworkInfo abstraction
// ─────────────────────────────────────────────────────────────────────────────

/// Contract for checking device network connectivity.
///
/// Abstracts `connectivity_plus` behind an interface so it can be
/// swapped out (or mocked) without touching any consumer code.
abstract class NetworkInfo {
  /// Returns `true` if the device currently has network access.
  Future<bool> get isConnected;
}

// ─────────────────────────────────────────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────────────────────────────────────────

/// [NetworkInfo] implementation backed by [Connectivity] from `connectivity_plus`.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    // `checkConnectivity` returns a list; we have connectivity if at least
    // one result is not [ConnectivityResult.none].
    return results.any((r) => r != ConnectivityResult.none);
  }
}
