import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/profile/presentation/widgets_profile.dart';

class ProfilePage extends StatelessWidget {

  var userLogin = GetData().getUserLogin();

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarHospital().getAppBar(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.shade100,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widgets_Profile().getAvatar(),
            const SizedBox(height: 20),
            widgets_Profile().getWidgetNameSurName(userLogin["nombre"], ""),
            const SizedBox(height: 8),
            widgets_Profile().getWidgetCode(userLogin["codigo"]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widgets_Profile().getIconHospital(),
                const SizedBox(width: 8),
                widgets_Profile().getNameHospital(userLogin["hospital"]),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 1.2),
            const SizedBox(height: 10),
            // Más widgets si quieres
          ],
        ),
      ),
    );
  }
}
