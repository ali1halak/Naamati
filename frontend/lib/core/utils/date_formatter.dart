/// Lightweight Arabic-friendly date formatting helpers (no intl dependency).
///
/// All formatters convert to the device's local time first — backend
/// timestamps arrive as UTC ISO strings.
abstract class DateFormatter {
  static String _two(int n) => n.toString().padLeft(2, '0');

  /// `01/09/2026 · 03:30 م`
  static String formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final period = local.hour < 12 ? 'ص' : 'م';
    return '${_two(local.day)}/${_two(local.month)}/${local.year} · '
        '${_two(hour12)}:${_two(local.minute)} $period';
  }

  /// `01/09/2026`
  static String formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    return '${_two(local.day)}/${_two(local.month)}/${local.year}';
  }

  /// ETA in minutes → `45 دقيقة` / `ساعتان ونصف` style short text.
  static String formatEta(int? minutes) {
    if (minutes == null) return '—';
    if (minutes < 60) return '$minutes دقيقة';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours ساعة';
    return '$hours ساعة و $mins دقيقة';
  }
}
