import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final themeProvider =
StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {

  ThemeNotifier()
      : super(_loadTheme());

  static ThemeMode _loadTheme() {
    final box = Hive.box('settings');

    bool isDark =
    box.get(
      'theme_mode',
      defaultValue: false,
    );

    return isDark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void toggle(bool dark) {

    Hive.box('settings').put(
      'theme_mode',
      dark,
    );

    state =
    dark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

}