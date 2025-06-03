import 'package:flutter/material.dart';
import 'package:mi_hospital/sections/Sign_in/presentation/widgets_Sign_In.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            WidgetsSignIn().iniciarSesionTextLogIn(),
            WidgetsSignIn().containerLogin(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
