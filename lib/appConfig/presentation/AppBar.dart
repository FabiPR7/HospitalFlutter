import 'package:flutter/material.dart';

class AppBarHospital{
  
   AppBar getAppBar(){
   return AppBar(
        title: Image.asset("assets/images/log/logo.png", height: 50),
        backgroundColor: const Color(0xFF2196F3),
      );
   }
}