// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ThemeHospital {
  List<Color> colors = [
    Colors.lightBlue,
    Colors.deepOrange,
    Colors.purple,
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.pink,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.lime,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  ThemeData themeData() {
    return ThemeData(useMaterial3: true, colorSchemeSeed: colors[color]);
  }

  int color;
  ThemeHospital({required this.color});

  static Color getButtonBlue() {
    return const Color(0xFF2196F3);
  }

  static Color getLightBlue() {
    return const Color(0xFF48CAE4);
  }

  static Color getDarkBlue() {
    return const Color(0xFF0077B6);
  }

  static Color getBackgroundBlue() {
    return const Color(0xFFCAF0F8);
  }

  static Color getErrorRed() {
    return const Color(0xFFE34545);
  }

  static Color getWhite() {
    return const Color(0xFFFFFFFF);
  }

  static Color getTaskCardColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.green.shade100; // Verde para tareas recientes
      case 1:
        return Colors.yellow.shade100; // Amarillo para tareas de 1-2 horas
      case 2:
        return Colors.red.shade100; // Rojo para tareas de más de 2 horas
      default:
        return Colors.green.shade100;
    }
  }
}
