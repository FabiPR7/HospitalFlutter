import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/domain/Firebase/UserFirebase.dart';
import 'package:mi_hospital/appConfig/domain/sqlite/Sqlite.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Rooms/presentation/RoomScreen.dart';
import 'package:mi_hospital/sections/Patients/presentation/PatientsScreen.dart';
import 'package:mi_hospital/sections/Staff/presentation/StaffScreen.dart';
import 'package:mi_hospital/sections/Menu_main/presentation/widgets_main_menu.dart';
import 'package:mi_hospital/sections/Profile/presentation/profile.dart';
import 'package:mi_hospital/sections/Settings/presentation/setting.dart';
import 'package:mi_hospital/sections/tasks/presentation/tasks.dart';
import 'package:mi_hospital/sections/Menu_main/presentation/drawer_menu.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:mi_hospital/domain/Data/DataFuture.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String userName = '';
  String code = "";
  bool isSwitchOn = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      code = codigo ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: WidgetsMainMenu().appBarMenu(_scaffoldKey),
      drawer: DrawerMenu(
        userName: userName,
        code: code,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeController.to.getBackgroundBlue().withOpacity(0.1),
              ThemeController.to.getWhite(),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ThemeController.to.getWhite(),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeController.to.getGrey().withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: ThemeController.to.getButtonBlue().withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ThemeController.to.getButtonBlue().withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ThemeController.to.getButtonBlue(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isEmpty ? 'Cargando...' : userName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeController.to.getDarkGrey(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeController.to.getButtonBlue().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Código: $code',
                              style: TextStyle(
                                fontSize: 12,
                                color: ThemeController.to.getButtonBlue(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isSwitchOn,
                      onChanged: (value) {
                        setState(() {
                          isSwitchOn = value;
                        });
                        Userfirebase().updateUserStateByCode(code, value);
                      },
                      activeColor: ThemeController.to.getButtonBlue(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildMenuCard(
                      'Pacientes',
                      Icons.people,
                      ThemeController.to.getButtonBlue(),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PacientesScreen()),
                      ),
                    ),
                    _buildMenuCard(
                      'Habitaciones',
                      Icons.bed,
                      ThemeController.to.getLightBlue(),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RoomScreen()),
                      ),
                    ),
                    _buildMenuCard(
                      'Personal',
                      Icons.medical_services,
                      ThemeController.to.getButtonBlue(),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StaffScreen()),
                      ),
                    ),
                    _buildMenuCard(
                      'Tareas',
                      Icons.task,
                      ThemeController.to.getLightBlue(),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TasksScreen(
                            codePrefix: GetData().getHospitalCode(),
                          ),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      'Perfil',
                      Icons.person,
                      ThemeController.to.getButtonBlue(),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      ),
                    ),
                    _buildMenuCard(
                      'Ajustes',
                      Icons.settings,
                      ThemeController.to.getLightBlue(),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: isSwitchOn ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeController.to.getWhite(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Opacity(
          opacity: isSwitchOn ? 1.0 : 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
