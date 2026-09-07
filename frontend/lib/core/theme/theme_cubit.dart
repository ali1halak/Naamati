import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

/// Persists the user's light/dark/system preference across launches.
///
/// Activates the dark theme `AppTheme.dark` already fully defines — until
/// now `MaterialApp.router` hard-coded `ThemeMode.system` with no way for the
/// user to override it.
@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_readInitial(_prefs));

  static ThemeMode _readInitial(SharedPreferences prefs) {
    final stored = prefs.getString(StorageKeys.appThemeMode);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  bool get isDark => state == ThemeMode.dark;

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _prefs.setString(StorageKeys.appThemeMode, mode.name);
  }

  /// Convenience toggle for a single dark-mode [Switch] — `off` maps back to
  /// `system` rather than forcing `light`, so a user who never touched the
  /// toggle keeps following the OS setting until they explicitly opt out.
  Future<void> toggleDark(bool enabled) {
    return setMode(enabled ? ThemeMode.dark : ThemeMode.system);
  }
}
