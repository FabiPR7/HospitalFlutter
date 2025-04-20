import 'package:flutter/material.dart';
import 'package:mi_hospital/domain/sqlite/Sqlite.dart';
import 'package:sqflite/sqlite_api.dart';

class WidgetsMainMenu {

  Widget imageButtonBySrc(String src, double h, bool enabled) {
  return Opacity(
    opacity: enabled ? 1.0 : 0.4, // 🔥 más opaco si está deshabilitado
    child: IconButton(
      onPressed: enabled ? () {
        // Tu acción al presionar
      } : null, // 🔒 desactiva si está en false
      icon: Image.asset(src, height: h),
    ),
  );
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
