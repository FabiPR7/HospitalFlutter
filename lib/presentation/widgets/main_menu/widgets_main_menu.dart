import 'package:flutter/material.dart';

class WidgetsMainMenu {
  Widget imageButtonBySrc(String src, double h) {
    return IconButton(onPressed: () {}, icon: Image.asset(src, height: h));
  }

  AppBar appBarMenu() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        style: ButtonStyle(),
        onPressed: () {
          // Add your onPressed logic here
        },
      ),
      title: Image.asset("assets/images/log/logo.png", height: 50),
      backgroundColor: const Color(0xFF2196F3),
    );
  }
}
