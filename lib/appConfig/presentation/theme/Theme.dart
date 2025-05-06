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
}
