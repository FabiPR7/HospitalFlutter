import 'package:flutter/material.dart';

class ThemeController {
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;
  ThemeController._internal();

  static ThemeController get to => _instance;

  Color getButtonBlue() => const Color(0xFF2196F3);
  Color getTextColor() => Colors.black;
  Color getCardColor() => Colors.white;
  Color getSurfaceColor() => Colors.grey[100]!;
  Color getGrey() => Colors.grey;
  Color getErrorRed() => Colors.red;
} 