import 'package:flutter/material.dart';
import 'package:mi_hospital/sections/Rooms/entities/Room.dart';
import 'package:mi_hospital/sections/Rooms/entities/RoomFirebase.dart';



class WidgetsRoom extends StatefulWidget {
  final String hospitalCode;

  const WidgetsRoom({super.key, required this.hospitalCode});

  @override
  State<WidgetsRoom> createState() => _WidgetsRoomState();
}

class _WidgetsRoomState extends State<WidgetsRoom> {
  List<Room> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    HabitacionFirebase habitacionFirebase = HabitacionFirebase();
    final fetchedRooms = await habitacionFirebase.getRoomsByHospitalCode(
      widget.hospitalCode,
    );
   //Room(id: '', name: 'jaja', stretches: 10, floor: 1, available: 10, code: '123', department: 'jaja')];
    setState(() {
   
    // rooms = fetchedRooms; <= ERROR AQUI
      isLoading = false;
    });
  }

  Widget buildRoomCard(Room room) {
    final occupied = (room.stretches - room.available).clamp(0, room.stretches);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      color: room.stretches != occupied
          ? const Color(0xFFFFFFFF)
          : const Color(0xFFE34545),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: room.stretches != occupied
                    ? const Color(0xFF48CAE4)
                    : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Departamento: ${room.department}',
              style: TextStyle(
                fontSize: 14,
                color: room.stretches != occupied
                    ? const Color(0xFF48CAE4)
                    : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Piso: ${room.floor}',
              style: TextStyle(
                fontSize: 14,
                color: room.stretches != occupied
                    ? const Color(0xFF48CAE4)
                    : Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: room.stretches != occupied
                    ? const Color(0xFFCAF0F8)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${room.stretches}/$occupied camillas',
                style: TextStyle(
                  fontSize: 14,
                  color: room.stretches != occupied
                      ? const Color(0xFF0077B6)
                      : const Color(0xFFFF0000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRoomList() {
    return ListView.builder(
      itemCount: rooms.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        return buildRoomCard(rooms[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rooms.isEmpty) {
      return const Center(
        child: Text('No se encontraron habitaciones de hospital'),
      );
    }

    return buildRoomList();
  }
}

class AddRoomDialog extends StatefulWidget {
  final Function(Room) onSave;
  final String hospitalCode;

  const AddRoomDialog({
    Key? key,
    required this.onSave,
    required this.hospitalCode,
  }) : super(key: key);

  @override
  _AddRoomDialogState createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stretchesController = TextEditingController(text: '0');
  final _departmentController = TextEditingController();
  final _floorController = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameController.dispose();
    _stretchesController.dispose();
    _departmentController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final room = Room(
        id: '', // El ID lo asigna Firebase
        name: _nameController.text,
        stretches: int.parse(_stretchesController.text),
        floor: int.parse(_floorController.text),
        available: int.parse(_stretchesController.text),
        code: widget.hospitalCode,
        department: _departmentController.text,
      );

      widget.onSave(room);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar nueva habitación'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor ingrese un nombre' : null,
              ),
              TextFormField(
                controller: _stretchesController,
                decoration: const InputDecoration(labelText: 'Número de camillas'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || int.tryParse(value) == null ? 'Ingrese un número válido' : null,
              ),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Departamento'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor ingrese un departamento' : null,
              ),
              TextFormField(
                controller: _floorController,
                decoration: const InputDecoration(labelText: 'Piso'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || int.tryParse(value) == null ? 'Ingrese un número válido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _saveForm, child: const Text('Guardar')),
      ],
    );
  }
}
