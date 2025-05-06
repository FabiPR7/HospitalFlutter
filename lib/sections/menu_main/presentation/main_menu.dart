import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/domain/Firebase/UserFirebase.dart';
import 'package:mi_hospital/appConfig/domain/sqlite/Sqlite.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Rooms/presentation/RoomScreen.dart';
import 'package:mi_hospital/sections/Patients/presentation/PatientsScreen.dart';
import 'package:mi_hospital/sections/Staff/presentation/StaffScreen.dart';
import 'package:mi_hospital/sections/menu_main/presentation/widgets_main_menu.dart';
import 'package:mi_hospital/sections/tasks/presentation/tasks.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String userName = '';
  String code = "";
  bool isSwitchOn = true;
  @override
  void initState() {
    super.initState();
    cargarNombreUsuario();
  }

  void cargarNombreUsuario() async {
    String? nombre = await DatabaseHelper().getUserName();
    String? codigo = await DatabaseHelper().getUserCode();
    setState(() {
      nombre = nombre?.replaceAll("}", "");
      userName = nombre ?? 'Invitado';
      code = codigo!;
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
                      Userfirebase().updateUserStateByCode(code, value);
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
                    130, isSwitchOn,() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitacionesScreen(),
                        ),
                      );
                    }
                  ),
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/pacientes.png",
                    135,isSwitchOn,() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PacientesScreen(),
                        ),
                      );
                    }
                  ),
                  WidgetsMainMenu().imageButtonBySrc(
                    "assets/images/buttons/personal.png",
                    130,isSwitchOn, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StaffScreen(),
                        ),
                      );
                    }
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
                    132,isSwitchOn, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TasksScreen(codePrefix: GetData().getHospitalCode(),),
                        ),
                      );
                    }
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
