import 'package:flutter/material.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Rooms/entities/Room.dart';
import 'package:mi_hospital/sections/Rooms/entities/RoomFirebase.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';

class AddRoomDialog extends StatefulWidget {
  final String hospitalCode;
  final Function(Room) onSave;

  const AddRoomDialog({
    Key? key,
    required this.hospitalCode,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _floorController = TextEditingController();
  final _stretchesController = TextEditingController();
  final RoomFirebase _roomFirebase = RoomFirebase();

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _floorController.dispose();
    _stretchesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeHospital.getButtonBlue().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_home_work, color: ThemeHospital.getButtonBlue(), size: 24),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Agregar Habitación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeHospital.getButtonBlue(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      'Nombre',
                      _nameController,
                      Icons.door_front_door_outlined,
                      'Por favor ingrese un nombre',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Departamento',
                      _departmentController,
                      Icons.business_outlined,
                      'Por favor ingrese un departamento',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Piso',
                      _floorController,
                      Icons.layers_outlined,
                      'Por favor ingrese un piso',
                      isNumeric: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Número de Camillas',
                      _stretchesController,
                      Icons.bed_outlined,
                      'Por favor ingrese el número de camillas',
                      isNumeric: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeHospital.getButtonBlue(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String validatorText, {
    bool isNumeric = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeHospital.getButtonBlue().withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ThemeHospital.getButtonBlue()),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: ThemeHospital.getButtonBlue().withOpacity(0.7),
            fontSize: 16,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ThemeHospital.getButtonBlue(),
              width: 2,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorText;
          }
          if (isNumeric) {
            if (int.tryParse(value) == null) {
              return 'En $label solo se pueden ingresar números';
            }
          }
          return null;
        },
      ),
    );
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    if (_floorController.text.isEmpty || 
        !RegExp(r'^[0-9]+$').hasMatch(_floorController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En Piso solo se pueden ingresar números'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_stretchesController.text.isEmpty || 
        !RegExp(r'^[0-9]+$').hasMatch(_stretchesController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En Número de Camillas solo se pueden ingresar números'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _roomFirebase.insertRoom(
        name: _nameController.text,
        department: _departmentController.text,
        floor: int.parse(_floorController.text),
        stretches: int.parse(_stretchesController.text),
        code: GetData().getHospitalCode(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Habitación agregada exitosamente'),
            backgroundColor: ThemeHospital.getButtonBlue(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
