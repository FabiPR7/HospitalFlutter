// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode.value);
  }

  Color getButtonBlue() {
    return const Color(0xFF2196F3);
  }

  Color getLightBlue() {
    return const Color(0xFF48CAE4);
  }

  Color getDarkBlue() {
    return isDarkMode ? const Color(0xFF1976D2) : const Color(0xFF0077B6);
  }

  Color getBackgroundBlue() {
    return isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  Color getErrorRed() {
    return isDarkMode ? const Color(0xFFFF5252) : const Color(0xFFE34545);
  }

  Color getWhite() {
    return isDarkMode ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
  }

  Color getGrey() {
    return isDarkMode ? const Color(0xFF757575) : const Color(0xFF9E9E9E);
  }

  Color getLightGrey() {
    return isDarkMode ? const Color(0xFF424242) : const Color(0xFFE0E0E0);
  }

  Color getDarkGrey() {
    return isDarkMode ? const Color(0xFFBDBDBD) : const Color(0xFF424242);
  }

  Color getSuccessGreen() {
    return isDarkMode ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
  }

  Color getWarningYellow() {
    return isDarkMode ? const Color(0xFFFFD54F) : const Color(0xFFFFC107);
  }

  Color getTextColor() {
    return isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }

  Color getCardColor() {
    return isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  }

  Color getSurfaceColor() {
    return isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);
  }

  Color getTaskCardColor(int priority) {
    if (isDarkMode) {
      switch (priority) {
        case 0:
          return const Color(0xFF1B5E20);
        case 1:
          return const Color(0xFFF57F17);
        case 2:
          return const Color(0xFFB71C1C);
        default:
          return const Color(0xFF1B5E20);
      }
    } else {
      switch (priority) {
        case 0:
          return Colors.green.shade100;
        case 1:
          return Colors.yellow.shade100;
        case 2:
          return Colors.red.shade100;
        default:
          return Colors.green.shade100;
      }
    }
  }

  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: getButtonBlue(),
        onPrimary: Colors.white,
        secondary: getLightBlue(),
        onSecondary: Colors.white,
        error: getErrorRed(),
        onError: Colors.white,
        background: getBackgroundBlue(),
        onBackground: getTextColor(),
        surface: getSurfaceColor(),
        onSurface: getTextColor(),
      ),
      scaffoldBackgroundColor: getBackgroundBlue(),
      cardColor: getCardColor(),
      dialogBackgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: getTextColor()),
        bodyMedium: TextStyle(color: getTextColor()),
        titleLarge: TextStyle(color: getTextColor()),
        titleMedium: TextStyle(color: getTextColor()),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: getButtonBlue(),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return getButtonBlue();
          }
          return getGrey();
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return getButtonBlue().withOpacity(0.5);
          }
          return getGrey().withOpacity(0.5);
        }),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        titleTextStyle: TextStyle(
          color: getTextColor(),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: getTextColor(),
          fontSize: 16,
        ),
      ),
    );
  }
}
