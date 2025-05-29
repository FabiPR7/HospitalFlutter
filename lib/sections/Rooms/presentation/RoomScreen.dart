import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Rooms/entities/Room.dart';
import 'package:mi_hospital/sections/Rooms/entities/RoomFirebase.dart';
import 'package:mi_hospital/sections/Rooms/presentation/widgets_Room.dart';
import 'package:mi_hospital/sections/Rooms/presentation/AddRoomDialog.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final RoomFirebase _roomFirebase = RoomFirebase();
  final _widgetsRoomKey = GlobalKey<WidgetsRoomState>();

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddRoomDialog(
          hospitalCode: GetData().getHospitalCode(),
          onSave: (Room newRoom) async {
            try {
              await _roomFirebase.insertRoom(
                name: newRoom.name,
                department: newRoom.department,
                floor: newRoom.floor,
                stretches: newRoom.stretches,
                code: newRoom.code,
              );
              if (mounted) {
                Navigator.pop(context);
                _widgetsRoomKey.currentState?.fetchRooms();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Habitación agregada exitosamente')),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al agregar habitación: $e')),
                );
              }
            }
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
        backgroundColor: ThemeHospital.getButtonBlue(),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: WidgetsRoom(
        key: _widgetsRoomKey,
        hospitalCode: GetData().getHospitalCode(),
      ),
    );
  }
}
