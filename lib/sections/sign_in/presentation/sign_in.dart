import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/sections/sign_in/presentation/widgets_Sign_In.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBarHospital().getAppBar(),
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
