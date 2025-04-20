import 'package:flutter/material.dart';
import 'package:mi_hospital/domain/sqlite/Sqlite.dart';
import 'package:mi_hospital/presentation/widgets/log_Sign/widgets_Sign_In.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
            WidgetsSignIn().iniciarSesionTextLogIn(),
            WidgetsSignIn().containerLogin(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
