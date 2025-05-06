import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/sections/log_in/presentation/widgets_Log_In.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBarHospital().getAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            WidgetsLogIn().registrarTextLogIn(),
            WidgetsLogIn().containerLogin(context),
          ],
        ),
      ),
    );
  }
}
