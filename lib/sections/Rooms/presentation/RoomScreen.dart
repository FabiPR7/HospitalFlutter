import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/rooms/entities/Room.dart';
import 'package:mi_hospital/sections/rooms/presentation/widgets_Room.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {


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
