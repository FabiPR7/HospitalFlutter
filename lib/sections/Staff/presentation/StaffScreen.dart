import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/sections/Staff/presentation/widgets_Staff.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHospital().getAppBar(),
      body: const WidgetsStaff(),
    );
  }
}
