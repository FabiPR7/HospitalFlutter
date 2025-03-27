import 'package:flutter/material.dart';
import 'package:mi_hospital/presentation/widgets/main_menu/widgets_main_menu.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetsMainMenu().appBarMenu(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/habitaciones.png",
                    130,
                  ),
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/pacientes.png",
                    135,
                  ),
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/personal.png",
                    130,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/ajustes.png",
                    130,
                  ),
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/perfil.png",
                    132,
                  ),
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/tareas.png",
                    132,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
