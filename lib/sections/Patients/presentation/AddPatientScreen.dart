import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:mi_hospital/sections/Rooms/entities/RoomFirebase.dart';
import 'package:mi_hospital/sections/Rooms/entities/Room.dart';
import 'package:mi_hospital/sections/Patients/entities/PatientsFirebase.dart';
import 'package:mi_hospital/sections/Tasks/entitites/TasksFirebase.dart';
import 'package:mi_hospital/main.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({Key? key}) : super(key: key);

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _tareaController = TextEditingController();
  String? _selectedRoomId;
  List<Room> _rooms = [];
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _tareas = [];
  final Tasksfirebase _tasksFirebase = Tasksfirebase();

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final roomFirebase = RoomFirebase();
    final rooms = await roomFirebase.getRoomsByHospitalCode(GetData().getHospitalCode());
    setState(() {
      _rooms = rooms;
      _isLoading = false;
    });
  }

  void _addTask() {
    if (_tareaController.text.isNotEmpty) {
      setState(() {
        _tareas.add({
          'description': _tareaController.text,
          'assignedTo': null,
        });
        _tareaController.clear();
      });
    }
  }

  void _deleteTask(int index) {
    setState(() {
      _tareas.removeAt(index);
    });
  }

  void _showAssignDialog(int taskIndex) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedStaff;
        final staffList = (GetData().getStaffList() as List).map((staff) {
          final Map<dynamic, dynamic> staffMap = staff as Map<dynamic, dynamic>;
          return {
            'codigo': staffMap['codigo']?.toString(),
            'name': staffMap['name']?.toString(),
          };
        }).toList();
        
        return AlertDialog(
          title: const Text('Asignar Tarea'),
          content: DropdownButtonFormField<String>(
            value: selectedStaff,
            decoration: InputDecoration(
              labelText: 'Seleccionar Personal',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: staffList.map((staff) {
              return DropdownMenuItem<String>(
                value: staff['codigo'],
                child: Text(staff['name'] ?? ''),
              );
            }).toList(),
            onChanged: (value) {
              selectedStaff = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedStaff != null) {
                  setState(() {
                    _tareas[taskIndex]['assignedTo'] = selectedStaff;
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48CAE4),
              ),
              child: const Text('Asignar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardarPaciente() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      setState(() {
        _isSaving = true;
      });

      try {
        final roomFirebase = RoomFirebase();
        final rooms = await roomFirebase.getRoomsByHospitalCode(GetData().getHospitalCode());
        final selectedRoom = rooms.firstWhere((room) => room.id == _selectedRoomId);
        
        if (selectedRoom.available <= 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No hay camillas disponibles en la habitación ${selectedRoom.name}'),
                backgroundColor: ThemeController.to.getErrorRed(),
              ),
            );
            setState(() {
              _isSaving = false;
            });
          }
          return;
        }

        final pacienteFirebase = PatientsFirebase();
        final now = DateTime.now();
        final formattedDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
        
        final paciente = {
          'dni': _dniController.text,
          'name': _nombreController.text,
          'address': _direccionController.text,
          'phone': _telefonoController.text,
          'description': _descripcionController.text,
          'roomName': selectedRoom.name,
          'admissionDate': formattedDate,
          'task': [],
          'img': 'https://cdn-icons-png.flaticon.com/512/1077/1077114.png',
        };

        await roomFirebase.updateRoomAvailability(
          GetData().getHospitalCode(),
          selectedRoom.name,
          selectedRoom.available - 1,
        );

        await pacienteFirebase.addPatient(paciente, context: context);
    
        for (var tarea in _tareas) {
          await _tasksFirebase.add_task(
            description: tarea['description'],
            patientDni: _dniController.text,
            assignedTo: tarea['assignedTo'],
            createdBy: GetData().getUserLogin()["codigo"],
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Paciente guardado exitosamente'),
              backgroundColor: ThemeController.to.getButtonBlue(),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: $e'),
              backgroundColor: ThemeController.to.getErrorRed(),
            ),
          );
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _dniController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _descripcionController.dispose();
    _tareaController.dispose();
    super.dispose();
  }

  Widget getText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ThemeController.to.getButtonBlue(),
        ),
      ),
    );
  }

  Widget getElevatedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isSaving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isSaving 
          ? ThemeController.to.getButtonBlue().withOpacity(0.5)
          : ThemeController.to.getButtonBlue(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isSaving
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Guardando...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget getTextFormField(
    String labelText,
    String hintText,
    IconData prefixIcon,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: ThemeController.to.getButtonBlue()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ThemeController.to.getButtonBlue().withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ThemeController.to.getButtonBlue().withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ThemeController.to.getButtonBlue(),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: ThemeController.to.getBackgroundBlue().withOpacity(0.1),
        labelStyle: TextStyle(
          color: ThemeController.to.getButtonBlue().withOpacity(0.7),
        ),
        hintStyle: TextStyle(
          color: Colors.grey[400],
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildRoomDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRoomId,
      decoration: InputDecoration(
        labelText: 'Habitación',
        hintText: 'Seleccione una habitación',
        prefixIcon: Icon(Icons.room, color: ThemeController.to.getButtonBlue()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ThemeController.to.getButtonBlue().withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ThemeController.to.getButtonBlue().withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ThemeController.to.getButtonBlue(),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: ThemeController.to.getBackgroundBlue().withOpacity(0.1),
        labelStyle: TextStyle(
          color: ThemeController.to.getButtonBlue().withOpacity(0.7),
        ),
      ),
      items: _rooms.where((room) => room.available > 0).map((room) {
        return DropdownMenuItem<String>(
          value: room.id,
          child: Text('${room.name} - Piso ${room.floor} (${room.available} camillas disponibles)'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRoomId = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor seleccione una habitación';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHospital().getAppBar(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: ThemeController.to.getButtonBlue(),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeController.to.getButtonBlue().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            color: ThemeController.to.getButtonBlue(),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Nuevo Paciente',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeController.to.getButtonBlue(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    getTextFormField(
                      'DNI',
                      'Ingrese el DNI del paciente',
                      Icons.badge,
                      _dniController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el DNI';
                        }
                        if (value.length != 8) {
                          return 'El DNI debe tener 8 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    getTextFormField(
                      'Nombre Completo',
                      'Ingrese el nombre completo',
                      Icons.person,
                      _nombreController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    getTextFormField(
                      'Dirección',
                      'Ingrese la dirección',
                      Icons.location_on,
                      _direccionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese la dirección';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    getTextFormField(
                      'Teléfono',
                      'Ingrese el número de teléfono',
                      Icons.phone,
                      _telefonoController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el teléfono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    getTextFormField(
                      'Descripción',
                      'Ingrese una descripción del paciente',
                      Icons.description,
                      _descripcionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildRoomDropdown(),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeController.to.getButtonBlue().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.task_alt,
                                color: ThemeController.to.getButtonBlue(),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tareas Pendientes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeController.to.getButtonBlue(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: getTextFormField(
                            'Agregar nueva tarea',
                            'Ingrese la tarea',
                            Icons.add_circle,
                            _tareaController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addTask,
                          icon: Icon(
                            Icons.add_circle,
                            color: ThemeController.to.getButtonBlue(),
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._tareas.asMap().entries.map((entry) {
                      final task = entry.value;
                      final assignedTo = task['assignedTo'];
                      String assignedName = 'Sin asignar';
                      if (assignedTo != null) {
                        for (var staff in GetData().getStaffList()) {
                          if (staff['codigo'] == assignedTo) {
                            assignedName = staff['name'];
                            break;
                          }
                        }
                      }
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            task['description'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Asignado a: $assignedName',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.person_add,
                                  color: ThemeController.to.getButtonBlue(),
                                ),
                                onPressed: () => _showAssignDialog(entry.key),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: ThemeController.to.getErrorRed(),
                                ),
                                onPressed: () => _deleteTask(entry.key),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 32),
                    getElevatedButton('Guardar Paciente', _guardarPaciente),
                  ],
                ),
              ),
            ),
    );
  }
} 