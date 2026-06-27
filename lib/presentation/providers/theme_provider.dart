import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/service_locator.dart';
import '../../data/datasources/local/local_datasource.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final _local = ServiceLocator().get<LocalDataSource>();

  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  void _loadTheme() {
    final mode = _local.getString(AppConstants.prefThemeMode);
    if (mode != null) {
      state = switch (mode) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.dark,
      };
    }
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    _local.setString(AppConstants.prefThemeMode, mode.name);
  }

  void toggleTheme() {
    setTheme(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}

final themeDataProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeModeProvider);
  if (mode == ThemeMode.light) return AppTheme.lightTheme;
  return AppTheme.darkTheme;
});

final isDarkModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(themeModeProvider);
  return mode != ThemeMode.light;
});
