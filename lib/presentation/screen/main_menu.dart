import 'package:flutter/material.dart';
import 'package:mi_hospital/domain/sqlite/Sqlite.dart';
import 'package:mi_hospital/presentation/widgets/main_menu/widgets_main_menu.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String userName = '';
  bool isSwitchOn = true;
  @override
  void initState() {
    super.initState();
    cargarNombreUsuario();
  }

  void cargarNombreUsuario() async {
    final nombre = await DatabaseHelper().getUserName();
    setState(() {
      userName = nombre ?? 'Invitado';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetsMainMenu().appBarMenu(),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    userName.isEmpty ? 'Cargando...' : userName,
                    style: const TextStyle(fontFamily: "arial", fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Switch(
                    value: isSwitchOn,
                    onChanged: (value) {
                      setState(() {
                        isSwitchOn = value;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 20, 84, 223),
                  ),
                ),
              ],
            ),
            Padding(      
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/habitaciones.png",
                    130, isSwitchOn
                  ),
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/pacientes.png",
                    135,isSwitchOn
                  ),
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/personal.png",
                    130,isSwitchOn
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
                    130,isSwitchOn
                  ),
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/perfil.png",
                    132,isSwitchOn
                  ),
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/tareas.png",
                    132,isSwitchOn
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
