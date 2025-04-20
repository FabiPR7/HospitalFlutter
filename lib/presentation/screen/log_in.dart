import 'package:flutter/material.dart';
import 'package:mi_hospital/presentation/widgets/log_Sign/widgets_Log_In.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("assets/images/log/logo.png", height: 50),
        backgroundColor: const Color(0xFF2196F3),
      ),
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
