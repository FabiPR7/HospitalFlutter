import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Rooms/entities/Room.dart';
import 'package:mi_hospital/sections/Rooms/presentation/widgets_Room.dart';

class HabitacionesScreen extends StatefulWidget {
  const HabitacionesScreen({super.key});

  @override
  State<HabitacionesScreen> createState() => _HabitacionesScreenState();
}

class _HabitacionesScreenState extends State<HabitacionesScreen> {


  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddRoomDialog(
          hospitalCode: GetData().getHospitalCode(),
          onSave: (Room newRoom) async {
           // await HabitacionFirebase().addRoom(newRoom);
            setState(() {}); // Refrescar la vista
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHospital().getAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add),
      ),
      body: WidgetsHabitacion(hospitalCode: GetData().getHospitalCode()),
    );
  }
}
